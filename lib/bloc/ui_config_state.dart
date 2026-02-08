part of 'ui_config_bloc.dart';

abstract class UiConfigState {}

class UiConfigInitial extends UiConfigState {}

class UiConfigLoading extends UiConfigState {
  final UiConfig? previousConfig;

  UiConfigLoading({this.previousConfig});
}

class UiConfigLoaded extends UiConfigState {
  final UiConfig config;
  final DateTime loadedAt;

  UiConfigLoaded({
    required this.config,
    DateTime? loadedAt,
  }) : loadedAt = loadedAt ?? DateTime.now();
}

class UiConfigError extends UiConfigState {
  final String message;
  final UiConfig? previousConfig;

  UiConfigError({
    required this.message,
    this.previousConfig,
  });
}
