import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

abstract class BaseLoadMoreUseCase<Input extends BaseInput, Output>
    extends BaseUseCase<Input, Future<PagedList<Output>>> {
  BaseLoadMoreUseCase({
    this.initPage = PagingConstants.initialPage,
    this.initOffset = 0,
  })  : _output = LoadMoreOutput<Output>(
          data: <Output>[],
          key: '',
          page: initPage,
          offset: initOffset,
        ),
        _oldOutput = LoadMoreOutput<Output>(
          data: <Output>[],
          key: '',
          page: initPage,
          offset: initOffset,
        );

  final int initPage;
  final int initOffset;

  LoadMoreOutput<Output> _output;
  LoadMoreOutput<Output> _oldOutput;

  int get page => _output.page;
  int get offset => _output.offset;
  String? get key => _output.key;

  Future<LoadMoreOutput<Output>> execute(Input input, bool isInitialLoad) async {
    try {
      if (isInitialLoad) {
        _output = LoadMoreOutput<Output>(data: <Output>[]);
      }
      if (LogConfig.enableLogUseCaseInput) {
        logD('LoadMoreUseCase Input: $input');
      }
      final pagedList = await buildUseCase(input);

      final newOutput = _oldOutput.copyWith(
        data: pagedList.data,
        otherData: pagedList.otherData,
        key: pagedList.key,
        page: isInitialLoad
            ? initPage + (pagedList.data.isNotEmpty ? 1 : 0)
            : _oldOutput.page + (pagedList.data.isNotEmpty ? 1 : 0),
        offset: isInitialLoad
            ? (initOffset + pagedList.data.length)
            : _oldOutput.offset + pagedList.data.length,
        isLastPage: pagedList.isLastPage,
        isRefreshSuccess: isInitialLoad,
      );

      _output = newOutput;
      _oldOutput = newOutput;
      if (LogConfig.enableLogUseCaseOutput) {
        logD('LoadMoreUseCase Output: pagedList: $pagedList, newOutput: $newOutput');
      }

      return newOutput;
    } catch (e) {
      if (LogConfig.enableLogUseCaseError) {
        logE('FutureUseCase Error: $e');
      }
      _output = _oldOutput;

      throw e is AppException ? e : AppUncaughtException(e);
    }
  }
}
