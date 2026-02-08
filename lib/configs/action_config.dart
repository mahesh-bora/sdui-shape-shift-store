class ActionConfig {
  final String type;
  final String? route;
  final Map<String, dynamic>? params;
  final String? url;
  final String? modalContent;

  ActionConfig({
    required this.type,
    this.route,
    this.params,
    this.url,
    this.modalContent,
  });

  factory ActionConfig.fromJson(Map<String, dynamic> json) {
    return ActionConfig(
      type: json['type'] ?? 'navigate',
      route: json['route'],
      params: json['params'],
      url: json['url'],
      modalContent: json['modal_content'],
    );
  }
}