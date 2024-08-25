import 'package:sscasn_2024_formations_to_json/src/converter/converter.dart';
import 'package:sscasn_2024_formations_to_json/src/converter/param.dart';

abstract class IRestExecutor {
  final FormationsToJsonParam param;

  IRestExecutor({required this.param});

  Future<JsonResult> call();
}

class RestExecutor extends IRestExecutor {
  @override
  Future<JsonResult> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}
