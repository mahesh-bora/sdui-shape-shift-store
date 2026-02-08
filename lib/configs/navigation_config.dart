class NavigationConfig {
  final List<NavItem> bottomNav;
  final List<NavItem> topActions;
  final bool showBackButton;
  final String? title;

  NavigationConfig({
    required this.bottomNav,
    required this.topActions,
    required this.showBackButton,
    this.title,
  });

  factory NavigationConfig.fromJson(Map<String, dynamic> json) {
    return NavigationConfig(
      bottomNav: (json['bottom_nav'] as List?)
          ?.map((n) => NavItem.fromJson(n))
          .toList() ??
          [],
      topActions: (json['top_actions'] as List?)
          ?.map((n) => NavItem.fromJson(n))
          .toList() ??
          [],
      showBackButton: json['show_back_button'] ?? false,
      title: json['title'],
    );
  }
}

class NavItem {
  final String id;
  final String label;
  final String icon;
  final String route;
  final bool isActive;

  NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    required this.isActive,
  });

  factory NavItem.fromJson(Map<String, dynamic> json) {
    return NavItem(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? 'home',
      route: json['route'] ?? '/',
      isActive: json['is_active'] ?? false,
    );
  }
}