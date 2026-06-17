import 'package:go_router/go_router.dart';
import '../../presentation/shared/main_scaffold.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(),
    ),
  ],
);
