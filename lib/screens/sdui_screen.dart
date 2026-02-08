import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:server_side_ui/screens/sdui_widget_builder.dart';
import '../bloc/ui_config_bloc.dart';
import '../ui_config.dart';

class SduiScreen extends StatefulWidget {
  final String routeName;

  const SduiScreen({super.key, required this.routeName});

  @override
  State<SduiScreen> createState() => _SduiScreenState();
}

class _SduiScreenState extends State<SduiScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UiConfigBloc>().add(FetchUiConfig(screen: widget.routeName));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UiConfigBloc, UiConfigState>(
      listener: (context, state) {
        if (state is UiConfigError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading UI: ${state.message}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  context.read<UiConfigBloc>().add(
                    RefreshUiConfig(screen: widget.routeName),
                  );
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is UiConfigLoading) {
          if (state.previousConfig != null) {
            return _buildScaffold(context, state.previousConfig!);
          }
          return _buildLoadingScreen();
        }

        if (state is UiConfigLoaded) {
          return _buildScaffold(context, state.config);
        }

        if (state is UiConfigError && state.previousConfig != null) {
          return _buildScaffold(context, state.previousConfig!);
        }

        return _buildErrorScreen();
      },
    );
  }

  Widget _buildScaffold(BuildContext context, UiConfig config) {
    final widgetBuilder = SduiWidgetBuilder(context);

    return Scaffold(
      appBar: _buildAppBar(config),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<UiConfigBloc>().add(
            RefreshUiConfig(screen: widget.routeName),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: _buildBody(widgetBuilder, config),
      ),
      bottomNavigationBar: _buildBottomNav(config),
    );
  }

  PreferredSizeWidget? _buildAppBar(UiConfig config) {
    final nav = config.navigation;

    if (nav.title == null && nav.topActions.isEmpty && !nav.showBackButton) {
      return null;
    }

    return AppBar(
      title: nav.title != null ? Text(nav.title!) : null,
      automaticallyImplyLeading: nav.showBackButton,
      actions: nav.topActions.map((action) {
        return IconButton(
          icon: _getIcon(action.icon),
          onPressed: () {
            context.read<UiConfigBloc>().add(
              NavigateToScreen(screen: action.route),
            );
          },
        );
      }).toList(),
      backgroundColor: _parseColor(config.theme.primaryColor),
      foregroundColor: config.theme.isDarkMode ? Colors.white : Colors.black,
    );
  }

  Widget _buildBody(SduiWidgetBuilder builder, UiConfig config) {
    if (config.components.isEmpty) {
      return const Center(child: Text('No content available'));
    }

    switch (config.layoutType) {
      case 'scroll':
      case 'list':
        return SingleChildScrollView(
          child: Column(
            children: config.components
                .map((component) => builder.buildComponent(component))
                .toList(),
          ),
        );

      case 'grid':
        return GridView.builder(
          padding: EdgeInsets.all(config.theme.spacing['md'] ?? 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: config.components.length,
          itemBuilder: (context, index) {
            return builder.buildComponent(config.components[index]);
          },
        );

      case 'hero':
        return SingleChildScrollView(
          child: Column(
            children: [
              if (config.components.isNotEmpty)
                SizedBox(
                  height: 400,
                  child: builder.buildComponent(config.components.first),
                ),
              ...config.components
                  .skip(1)
                  .map((component) => builder.buildComponent(component)),
            ],
          ),
        );

      default:
        return SingleChildScrollView(
          child: Column(
            children: config.components
                .map((component) => builder.buildComponent(component))
                .toList(),
          ),
        );
    }
  }

  Widget? _buildBottomNav(UiConfig config) {
    final bottomNav = config.navigation.bottomNav;

    if (bottomNav.isEmpty) return null;

    final currentIndex = bottomNav.indexWhere((item) => item.isActive);

    return BottomNavigationBar(
      currentIndex: currentIndex >= 0 ? currentIndex : 0,
      onTap: (index) {
        final item = bottomNav[index];
        context.read<UiConfigBloc>().add(NavigateToScreen(screen: item.route));
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _parseColor(config.theme.primaryColor),
      unselectedItemColor: Colors.grey,
      items: bottomNav.map((item) {
        return BottomNavigationBarItem(
          icon: _getIcon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading experience...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load UI'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<UiConfigBloc>().add(
                  FetchUiConfig(screen: widget.routeName),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getIcon(String iconName) {
    switch (iconName) {
      case 'home':
        return const Icon(Icons.home);
      case 'search':
        return const Icon(Icons.search);
      case 'favorite':
      case 'heart':
        return const Icon(Icons.favorite);
      case 'cart':
      case 'shopping_cart':
        return const Icon(Icons.shopping_cart);
      case 'profile':
      case 'person':
        return const Icon(Icons.person);
      case 'settings':
        return const Icon(Icons.settings);
      case 'notifications':
        return const Icon(Icons.notifications);
      default:
        return const Icon(Icons.circle);
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }
}
