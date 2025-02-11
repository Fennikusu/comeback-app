// lib/views/profile/widgets/customization_section.dart
import 'package:comeback/config/constants.dart';
import 'package:flutter/material.dart';
import '../../../models/shop_item.dart';

class CustomizationSection extends StatefulWidget {
  final String title;
  final List<ShopItem> items;
  final String? selectedId;
  final Future<bool> Function(String) onSelect;
  final String type;

  const CustomizationSection({
    Key? key,
    required this.title,
    required this.items,
    this.selectedId,
    required this.onSelect,
    required this.type,
  }) : super(key: key);

  @override
  State<CustomizationSection> createState() => _CustomizationSectionState();
}

class _CustomizationSectionState extends State<CustomizationSection> {

  String? _updatingItemId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (widget.items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Aucun élément débloqué'),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = item.id == widget.selectedId;
                final isUpdating = item.id == _updatingItemId;

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildItemPreview(item, isSelected, isUpdating),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildItemPreview(ShopItem item, bool isSelected, bool isUpdating) {
    return GestureDetector(
      onTap: isUpdating ? null : () => _handleItemTap(item),
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(
                widget.type == 'banner' ? 8 : 40,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.type == 'banner' ? 6 : 38,
              ),
              child: item.asset != null
                  ? Image.network(
                AppConstants.imageUrl(item.asset!.filePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  print('Item asset: ${item.asset?.filePath}');
                  print('Full URL: ${item.asset?.fullUrl}');
                  return _buildPlaceholder();
                },
              )
                  : _buildPlaceholder(),
            ),
          ),
          if (isUpdating)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(
                    widget.type == 'banner' ? 8 : 40,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          widget.type == 'banner' ? Icons.image : Icons.person,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Future<void> _handleItemTap(ShopItem item) async {
    if (_updatingItemId != null) return;

    setState(() => _updatingItemId = item.id);
    try {
      final success = await widget.onSelect(item.id);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updatingItemId = null);
      }
    }
  }
}