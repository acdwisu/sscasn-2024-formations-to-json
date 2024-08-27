import 'dart:io';
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';

import 'package:sscasn_2024_formations_to_json/sscasn_2024_formations_to_json.dart' as sscasn_2024_formations_to_json;

void main(List<String> arguments) async {
  const helpArg = 'help';
  const kodePendidikanArg = 'kode_pendidikan';
  const isSyncExecutionModeArg = 'is_in_sync_execution_mode';
  const writeDestinationDirArg = 'write_destination_dir';

  final parser = ArgParser()..addFlag(helpArg, abbr: 'h', help: 'Help', negatable: false)
    ..addOption(kodePendidikanArg, abbr: 'k', help: 'Kode Pendidikan', mandatory: true)
    ..addFlag(isSyncExecutionModeArg, abbr: 's', help: 'is Sync Execution Mode', negatable: false, defaultsTo: false)
    ..addOption(writeDestinationDirArg, abbr: 'w', help: 'Write Destination Directory', mandatory: false)
  ;

  final logger = Logger.verbose();

  final argResults = parser.parse(arguments);

  if(argResults.flag(helpArg)) {
    print(parser.usage);

    exit(0);
  }

  final kodePendidikan = argResults.option(kodePendidikanArg);

  if(kodePendidikan==null) {
    exitCode = 2;

    logger.stderr('please specify $kodePendidikanArg');

    exit(2);
  }

  final param = sscasn_2024_formations_to_json.FormationsToJsonParam(
      kodePendidikan: kodePendidikan,
      executionMode: argResults.flag(isSyncExecutionModeArg)? sscasn_2024_formations_to_json.ExecutionMode.sync
          : sscasn_2024_formations_to_json.ExecutionMode.async
  );

  var progress = logger.progress('Converting formations to json');

  final json = await sscasn_2024_formations_to_json.FormationsToJson(
    param: param
  )();

  progress.finish(
    message: 'Done converting formations to json',
    showTiming: true
  );

  final writeDestinationDir = argResults.option(writeDestinationDirArg);

  if(writeDestinationDir==null) {
    exit(0);
  }

  if(writeDestinationDir.isEmpty) {
    logger.stderr("$writeDestinationDir is empty");

    exit(1);
  }

  progress = logger.progress('Writing to json file');

  await sscasn_2024_formations_to_json.JsonFileWriter(
    param: param,
    result: json,
    writeDestinationDir: writeDestinationDir,
  )();

  progress.finish(
    message: 'Done writing to json file',
    showTiming: true,
  );
}
