import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/constants/url_constants.dart';
import 'package:walleto/ui/ui.dart';

part 'select_icon_event.dart';
part 'select_icon_state.dart';
part 'select_icon_bloc.freezed.dart';

@injectable
class SelectIconBloc extends BaseBloc<SelectIconEvent, SelectIconState> {
  SelectIconBloc(this._getCategoryImagesUseCase) : super(const SelectIconState()) {
    on<SelectIconViewInitialized>(_onSelectIconViewInitialized);
  }

  final GetCategoryImagesUseCase _getCategoryImagesUseCase;

  Future<void> _onSelectIconViewInitialized(
    SelectIconViewInitialized event,
    Emitter<SelectIconState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        switch (event.iconType) {
          case IconType.wallet:
          // TODO: Fetch wallet icons

          case IconType.category:
            // Fetch category icons
            final output = await _getCategoryImagesUseCase.execute(const GetCategoryImagesInput());
            final icons =
                output.images.map((e) {
                  return e.copyWith(url: UrlConstants.categoryImageUrl(e.name ?? ''));
                }).toList();
            emit(state.copyWith(icons: icons));
        }
      },
    );
  }
}
