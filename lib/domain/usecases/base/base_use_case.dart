import 'package:flutter/foundation.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

abstract class BaseUseCase<Input extends BaseInput, Output> with LogMixin {
  const BaseUseCase();

  @protected
  Output buildUseCase(Input input);
}
