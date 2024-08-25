import 'package:sscasn_2024_formations_to_json/src/rest_executor.dart';

import 'param.dart';

typedef JsonResult = List<Map>;

abstract class IFormationsToJson {
  final FormationsToJsonParam param;
  final IRestExecutor restExecutor;

  IFormationsToJson({required this.param, required this.restExecutor});

  Future<JsonResult> call();
}

class FormationsToJson extends IFormationsToJson {
  FormationsToJson({
    required super.param,
  }) : super(restExecutor: RestExecutor(param: param));

  @override
  Future<JsonResult> call() {
    return restExecutor();
  }
}
