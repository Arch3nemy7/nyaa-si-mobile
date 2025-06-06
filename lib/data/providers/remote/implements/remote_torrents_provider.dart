import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/network_service/dio_client.dart';
import '../../../models/nyaa_torrent_model.dart';
import '../interfaces/i_torrents_provider.dart';

class RemoteTorrentsProviderImpl implements IRemoteTorrentsProvider {
  RemoteTorrentsProviderImpl(this.dioClient);
  final DioClient dioClient;

  @override
  Future<List<NyaaTorrentModel>> getTorrents({
    required int page,
    required int pageSize,
    required String filterStatus,
    required String filterCategory,
    required String searchQuery,
    required String sortField,
    required String sortOrder,
  }) async {
    try {
      final Response<dynamic> response = await dioClient.get(
        '',
        queryParameters: _buildQueryParams(
          page: page,
          searchQuery: searchQuery,
          filterStatus: filterStatus,
          filterCategory: filterCategory,
          sortField: sortField,
          sortOrder: sortOrder,
        ),
      );

      final Document document = html_parser.parse(response.data.toString());
      final List<Element> rows = document.querySelectorAll(
        'table.torrent-list tbody tr',
      );

      return rows
          .map(_parseTorrentRowToJson)
          .map((Map<String, dynamic> json) => NyaaTorrentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch torrents: $e');
    }
  }

  @override
  Future<String> downloadTorrent({
    required String torrentId,
    String? releaseGroup,
  }) async {
    try {
      final bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission is required to download files');
      }

      final Response<dynamic> response = await dioClient.get(
        '/download/$torrentId.torrent',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('${response.statusCode}');
      }

      final Uint8List bytes = response.data as Uint8List;
      final String fileName = _extractFileName(response.headers, torrentId);
      final String filePath = await _saveToDownloads(
        bytes,
        fileName,
        releaseGroup,
      );

      return filePath;
    } catch (e) {
      throw Exception('Failed to download torrent: $e');
    }
  }

  Map<String, dynamic> _buildQueryParams({
    required int page,
    required String searchQuery,
    required String filterStatus,
    required String filterCategory,
    required String sortField,
    required String sortOrder,
  }) {
    final Map<String, dynamic> params = <String, dynamic>{};
    if (page > 1) params['p'] = page.toString();
    if (searchQuery.isNotEmpty) params['q'] = searchQuery;
    if (filterStatus != '0') params['f'] = filterStatus;
    if (filterCategory != '0_0') params['c'] = filterCategory;
    if (sortField != 'id') params['s'] = sortField;
    if (sortOrder != 'desc') params['o'] = sortOrder;
    return params;
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.status.isDenied) {
        final PermissionStatus status =
            await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          return true;
        }
      } else if (await Permission.manageExternalStorage.status.isGranted) {
        return true;
      }

      if (await Permission.storage.status.isDenied) {
        final PermissionStatus status = await Permission.storage.request();
        return status.isGranted;
      } else if (await Permission.storage.status.isGranted) {
        return true;
      }

      return false;
    }
    return true;
  }

  String _extractFileName(Headers headers, String torrentId) {
    final String? contentDisposition = headers.value('content-disposition');
    if (contentDisposition != null) {
      final RegExpMatch? match = RegExp(
        r'''filename\*?=(?:UTF-8'')?["']?([^"';\r\n]+)["']?''',
      ).firstMatch(contentDisposition);
      if (match != null) {
        return Uri.decodeFull(match.group(1)!);
      }
    }
    return '$torrentId.torrent';
  }

  Future<String> _saveToDownloads(
    Uint8List bytes,
    String fileName,
    String? releaseGroup,
  ) async {
    Directory directory;

    try {
      directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final Directory nyaaDir = Directory('${directory.path}/Nyaa');
      if (!await nyaaDir.exists()) {
        await nyaaDir.create(recursive: true);
      }

      String subDirName;
      if (releaseGroup != null && releaseGroup.isNotEmpty) {
        final String sanitizedReleaseGroup = _sanitizeDirectoryName(
          releaseGroup,
        );
        subDirName = '[$sanitizedReleaseGroup]';
      } else {
        subDirName = 'Unknown';
      }

      final Directory subDir = Directory('${nyaaDir.path}/$subDirName');
      if (!await subDir.exists()) {
        await subDir.create(recursive: true);
      }
      directory = subDir;
    } catch (e) {
      throw Exception('$e');
    }

    final File file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Map<String, dynamic> _parseTorrentRowToJson(Element row) {
    final List<Element> cells = row.querySelectorAll('td');
    if (cells.length < 8) throw Exception('Invalid torrent row structure');

    return <String, dynamic>{
      'id': _extractTorrentId(cells[1]),
      'category': _extractCategory(cells[0]),
      'categoryImage': _extractCategoryImage(cells[0]),
      'name': _extractTorrentName(cells[1]),
      'releaseGroup': _extractReleaseGroup(cells[1]),
      'link': _extractTorrentLink(cells[1]),
      'comments': _extractComments(cells[1]),
      'torrentLink': _extractDownloadLink(cells[2]),
      'magnetLink': _extractMagnetLink(cells[2]),
      'size': cells[3].text.trim(),
      'date': cells[4].text.trim(),
      'timestamp': _extractTimestamp(cells[4]),
      'seeders': int.tryParse(cells[5].text.trim()) ?? 0,
      'leechers': int.tryParse(cells[6].text.trim()) ?? 0,
      'completed': int.tryParse(cells[7].text.trim()) ?? 0,
      'torrentStatus': _extractStatus(row),
    };
  }

  String _extractTorrentId(Element cell) {
    final Element? nameElement = cell.querySelector('a:not(.comments)');
    if (nameElement != null) {
      final String href = nameElement.attributes['href'] ?? '';
      final RegExpMatch? match = RegExp(r'/view/(\d+)').firstMatch(href);
      if (match != null) return match.group(1)!;
    }
    return '';
  }

  String _extractCategory(Element cell) {
    final Element? categoryLink = cell.querySelector('a');
    return categoryLink?.attributes['title'] ?? '';
  }

  String _extractCategoryImage(Element cell) {
    final Element? imgElement = cell.querySelector('a img');
    return imgElement?.attributes['src'] ?? '';
  }

  String _extractTorrentName(Element cell) {
    final Element? nameElement = cell.querySelector('a:not(.comments)');
    if (nameElement != null) {
      final String fullName = nameElement.text.trim();
      final RegExp releaseGroupRegex = RegExp(r'^\[([^\]]+)\]');
      return fullName.replaceFirst(releaseGroupRegex, '').trim();
    }
    return '';
  }

  String? _extractReleaseGroup(Element cell) {
    final Element? nameElement = cell.querySelector('a:not(.comments)');
    if (nameElement != null) {
      final String fullName = nameElement.text.trim();
      final RegExpMatch? match = RegExp(r'^\[([^\]]+)\]').firstMatch(fullName);
      return match?.group(1);
    }
    return null;
  }

  String _extractTorrentLink(Element cell) {
    final Element? nameElement = cell.querySelector('a:not(.comments)');
    if (nameElement != null) {
      final String href = nameElement.attributes['href'] ?? '';
      return 'https://nyaa.si$href';
    }
    return '';
  }

  int _extractComments(Element cell) {
    final Element? commentsElement = cell.querySelector('a.comments');
    if (commentsElement != null) {
      final String commentsText = commentsElement.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      return int.tryParse(commentsText) ?? 0;
    }
    return 0;
  }

  String _extractDownloadLink(Element cell) {
    final Element? torrentElement = cell.querySelector('a[href^="/download/"]');
    if (torrentElement != null) {
      return 'https://nyaa.si${torrentElement.attributes['href'] ?? ''}';
    }
    return '';
  }

  String _extractMagnetLink(Element cell) {
    final Element? magnetElement = cell.querySelector('a[href^="magnet:"]');
    return magnetElement?.attributes['href'] ?? '';
  }

  int? _extractTimestamp(Element cell) {
    final String? timestampStr = cell.attributes['data-timestamp'];
    return timestampStr != null ? int.tryParse(timestampStr) : null;
  }

  String _extractStatus(Element row) {
    if (row.classes.contains('success')) return 'success';
    if (row.classes.contains('danger')) return 'danger';
    return 'default';
  }

  String _sanitizeDirectoryName(String name) =>
      name
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
}
