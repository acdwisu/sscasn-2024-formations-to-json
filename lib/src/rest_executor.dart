import 'dart:convert';
import 'dart:developer';

import 'package:cli_util/cli_logging.dart';
import 'package:http/http.dart';
import 'package:sscasn_2024_formations_to_json/src/converter/converter.dart';
import 'package:sscasn_2024_formations_to_json/src/converter/param.dart';
import 'package:collection/collection.dart';

enum ExecutionMode { sync, async }

abstract class IRestExecutor {
  final FormationsToJsonParam param;

  IRestExecutor({required this.param});

  Future<JsonResult> call();
}

class RestExecutor extends IRestExecutor {
  RestExecutor({required super.param});

  @override
  Future<JsonResult> call(
      [ExecutionMode executionMode = ExecutionMode.sync]) async {
    final result = <JsonResult>[];

    final perPage = 10;

    final logger = Logger.standard();

    logger.stdout('start rest executor...');

    var progress = logger
        .progress('peeking total formations of selected $_paramKodeRefPend');

    final totalFormations = await _peekTotalFormations(param.kodePendidikan);

    progress.finish();

    if (totalFormations == null) {
      final message =
          'failed to peek total formations. totalFormations is $totalFormations';

      logger.stderr(message);

      throw Exception(message);
    }

    logger.stdout('total formations peeked: $totalFormations');

    progress = logger.progress('executing in ${executionMode.name} mode');

    switch (executionMode) {
      case ExecutionMode.async:
        final loopCount = (totalFormations / perPage).ceil();

        final offsets = List.generate(loopCount, (index) => index * perPage);

        final formations = await Future.wait(offsets.map((offset) {
          logger.stdout('executing at offset $offset');

          return _getFormationsJson(param.kodePendidikan, offset);
        }));

        result.addAll(formations);
        break;
      case ExecutionMode.sync:
        var offset = 0;

        for (; offset < totalFormations; offset += perPage) {
          logger.stdout('executing at offset $offset');

          final formations =
              await _getFormationsJson(param.kodePendidikan, offset);

          result.add(formations);
        }
        break;
    }

    final finalResult = result.flattenedToList;

    progress.finish(
      message: 'total formations collected: ${finalResult.length} '
          '(${totalFormations / finalResult.length * 100} %)',
      showTiming: true,
    );

    return finalResult;
  }

  final _endPointHeader = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
    'Connection': 'keep-alive',
    'DNT': '1',
    'Host': 'api-sscasn.bkn.go.id',
    'Origin': 'https://sscasn.bkn.go.id',
    'Referer': 'https://sscasn.bkn.go.id/',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-site',
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    'sec-ch-ua':
        '"Not.A/Brand";v="8", "Chromium";v="114", "Google Chrome";v="114"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': "Linux"
  };

  final _endPoint = 'https://api-sscasn.bkn.go.id/2024/portal/spf';
  final _paramKodeRefPend = 'kode_ref_pend';
  final _paramOffset = 'offset';

  Future<Response> _fetchFormations(String kodePendidikan, int offset) {
    final uri = Uri.parse(
        "$_endPoint?$_paramKodeRefPend=$kodePendidikan&$_paramOffset=$offset");

    return get(uri, headers: _endPointHeader);
  }

  Future<int?> _peekTotalFormations(String kodePendidikan) async {
    try {
      final response = await _fetchFormations(kodePendidikan, 0);

      final rawJson = jsonDecode(response.body);

      return rawJson['data']['meta']['total'];
    } catch (e, trace) {
      log('_peekTotalFormations', error: e, stackTrace: trace);

      return null;
    }
  }

  Future<JsonResult> _getFormationsJson(
      String kodePendidikan, int offset) async {
    final response = await _fetchFormations(kodePendidikan, offset);

    final rawJson = jsonDecode(response.body);

    return rawJson['data']['data'];
  }
}
