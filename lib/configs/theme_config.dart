class ThemeConfig {
  final bool isDarkMode;
  final String primaryColor;
  final String backgroundColor;
  final String accentColor;
  final Map<String, double> fontSizes;
  final Map<String, String> fontWeights;
  final double borderRadius;
  final Map<String, double> spacing;

  ThemeConfig({
    required this.isDarkMode,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.fontSizes,
    required this.fontWeights,
    required this.borderRadius,
    required this.spacing,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    // Convert all numeric values to double
    final fontSizesJson = json['font_sizes'] ?? {
      'headline': 32.0,
      'title': 24.0,
      'body': 16.0,
      'caption': 12.0,
    };

    final spacingJson = json['spacing'] ?? {
      'xs': 4.0,
      'sm': 8.0,
      'md': 16.0,
      'lg': 24.0,
      'xl': 32.0,
    };

    final Map<String, double> fontSizes = {};
    fontSizesJson.forEach((key, value) {
      if (value is num) {
        fontSizes[key] = value.toDouble();
      }
    });

    final Map<String, double> spacing = {};
    spacingJson.forEach((key, value) {
      if (value is num) {
        spacing[key] = value.toDouble();
      }
    });

    return ThemeConfig(
      isDarkMode: json['is_dark_mode'] ?? false,
      primaryColor: json['primary_color'] ?? '#000000',
      backgroundColor: json['background_color'] ?? '#FFFFFF',
      accentColor: json['accent_color'] ?? '#0000FF',
      fontSizes: fontSizes,
      fontWeights: Map<String, String>.from(json['font_weights'] ?? {}),
      borderRadius: (json['border_radius'] as num?)?.toDouble() ?? 8.0,
      spacing: spacing,
    );
  }
}