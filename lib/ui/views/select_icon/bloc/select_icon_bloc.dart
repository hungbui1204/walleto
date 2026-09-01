import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'select_icon_event.dart';
part 'select_icon_state.dart';
part 'select_icon_bloc.freezed.dart';

@injectable
class SelectIconBloc extends BaseBloc<SelectIconEvent, SelectIconState> {
  SelectIconBloc(this._getCategoryImagesUseCase, this._getWalletImagesUseCase)
    : super(const SelectIconState()) {
    on<SelectIconViewInitialized>(_onSelectIconViewInitialized, transformer: log());
  }

  final GetCategoryImagesUseCase _getCategoryImagesUseCase;
  final GetWalletImagesUseCase _getWalletImagesUseCase;

  Future<void> _onSelectIconViewInitialized(
    SelectIconViewInitialized event,
    Emitter<SelectIconState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        switch (event.iconType) {
          case IconType.wallet:
            // Fetch wallet icons
            final output = await _getWalletImagesUseCase.execute(const GetWalletImagesInput());
            final icons =
                output.images.map((e) {
                  return e.copyWith(
                    url: UrlConstants.imageUrl(path: e.name ?? '', bucket: 'wallet-images'),
                  );
                }).toList();
            emit(state.copyWith(icons: icons));
            break;

          case IconType.category:
            // Fetch category icons
            final output = await _getCategoryImagesUseCase.execute(const GetCategoryImagesInput());
            final icons =
                output.images.map((e) {
                  return e.copyWith(
                    url: UrlConstants.imageUrl(path: e.name ?? '', bucket: 'category-images'),
                  );
                }).toList();
            emit(state.copyWith(icons: icons));
        }
      },
    );
  }
}
