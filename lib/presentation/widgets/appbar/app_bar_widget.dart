import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/navigation_service/app_router_service.gr.dart';

PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
  title: Row(
    children: <Widget>[
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[nyaaPrimary, nyaaSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.pets, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 12),
      const Text(
        'Nyaa.si',
        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    ],
  ),
  foregroundColor: nyaaAccent,
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(height: 1, color: nyaaPrimaryBorder),
  ),
  actions: <Widget>[
    IconButton(
      onPressed: () {
        context.router.push(const DownloadedTorrentHomeRoute());
      },
      icon: const Icon(Icons.download, color: nyaaPrimary),
    ),
  ],
);
