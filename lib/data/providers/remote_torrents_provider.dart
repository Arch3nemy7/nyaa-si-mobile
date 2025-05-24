import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:nyaa_si_mobile/data/models/nyaa_torrent_model.dart';

import '../../core/services/network_service/dio_client.dart';

class RemoteTorrentsProvider {
  RemoteTorrentsProvider(this.dioClient);
  final DioClient dioClient;

  Future<List<NyaaTorrentModel>> getTorrents({
    int page = 1,
    String query = '',
    String filter = '0',
    String category = '0_0',
    String sort = 'id',
    String order = 'desc',
  }) async {
    try {
      final Map<String, dynamic> queryParams = <String, dynamic>{};
      if (page > 1) queryParams['p'] = page.toString();
      if (query.isNotEmpty) queryParams['q'] = query;
      if (filter != '0') queryParams['f'] = filter;
      if (category != '0_0') queryParams['c'] = category;
      if (sort != 'id') queryParams['s'] = sort;
      if (order != 'desc') queryParams['o'] = order;

      final Response<dynamic> response = await dioClient.get(
        '',
        queryParameters: queryParams,
      );

      final Document document = html_parser.parse(response.data.toString());

      final List<Element> rows = document.querySelectorAll(
        'table.torrent-list tbody tr',
      );

      final List<Map<String, dynamic>> torrentsJson = <Map<String, dynamic>>[];
      for (Element row in rows) {
        try {
          final Map<String, dynamic> torrentJson = _parseTorrentRowToJson(row);
          torrentsJson.add(torrentJson);
        } catch (e) {
          throw Exception('Failed to parse torrent JSON: $e');
        }
      }

      final List<NyaaTorrentModel> torrents =
          torrentsJson
              .map(
                (Map<String, dynamic> json) => NyaaTorrentModel.fromJson(json),
              )
              .toList();
      return torrents;
    } catch (e) {
      throw Exception('Failed to fetch torrents: $e');
    }
  }

  Map<String, dynamic> _parseTorrentRowToJson(Element row) {
    String torrentStatus = 'default';
    if (row.classes.contains('success')) {
      torrentStatus = 'success';
    } else if (row.classes.contains('danger')) {
      torrentStatus = 'danger';
    }

    final List<Element> cells = row.querySelectorAll('td');

    String category = '';
    String categoryImage = '';
    final Element? categoryLink = cells[0].querySelector('a');
    if (categoryLink != null) {
      category = categoryLink.attributes['title'] ?? '';
      final Element? imgElement = categoryLink.querySelector('img');
      if (imgElement != null) {
        categoryImage = imgElement.attributes['src'] ?? '';
      }
    }

    String name = '';
    String link = '';
    int comments = 0;

    final Element? commentsElement = cells[1].querySelector('a.comments');
    if (commentsElement != null) {
      final String commentsText = commentsElement.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      comments = int.tryParse(commentsText) ?? 0;
    }

    final Element? nameElement = cells[1].querySelector('a:not(.comments)');
    if (nameElement != null) {
      name = nameElement.text.trim();
      link = 'https://nyaa.si${nameElement.attributes['href'] ?? ''}';
    }

    String torrentLink = '';
    String magnetLink = '';
    final Element? torrentElement = cells[2].querySelector(
      'a[href^="/download/"]',
    );
    if (torrentElement != null) {
      torrentLink = 'https://nyaa.si${torrentElement.attributes['href'] ?? ''}';
    }
    final Element? magnetElement = cells[2].querySelector('a[href^="magnet:"]');
    if (magnetElement != null) {
      magnetLink = magnetElement.attributes['href'] ?? '';
    }

    final String size = cells[3].text.trim();

    final String date = cells[4].text.trim();
    int? timestamp;
    if (cells[4].attributes.containsKey('data-timestamp')) {
      timestamp = int.tryParse(cells[4].attributes['data-timestamp'] ?? '');
    }

    final int seeders = int.tryParse(cells[5].text.trim()) ?? 0;
    final int leechers = int.tryParse(cells[6].text.trim()) ?? 0;
    final int completed = int.tryParse(cells[7].text.trim()) ?? 0;

    return <String, dynamic>{
      'category': category,
      'categoryImage': categoryImage,
      'name': name,
      'link': link,
      'comments': comments,
      'torrentLink': torrentLink,
      'magnetLink': magnetLink,
      'size': size,
      'date': date,
      'timestamp': timestamp,
      'seeders': seeders,
      'leechers': leechers,
      'completed': completed,
      'torrentStatus': torrentStatus,
    };
  }
}
