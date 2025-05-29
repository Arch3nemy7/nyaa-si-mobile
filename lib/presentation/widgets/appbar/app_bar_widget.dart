import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

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
  backgroundColor: Colors.white,
  foregroundColor: nyaaAccent,
  elevation: 0,
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            nyaaPrimary.withValues(alpha: 0.1),
            nyaaSecondary.withValues(alpha: 0.1),
          ],
        ),
      ),
    ),
  ),
  actions: <Widget>[
    IconButton(
      onPressed: () {},
      icon: const Icon(Icons.download, color: nyaaPrimary),
    ),
  ],
);
