class FormationsToJsonParam {
  final String kodePendidikan;
  final ExecutionMode executionMode;

  FormationsToJsonParam({required this.kodePendidikan, this.executionMode=ExecutionMode.sync});
}

enum ExecutionMode { sync, async }