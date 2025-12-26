import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:home_widget/home_widget.dart";

import "core/theme/app_theme.dart";
import "features/home/home_screen.dart";
import "features/reveal/reveal_screen.dart";
import "providers/router_provider.dart";

class PetalPostApp extends ConsumerStatefulWidget {
  const PetalPostApp({super.key});

  @override
  ConsumerState<PetalPostApp> createState() => _PetalPostAppState();
}

class _PetalPostAppState extends ConsumerState<PetalPostApp> {
  @override
  void initState() {
    super.initState();
    _bindWidgetClicks();
  }

  Future<void> _bindWidgetClicks() async {
    final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
    _handleWidgetUri(initial);
    HomeWidget.widgetClicked.listen(_handleWidgetUri);
  }

  void _handleWidgetUri(Uri? uri) {
    if (uri == null) return;
    final router = ref.read(goRouterProvider);
    final target = uri.path.isNotEmpty ? uri.path : uri.host;
    if (target.contains("reveal")) {
      router.go(RevealScreen.routePath);
    } else {
      router.go(HomeScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "PetalPost",
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
