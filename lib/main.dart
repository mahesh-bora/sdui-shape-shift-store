import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:server_side_ui/screens/sdui_screen.dart';
import 'bloc/ui_config_bloc.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ShapeShiftingStoreApp());
}

class ShapeShiftingStoreApp extends StatelessWidget {
  const ShapeShiftingStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UiConfigBloc(
        apiService: ApiService(),
      ),
      child: BlocBuilder<UiConfigBloc, UiConfigState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Shape-Shifting Store',
            theme: _buildTheme(state, false),
            darkTheme: _buildTheme(state, true),
            themeMode: _getThemeMode(state),
            debugShowCheckedModeBanner: false,

            // Named routes generated from server
            onGenerateRoute: (settings) {
              print('🧭 Navigating to: ${settings.name}');
              return MaterialPageRoute(
                builder: (context) => SduiScreen(
                  routeName: settings.name ?? '/',
                ),
                settings: settings,
              );
            },

            initialRoute: '/',
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(UiConfigState state) {
    if (state is UiConfigLoaded) {
      return state.config.theme.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
    }
    return ThemeMode.system;
  }

  ThemeData _buildTheme(UiConfigState state, bool isDark) {
    if (state is UiConfigLoaded) {
      final theme = state.config.theme;
      final primaryColor = _parseColor(theme.primaryColor);
      final backgroundColor = _parseColor(theme.backgroundColor);
      final accentColor = _parseColor(theme.accentColor);

      return ThemeData(
        brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
          secondary: accentColor,
        ),

        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: theme.fontSizes['headline'] ?? 32,
            fontWeight: FontWeight.bold,
            color: theme.isDarkMode ? Colors.white : Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: theme.fontSizes['title'] ?? 24,
            fontWeight: FontWeight.bold,
            color: theme.isDarkMode ? Colors.white : Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: theme.fontSizes['body'] ?? 16,
            color: theme.isDarkMode ? Colors.white : Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: theme.fontSizes['body'] ?? 16,
            color: theme.isDarkMode ? Colors.white70 : Colors.black87,
          ),
          labelSmall: TextStyle(
            fontSize: theme.fontSizes['caption'] ?? 12,
            color: theme.isDarkMode ? Colors.white60 : Colors.black54,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: theme.isDarkMode ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(theme.borderRadius / 2),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing['lg'] ?? 24,
              vertical: theme.spacing['md'] ?? 16,
            ),
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: theme.isDarkMode ? Colors.white : Colors.black,
          elevation: 0,
          centerTitle: false,
        ),

        useMaterial3: true,
      );
    }

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }
}