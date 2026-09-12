import 'dart:async';

import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

abstract class BaseStreamUseCase<Input extends BaseInput, Output extends BaseOutput>
    extends BaseUseCase<Input, Stream<Output>> {
  const BaseStreamUseCase();

  Stream<Output> execute(Input input) async* {
    try {
      if (LogConfig.enableLogUseCaseInput) {
        logD('StreamUseCase Input: $input');
      }

      await for (final output in buildUseCase(input)) {
        yield output;
      }
    } catch (e) {
      if (LogConfig.enableLogUseCaseError) {
        logE('StreamUseCase Error: $e');
      }

      throw e is AppException ? e : AppUncaughtException(e);
    }
  }
}
