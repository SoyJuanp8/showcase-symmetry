import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.dark)) {
    // Default to dark as it's the current "Premium" look
    on<ToggleTheme>((event, emit) {
      if (state.themeMode == ThemeMode.dark) {
        emit(const ThemeState(ThemeMode.light));
      } else {
        emit(const ThemeState(ThemeMode.dark));
      }
    });
  }
}
