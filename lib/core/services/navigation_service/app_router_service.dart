import 'package:auto_route/auto_route.dart';
import 'package:nyaa_si_mobile/core/services/navigation_service/app_router_service.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: HomeRoute.page, initial: true),
  ];
}
