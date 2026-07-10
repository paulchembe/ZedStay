import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/listing_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1 — Basic info
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'apartment';

  // Step 2 — Location & price
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController(text: '1');

  // Step 3 — Amenities
  final List<String> _allAmenities = [
    'WiFi', 'Parking', 'Air conditioning', 'Swimming pool',
    'Kitchen', 'Washing machine', 'TV', 'Hot water',
    'Security', 'Generator', 'DSTV', 'Borehole water',
  ];
  final List<String> _selectedAmenities = [];

  // Step 4 — Photos
  final List<Uint8List> _selectedImages = [];
  final List<String> _imageNames = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _propertyTypes = [
    'apartment', 'house', 'room', 'guesthouse', 'hotel'
  ];

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isEmpty) return;

    for (var image in images) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImages.add(bytes);
        _imageNames.add(image.name);
      });
    }
  }

  Future<void> _submitListing() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(listingRepositoryProvider);

      // Create the listing
      final listingId = await repo.createListing(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        pricePerNight: double.parse(_priceController.text.trim()),
        rooms: int.parse(_roomsController.text.trim()),
        amenities: _selectedAmenities,
      );

      // Upload photos
      for (int i = 0; i < _selectedImages.length; i++) {
        final photoUrl = await repo.uploadPhoto(
          listingId,
          _selectedImages[i],
          _imageNames[i],
        );
        await repo.savePhotoRecord(listingId, photoUrl, i == 0, i);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing created successfully!'),
            backgroundColor: Color(0xFF0F6E56),
          ),
        );
        context.go('/my-listings');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  // ── STEP BUILDERS ────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What are you listing?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Listing title',
            hintText: 'e.g. Cozy 2-bedroom apartment in Kabulonga',
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter a title' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe your property...',
          ),
          maxLines: 4,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter a description' : null,
        ),
        const SizedBox(height: 24),
        const Text('Property type',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _propertyTypes.map((type) {
            final selected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1B3A6B)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF1B3A6B)
                        : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type[0].toUpperCase() + type.substring(1),
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location & pricing',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'City',
            hintText: 'e.g. Lusaka, Kitwe, Livingstone',
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter a city' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Full address',
            hintText: 'e.g. Plot 15, Kabulonga Road',
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter an address' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per night (ZMW)',
                  prefixText: 'K ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a price';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _roomsController,
                decoration: const InputDecoration(labelText: 'Number of rooms'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter rooms';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amenities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Select everything your property offers',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allAmenities.map((amenity) {
            final selected = _selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () {
                setState(() {
                  selected
                      ? _selectedAmenities.remove(amenity)
                      : _selectedAmenities.add(amenity);
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF0F6E56)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF0F6E56)
                        : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.check, size: 14, color: Colors.white),
                      ),
                    Text(
                      amenity,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Add at least 1 photo of your property',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xFF1B3A6B), style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFD6E4F7),
            ),
            child: const Column(
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 48, color: Color(0xFF1B3A6B)),
                SizedBox(height: 8),
                Text('Tap to add photos',
                    style: TextStyle(
                        color: Color(0xFF1B3A6B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F6E56),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Cover',
                            style: TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedImages.removeAt(index);
                        _imageNames.removeAt(index);
                      }),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!,
              style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }

  // ── MAIN BUILD ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildStep1(),
      _buildStep2(),
      _buildStep3(),
      _buildStep4(),
    ];

    final stepTitles = ['Basics', 'Location', 'Amenities', 'Photos'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('List your property'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/home'),
              ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(stepTitles.length, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: isCompleted || isActive
                                    ? const Color(0xFF1B3A6B)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stepTitles[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: isActive
                                    ? const Color(0xFF1B3A6B)
                                    : Colors.grey,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < stepTitles.length - 1)
                        const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Step content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: steps[_currentStep],
              ),
            ),
          ),

          // Bottom navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A6B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_currentStep < steps.length - 1) {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _currentStep++);
                          }
                        } else {
                          if (_selectedImages.isEmpty) {
                            setState(() => _errorMessage =
                                'Please add at least one photo');
                            return;
                          }
                          _submitListing();
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _currentStep < steps.length - 1
                            ? 'Continue'
                            : 'Publish listing',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}