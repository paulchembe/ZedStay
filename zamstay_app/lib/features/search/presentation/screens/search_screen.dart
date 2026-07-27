import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../listings/domain/listing_model.dart';
import '../../../listings/presentation/providers/listing_provider.dart';

// Search filters state
class SearchFilters {
  final String city;
  final String type;
  final double? maxPrice;

  const SearchFilters({
    this.city = '',
    this.type = '',
    this.maxPrice,
  });

  // Convert to a stable string key to avoid infinite loops
  String toKey() => '$city|$type|${maxPrice ?? ''}';
}

final searchFiltersProvider =
    StateProvider<SearchFilters>((ref) => const SearchFilters());

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedType = '';
  double _maxPrice = 2000;
  bool _filtersVisible = false;

  final List<String> _propertyTypes = [
    'All', 'apartment', 'house', 'room', 'guesthouse', 'hotel'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(searchFiltersProvider.notifier).state = SearchFilters(
      city: _searchController.text.trim(),
      type: _selectedType == 'All' ? '' : _selectedType,
      maxPrice: _maxPrice < 2000 ? _maxPrice : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFilters = ref.watch(searchFiltersProvider);
    final listings = ref.watch(listingsProvider(currentFilters.toKey()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Accommodation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _filtersVisible ? Icons.filter_list_off : Icons.filter_list,
              color: const Color(0xFF1B3A6B),
            ),
            onPressed: () =>
                setState(() => _filtersVisible = !_filtersVisible),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by city — Lusaka, Kitwe...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onSubmitted: (_) => _applyFilters(),
              onChanged: (value) {
                if (value.isEmpty) _applyFilters();
              },
            ),
          ),

          // Filters panel
          if (_filtersVisible) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property type filter
                  const Text('Property type',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _propertyTypes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final type = _propertyTypes[index];
                        final selected = _selectedType == type ||
                            (type == 'All' && _selectedType.isEmpty);
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedType =
                                type == 'All' ? '' : type);
                            _applyFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF1B3A6B)
                                  : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF1B3A6B)
                                    : Colors.grey.shade300,
                              ),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              type[0].toUpperCase() +
                                  type.substring(1),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price filter
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max price per night',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Text(
                        _maxPrice >= 2000
                            ? 'Any price'
                            : 'K ${_maxPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFF0F6E56),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxPrice,
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    activeColor: const Color(0xFF1B3A6B),
                    onChanged: (value) =>
                        setState(() => _maxPrice = value),
                    onChangeEnd: (_) => _applyFilters(),
                  ),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A6B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8)),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Results
          Expanded(
            child: listings.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Error: $e',
                        style:
                            const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(
                        listingsProvider(currentFilters.toKey())),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (listingList) {
                if (listingList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 72, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No listings found',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text(
                          currentFilters.city.isNotEmpty
                              ? 'No results for "${currentFilters.city}"'
                              : 'Try adjusting your filters',
                          style:
                              const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    // Results count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '${listingList.length} ${listingList.length == 1 ? 'property' : 'properties'} found',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: listingList.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final listing = listingList[index];
                          return _ListingCard(listing: listing);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/listing-detail', extra: listing),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: listing.photoUrls.isNotEmpty
                  ? Image.network(
                      listing.photoUrls.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      color: const Color(0xFFD6E4F7),
                      child: const Center(
                        child: Icon(Icons.home_outlined,
                            size: 60,
                            color: Color(0xFF1B3A6B)),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'K ${listing.pricePerNight.toStringAsFixed(0)}/night',
                        style: const TextStyle(
                          color: Color(0xFF0F6E56),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(listing.city,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E4F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          listing.type[0].toUpperCase() +
                              listing.type.substring(1),
                          style: const TextStyle(
                              color: Color(0xFF1B3A6B),
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.bed_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${listing.rooms} rooms',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}