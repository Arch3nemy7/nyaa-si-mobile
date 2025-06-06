import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class SearchBarWidget extends StatefulWidget {
  final String? currentSearchQuery;
  final String? currentSortField;
  final String? currentSortOrder;
  final String? currentFilterStatus;
  final String? currentFilterCategory;
  final void Function(String) onSearch;
  final void Function(String, String) onSort;
  final void Function(String) onStatusFilter;
  final void Function(String) onFilterCategory;

  const SearchBarWidget({
    super.key,
    this.currentSearchQuery,
    this.currentSortField,
    this.currentSortOrder,
    this.currentFilterStatus,
    this.currentFilterCategory,
    required this.onSearch,
    required this.onSort,
    required this.onStatusFilter,
    required this.onFilterCategory,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  final Map<String, String> _categories = <String, String>{
    '0_0': 'All Categories',
    '1_1': 'Anime - Music Video',
    '1_2': 'Anime - English-translated',
    '1_3': 'Anime - Non-English-translated',
    '1_4': 'Anime - Raw',
    '2_1': 'Audio - Lossless',
    '2_2': 'Audio - Lossy',
    '3_1': 'Literature - English-translated',
    '3_2': 'Literature - Non-English-translated',
    '3_3': 'Literature - Raw',
    '4_1': 'Live Action - English-translated',
    '4_2': 'Live Action - Idol/Promotional Video',
    '4_3': 'Live Action - Non-English-translated',
    '4_4': 'Live Action - Raw',
    '5_1': 'Pictures - Graphics',
    '5_2': 'Pictures - Photos',
    '6_1': 'Software - Applications',
    '6_2': 'Software - Games',
  };

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.currentSearchQuery ?? '';
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSearchQuery != oldWidget.currentSearchQuery) {
      _searchController.text = widget.currentSearchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: nyaaPrimaryContainerBackground,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: nyaaPrimaryBorder),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: nyaaPrimary.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: _isExpanded ? _buildExpandedSearch() : _buildCollapsedSearch(),
    ),
  );

  Widget _buildCollapsedSearch() => InkWell(
    onTap: () => setState(() => _isExpanded = true),
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.search_rounded,
                color: nyaaPrimary.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.currentSearchQuery?.isNotEmpty == true
                      ? widget.currentSearchQuery!
                      : 'Search torrents...',
                  style: TextStyle(
                    color:
                        widget.currentSearchQuery?.isNotEmpty == true
                            ? nyaaAccent
                            : nyaaAccent.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight:
                        widget.currentSearchQuery?.isNotEmpty == true
                            ? FontWeight.w500
                            : FontWeight.normal,
                  ),
                ),
              ),
              _buildQuickFilters(),
            ],
          ),

          if ((widget.currentFilterCategory ?? '0_0') != '0_0') ...<Widget>[
            const SizedBox(height: 8),
            Container(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: nyaaPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.category_rounded,
                      size: 12,
                      color: nyaaPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getCategoryDisplayName(
                        widget.currentFilterCategory ?? '0_0',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: nyaaPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildQuickFilters() => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      _buildSortButton(),
      const SizedBox(width: 8),
      IconButton(
        onPressed: _showFilterBottomSheet,
        icon: Stack(
          children: <Widget>[
            Icon(
              Icons.tune_rounded,
              color: nyaaPrimary.withValues(alpha: 0.7),
              size: 20,
            ),
            if (_hasActiveFilters())
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: nyaaPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
    ],
  );

  Widget _buildExpandedSearch() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search torrents...',
                  hintStyle: TextStyle(
                    color: nyaaAccent.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                style: const TextStyle(
                  color: nyaaAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                onSubmitted: _performSearch,
              ),
            ),
            IconButton(
              onPressed: () => _performSearch(_searchController.text),
              icon: const Icon(
                Icons.search_rounded,
                color: nyaaPrimary,
                size: 20,
              ),
              splashRadius: 20,
            ),
            IconButton(
              onPressed: () {
                setState(() => _isExpanded = false);
                _searchController.clear();
                widget.onSearch('');
              },
              icon: Icon(
                Icons.close_rounded,
                color: nyaaAccent.withValues(alpha: 0.7),
                size: 20,
              ),
              splashRadius: 20,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSortButton() {
    final String currentSort = _getSortDisplayName(
      widget.currentSortField ?? 'id',
    );
    final String currentOrder = widget.currentSortOrder ?? 'desc';

    return PopupMenuButton<String>(
      onSelected: _handleSortSelection,
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            _buildSortMenuItem('id', 'Date', currentSort, currentOrder),
            _buildSortMenuItem('seeders', 'Seeders', currentSort, currentOrder),
            _buildSortMenuItem(
              'leechers',
              'Leechers',
              currentSort,
              currentOrder,
            ),
            _buildSortMenuItem(
              'downloads',
              'Downloads',
              currentSort,
              currentOrder,
            ),
            _buildSortMenuItem('size', 'Size', currentSort, currentOrder),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: nyaaPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: nyaaPrimary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              currentOrder == 'desc'
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 12,
              color: nyaaPrimary,
            ),
            const SizedBox(width: 2),
            Text(
              currentSort,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: nyaaPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(
    String field,
    String display,
    String currentSort,
    String currentOrder,
  ) {
    final bool isSelected = _getSortDisplayName(field) == currentSort;

    return PopupMenuItem<String>(
      value: field,
      child: Row(
        children: <Widget>[
          Icon(
            isSelected && currentOrder == 'desc'
                ? Icons.arrow_downward_rounded
                : isSelected && currentOrder == 'asc'
                ? Icons.arrow_upward_rounded
                : Icons.sort_rounded,
            size: 16,
            color: isSelected ? nyaaPrimary : nyaaAccent.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            display,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? nyaaPrimary : nyaaAccent,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (BuildContext context, ScrollController scrollController) =>
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              children: <Widget>[
                                const Text(
                                  'Filter & Categories',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: nyaaAccent,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    widget.onStatusFilter('0');
                                    widget.onFilterCategory('0_0');
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Reset All',
                                    style: TextStyle(color: nyaaPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(20),
                              children: <Widget>[
                                const Text(
                                  'Status Filter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: nyaaAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    _buildBottomSheetFilterChip('All', '0'),
                                    _buildBottomSheetFilterChip(
                                      'No Remakes',
                                      '1',
                                    ),
                                    _buildBottomSheetFilterChip(
                                      'Trusted Only',
                                      '2',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: nyaaAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._buildCategoryGroups(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
    );
  }

  Widget _buildBottomSheetFilterChip(String label, String status) {
    final bool isSelected = (widget.currentFilterStatus ?? '0') == status;

    return GestureDetector(
      onTap: () {
        widget.onStatusFilter(status);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? nyaaPrimary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? nyaaPrimary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : nyaaAccent,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryGroups() {
    final Map<String, List<MapEntry<String, String>>> grouped =
        <String, List<MapEntry<String, String>>>{};

    for (final MapEntry<String, String> entry in _categories.entries) {
      if (entry.key == '0_0') continue;

      final String mainCategory = entry.value.split(' - ')[0];
      grouped.putIfAbsent(mainCategory, () => <MapEntry<String, String>>[]);
      grouped[mainCategory]!.add(entry);
    }

    final List<Widget> widgets = <Widget>[];

    widgets.add(_buildCategoryChip('0_0', 'All Categories'));
    widgets.add(const SizedBox(height: 16));

    for (final MapEntry<String, List<MapEntry<String, String>>> group
        in grouped.entries) {
      widgets.add(
        Text(
          group.key,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: nyaaAccent.withValues(alpha: 0.8),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      widgets.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              group.value
                  .map(
                    (MapEntry<String, String> entry) =>
                        _buildCategoryChip(entry.key, entry.value),
                  )
                  .toList(),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  Widget _buildCategoryChip(String value, String label) {
    final bool isSelected = (widget.currentFilterCategory ?? '0_0') == value;
    final String displayText =
        label.contains(' - ') ? label.split(' - ')[1] : label;

    return GestureDetector(
      onTap: () {
        widget.onFilterCategory(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? nyaaPrimary : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? nyaaPrimary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : nyaaAccent,
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() =>
      (widget.currentFilterStatus ?? '0') != '0' ||
      (widget.currentFilterCategory ?? '0_0') != '0_0';

  String _getCategoryDisplayName(String categoryValue) {
    final String fullName = _categories[categoryValue] ?? 'All Categories';
    if (fullName.contains(' - ')) {
      final List<String> parts = fullName.split(' - ');
      return '${parts[0]} • ${parts[1]}';
    }
    return fullName;
  }

  void _performSearch(String query) {
    setState(() => _isExpanded = false);
    widget.onSearch(query.trim());
  }

  void _handleSortSelection(String field) {
    String newOrder = 'desc';
    final String currentField = widget.currentSortField ?? 'id';
    final String currentOrder = widget.currentSortOrder ?? 'desc';

    if (currentField == field) {
      newOrder = currentOrder == 'desc' ? 'asc' : 'desc';
    }

    widget.onSort(field, newOrder);
  }

  String _getSortDisplayName(String field) => switch (field) {
    'id' => 'Date',
    'seeders' => 'Seeders',
    'leechers' => 'Leechers',
    'downloads' => 'Downloads',
    'size' => 'Size',
    _ => 'Date',
  };
}
