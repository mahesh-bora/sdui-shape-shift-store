import 'action_config.dart';

class ComponentConfig {
  final String id;
  final String type;
  final Map<String, dynamic> props;
  final Map<String, dynamic>? style;
  final ActionConfig? action;
  final List<ComponentConfig>? children;

  ComponentConfig({
    required this.id,
    required this.type,
    required this.props,
    this.style,
    this.action,
    this.children,
  });

  factory ComponentConfig.fromJson(Map<String, dynamic> json) {
    return ComponentConfig(
      id: json['id'] ?? '',
      type: json['type'] ?? 'container',
      props: json['props'] ?? {},
      style: json['style'],
      action: json['action'] != null
          ? ActionConfig.fromJson(json['action'])
          : null,
      children: (json['children'] as List?)
          ?.map((c) => ComponentConfig.fromJson(c))
          .toList(),
    );
  }
}