# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter mobile client for [nyaa.si](https://nyaa.si). There is no public API — torrent listings are obtained by scraping the rendered HTML, so any data-source change typically means updating CSS selectors and the row-parsing logic, not a JSON contract.

Android is the only supported runtime today: downloads are written under a hard-coded `/storage/emulated/0/Download/Nyaa/[ReleaseGroup]/` path, and the local provider throws `Unsupported platform` for anything else. iOS scaffolding exists but the data layer does not work there.

## Common commands

```bash
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device/emulator (debug)
flutter run --release              # Release build
flutter build apk                  # Build Android APK
flutter analyze                    # Static analysis — strict; lints are tight
dart format .                      # Format
flutter clean                      # Wipe build artifacts
```

Code generation (auto_route routes, Hive type adapters) — required after editing routes in [lib/core/services/navigation_service/app_router_service.dart](lib/core/services/navigation_service/app_router_service.dart) or any `@HiveType` model:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # rebuild on save
```

Generated files (`*.g.dart`, `*.gr.dart`, `*.freezed.dart`) are excluded from the analyzer — never hand-edit them.

There is **no `test/` directory and no test commands**. Don't claim work is verified by tests; either run the app or say verification was not performed.

## Architecture

Clean Architecture split into four layers under [lib/](lib/). Dependencies point inward: `presentation → domain ← data`, with `core` shared by all.

- **[lib/domain/](lib/domain/)** — pure Dart. `entities/` are framework-agnostic value types, `repositories/` are abstract contracts, `usecases/` are thin callables (`call(...)`) that the BLoCs invoke. Domain code must not import from `data/` or `presentation/`.
- **[lib/data/](lib/data/)** — concrete implementations. `models/` extend entities with serialization (e.g. Hive annotations); `providers/` are split into `remote/` (HTTP scraping via Dio) and `local/` (filesystem/Hive), each with an `interfaces/` abstract type and an `implements/` concrete class registered by interface in DI; `repositories/` compose providers and map models → entities.
- **[lib/presentation/](lib/presentation/)** — `blocs/` (one folder per feature, with `_bloc.dart` + `part` files for events/state), `pages/` (`@RoutePage()`-annotated widgets), `widgets/`. BLoCs pull their dependencies from `serviceLocator` directly in their constructor (see [torrent_list_bloc.dart:22-24](lib/presentation/blocs/torrent_list/torrent_list_bloc.dart#L22-L24)) rather than receiving them as parameters.
- **[lib/core/](lib/core/)** — cross-cutting: `services/network_service/` (DioClient + ApiConfig + interceptors), `services/navigation_service/` (auto_route), `constants/` (color tokens, endpoints), `exceptions/`.

### Dependency injection

All wiring lives in [lib/presentation/dependency_injection.dart](lib/presentation/dependency_injection.dart), called once from `main()` before `runApp`. The order is fixed: network → providers → repositories → usecases. `ApiConfig` branches on `kReleaseMode` to pick `.production()` vs `.development()` (development just uses longer timeouts; both point at `https://nyaa.si`). When adding a new feature, register **against the interface** (`registerFactory<IFoo>(() => FooImpl(...))`), matching the pattern used for `IRemoteTorrentsProvider` and `IDownloadedTorrentProvider`.

### Navigation

`auto_route` with code generation. New pages need `@RoutePage()` on the widget class and an entry in `AppRouter.routes` in [app_router_service.dart](lib/core/services/navigation_service/app_router_service.dart) — then re-run `build_runner` to regenerate `app_router_service.gr.dart`.

### State management

`flutter_bloc` with `equatable`. State classes carry the full filter/sort/search context (`searchQuery`, `filterStatus`, `filterCategory`, `sortField`, `sortOrder`) so that error and loading states can be re-emitted without losing the user's query — see how every handler in [torrent_list_bloc.dart](lib/presentation/blocs/torrent_list/torrent_list_bloc.dart) threads these fields through. When adding a new event that changes one of these, follow the same pattern: read from `currentState`, fall back to the `_default…` constants, emit a loading state that preserves context, then a loaded state with the new value.

### Remote data: HTML scraping

[RemoteTorrentsProviderImpl](lib/data/providers/remote/implements/remote_torrents_provider.dart) GETs nyaa.si and parses `table.torrent-list tbody tr` rows. The fragile bit is `_parseTorrentRowToJson` and its `_extract*` helpers — if nyaa.si tweaks markup, parsing silently degrades (empty IDs, null release groups). Release groups are pulled from a `^\[(...)\]` prefix on the torrent name; the same regex is used in two places (parsing and download dir naming) so changes need to land together.

### Local data: downloads on the filesystem

The "downloaded torrents" list is not a database — it's a recursive scan of `/storage/emulated/0/Download/Nyaa/`. IDs are derived from `filePath.hashCode.abs().toString()` ([local_downloaded_torrent_provider.dart:80-81](lib/data/providers/local/implements/local_downloaded_torrent_provider.dart#L80-L81)), so a file's "id" changes if it's moved or renamed. The release group is inferred from the directory name one level below `Nyaa/`. Hive is declared as a dependency and `DownloadedTorrentModel` is annotated `@HiveType`, but no box is opened — current persistence is purely file-based; the Hive setup is wired for future use.

### Permissions

Android storage permissions are requested lazily inside `RemoteTorrentsProviderImpl.downloadTorrent` (tries `manageExternalStorage` first, falls back to `storage`). No permission setup happens in `main()`.

## Conventions enforced by the analyzer

[analysis_options.yaml](analysis_options.yaml) enables `strict-casts`, `strict-inference`, `strict-raw-types`, plus `always_specify_types`, `require_trailing_commas`, `prefer_single_quotes`, `prefer_const_constructors`, `avoid_print`. Existing code uses explicit type annotations on locals (`final List<NyaaTorrentEntity> torrents = …`, not `final torrents = …`) — match that style or `flutter analyze` will fail.

`pubspec.yaml` pins `dependency_overrides: source_gen: ^2.0.0` to keep `auto_route_generator` and `hive_generator` compatible; don't remove that override without testing both generators.
