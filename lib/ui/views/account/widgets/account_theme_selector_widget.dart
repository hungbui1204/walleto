import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class AccountThemeSelectorWidget extends StatelessWidget {
  const AccountThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) =>
          previous.themePreference != current.themePreference ||
          previous.isThemePreferenceSaving != current.isThemePreferenceSaving,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d12.responsive(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.appearance, style: AppTextStyles.s14wNormalBlack()),
              SizedBox(height: Dimens.d8.responsive()),
              Row(
                children: [
                  Expanded(
                    child: _ThemeOption(
                      preference: AppThemePreference.light,
                      label: S.current.lightTheme,
                      icon: Icons.light_mode_outlined,
                      selected: state.themePreference == AppThemePreference.light,
                      enabled: !state.isThemePreferenceSaving,
                    ),
                  ),
                  SizedBox(width: Dimens.d8.responsive()),
                  Expanded(
                    child: _ThemeOption(
                      preference: AppThemePreference.dark,
                      label: S.current.darkTheme,
                      icon: Icons.dark_mode_outlined,
                      selected: state.themePreference == AppThemePreference.dark,
                      enabled: !state.isThemePreferenceSaving,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.preference,
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
  });

  final AppThemePreference preference;
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radius = AppDecorations.chipRadius();

    return Semantics(
      selected: selected,
      child: Pressable(
        semanticLabel: label,
        onTap: selected || !enabled
            ? null
            : () => context.read<AppBloc>().add(AppThemePreferenceSelected(preference: preference)),
        borderRadius: radius,
        child: AnimatedContainer(
          duration: DurationConstants.microInteraction,
          constraints: BoxConstraints(minHeight: Dimens.d48.responsive()),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: Dimens.d10.responsive()),
          decoration: BoxDecoration(
            color: selected ? primaryShadeColor : surfaceColor,
            borderRadius: radius,
            border: Border.all(color: selected ? primaryColor : frameColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: Dimens.d18.responsive(),
                color: selected ? primaryColor : darkGreyColor,
              ),
              SizedBox(width: Dimens.d6.responsive()),
              Text(label, style: AppTextStyles.s14wBoldBlack()),
              if (selected) ...[
                SizedBox(width: Dimens.d4.responsive()),
                Icon(Icons.check, size: Dimens.d14.responsive(), color: primaryColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
