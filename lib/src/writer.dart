import 'package:sscasn_2024_formations_to_json/src/converter/converter.dart';

abstract class Writer {
  final JsonResult result;

  Writer({required this.result});

  Future<void> call();
}
