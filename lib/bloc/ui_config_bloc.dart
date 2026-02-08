import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import '../ui_config.dart';

part 'ui_config_event.dart';
part 'ui_config_state.dart';

// ==================== BLOC ====================

class UiConfigBloc extends Bloc<UiConfigEvent, UiConfigState> {
  final ApiService apiService;
  UiConfig? _lastConfig;

  UiConfigBloc({required this.apiService}) : super(UiConfigInitial()) {
    on<FetchUiConfig>(_onFetchUiConfig);
    on<RefreshUiConfig>(_onRefreshUiConfig);
    on<NavigateToScreen>(_onNavigateToScreen);
  }

  Future<void> _onFetchUiConfig(
      FetchUiConfig event,
      Emitter<UiConfigState> emit,
      ) async {
    emit(UiConfigLoading(previousConfig: _lastConfig));

    try {
      final config = await apiService.fetchUiConfig(
        screen: event.screen,
        params: event.params,
      );

      _lastConfig = config;
      emit(UiConfigLoaded(config: config));

      await apiService.trackEvent(
        eventType: 'screen_view',
        data: {'screen': event.screen},
      );
    } catch (e) {
      emit(UiConfigError(
        message: e.toString(),
        previousConfig: _lastConfig,
      ));
    }
  }

  Future<void> _onRefreshUiConfig(
      RefreshUiConfig event,
      Emitter<UiConfigState> emit,
      ) async {
    try {
      final config = await apiService.fetchUiConfig(screen: event.screen);
      _lastConfig = config;
      emit(UiConfigLoaded(config: config));
    } catch (e) {
      emit(UiConfigError(
        message: e.toString(),
        previousConfig: _lastConfig,
      ));
    }
  }

  Future<void> _onNavigateToScreen(
      NavigateToScreen event,
      Emitter<UiConfigState> emit,
      ) async {
    emit(UiConfigLoading(previousConfig: _lastConfig));

    try {
      final config = await apiService.fetchUiConfig(
        screen: event.screen,
        params: event.params,
      );
      _lastConfig = config;
      emit(UiConfigLoaded(config: config));
    } catch (e) {
      emit(UiConfigError(
        message: e.toString(),
        previousConfig: _lastConfig,
      ));
    }
  }
}