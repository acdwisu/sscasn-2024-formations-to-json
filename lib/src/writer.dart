import 'dart:convert';
import 'dart:io';

import 'package:sscasn_2024_formations_to_json/src/converter/converter.dart';
import 'package:sscasn_2024_formations_to_json/src/converter/formation_to_json.dart';

abstract class Writer {
  final JsonResult result;
  final FormationsToJsonParam param;
  final String writeDestinationDir;

  Writer({required this.result, required this.param, required this.writeDestinationDir});

  Future<void> call();
}

class JsonFileWriter extends Writer {
  JsonFileWriter({required super.result, required super.param, required super.writeDestinationDir});

  @override
  Future<void> call() {
    final dir = File(writeDestinationDir);

    return File(_getCorrectFileName("$writeDestinationDir/${param.kodePendidikan}", 'json'))
        .writeAsString(jsonEncode(result));
  }

  String _getCorrectFileName(String fileName, String fileExtension) {
    int numbering = 1;

    var finalFilaName = '$fileName.$fileExtension';

    while(File(finalFilaName).existsSync()) {
      finalFilaName = "$fileName (${numbering++}).$fileExtension";
    }

    return finalFilaName;
  }
}