part of 'ui_config_bloc.dart';


abstract class UiConfigEvent {}

class FetchUiConfig extends UiConfigEvent {
  final String screen;
  final Map<String, dynamic>? params;

  FetchUiConfig({required this.screen, this.params});
}

class RefreshUiConfig extends UiConfigEvent {
  final String screen;

  RefreshUiConfig({required this.screen});
}

class NavigateToScreen extends UiConfigEvent {
  final String screen;
  final Map<String, dynamic>? params;

  NavigateToScreen({required this.screen, this.params});
}
