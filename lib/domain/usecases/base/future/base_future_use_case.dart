import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

abstract class BaseFutureUseCase<Input extends BaseInput, Output extends BaseOutput>
    extends BaseUseCase<Input, Future<Output>> {
  const BaseFutureUseCase();

  Future<Output> execute(Input input) async {
    try {
      if (LogConfig.enableLogUseCaseInput) {
        logD('FutureUseCase Input: ${input.runtimeType}');
      }
      final output = await buildUseCase(input);
      if (LogConfig.enableLogUseCaseOutput) {
        logD('FutureUseCase Output: ${output.runtimeType}');
      }

      return output;
    } catch (e) {
      if (LogConfig.enableLogUseCaseError) {
        logE('FutureUseCase Error: ${e.runtimeType}');
      }

      throw e is AppException ? e : AppUncaughtException(e);
    }
  }
}
