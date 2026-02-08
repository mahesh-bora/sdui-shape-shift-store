import 'dart:convert';

import 'configs/component_config.dart';
import 'configs/navigation_config.dart';
import 'configs/theme_config.dart';

/// Main UI Configuration from server
class UiConfig {
  final String screenId;
  final String layoutType;
  final ThemeConfig theme;
  final List<ComponentConfig> components;
  final NavigationConfig navigation;
  final Map<String, dynamic>? animations;
  final Map<String, dynamic>? metadata;

  UiConfig({
    required this.screenId,
    required this.layoutType,
    required this.theme,
    required this.components,
    required this.navigation,
    this.animations,
    this.metadata,
  });

  factory UiConfig.fromJson(Map<String, dynamic> json) {
    return UiConfig(
      screenId: json['screen_id'] ?? '',
      layoutType: json['layout_type'] ?? 'list',
      theme: ThemeConfig.fromJson(json['theme'] ?? {}),
      components: (json['components'] as List?)
          ?.map((c) => ComponentConfig.fromJson(c))
          .toList() ??
          [],
      navigation: NavigationConfig.fromJson(json['navigation'] ?? {}),
      animations: json['animations'],
      metadata: json['metadata'],
    );
  }
}











