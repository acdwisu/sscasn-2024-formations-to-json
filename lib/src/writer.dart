import 'dart:convert';
import 'dart:io';

import 'package:sscasn_2024_formations_to_json/src/converter/converter.dart';

abstract class Writer {
  final JsonResult result;
  final String writeDestination;

  Writer({required this.result, required this.writeDestination});

  Future<void> call();
}

class DatFileWriter extends Writer {
  DatFileWriter({required super.result, required super.writeDestination});

  @override
  Future<void> call() {
    return File(writeDestination).writeAsString(jsonEncode(result));
  }
}