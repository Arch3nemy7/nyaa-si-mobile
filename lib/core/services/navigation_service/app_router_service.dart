import 'package:auto_route/auto_route.dart';

import 'app_router_service.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: DownloadedTorrentHomeRoute.page),
    AutoRoute(page: ReleaseGroupDetailsRoute.page),
  ];
}
