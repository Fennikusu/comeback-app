// lib/screens/shop/shop_items_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/shop_item.dart';
import '../../services/shop_service.dart';
import 'widgets/item_dialogs.dart';
import 'widgets/shop_item_tile.dart';

class ShopItemsScreen extends StatefulWidget {
  const ShopItemsScreen({Key? key}) : super(key: key);

  @override
  State<ShopItemsScreen> createState() => _ShopItemsScreenState();
}

class _ShopItemsScreenState extends State<ShopItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ShopService _shopService = ShopService();
  bool _isLoading = false;
  Map<String, List<ShopItem>> _items = {
    'profile_pictures': [],
    'banners': [],
    'titles': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _shopService.getAllItems();
      setState(() => _items = items);
    } catch (e) {
      _showError('Erreur lors du chargement des items: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addItem(String type) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddItemDialog(type: type),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final file = result['file'] as PlatformFile?;
        final name = result['name'] as String;
        final price = result['price'] as int;

        if (file != null) {
          await _shopService.createItem(file, name, type, price);
          await _loadItems();
        }
      } catch (e) {
        _showError('Erreur lors de l\'ajout: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editItem(ShopItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditItemDialog(item: item),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _shopService.updateItem(
          item.id,
          result['name'] as String,
          result['price'] as int,
        );
        await _loadItems();
      } catch (e) {
        _showError('Erreur lors de la modification: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de la boutique'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Photos de profil'),
            Tab(text: 'Bannières'),
            Tab(text: 'Titres'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemsGrid('profile_picture'),
                _buildItemsGrid('banner'),
                _buildItemsGrid('title'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(_getTypeFromIndex(_tabController.index)),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return 'profile_picture';
      case 1:
        return 'banner';
      case 2:
        return 'title';
      default:
        return 'profile_picture';
    }
  }

  Widget _buildItemsGrid(String type) {
    final items = _items[type + 's'] ?? [];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ShopItemTile(
          item: item,
          onEdit: () => _editItem(item),
          onDelete: () async {
            try {
              await _shopService.deleteItem(item.id);
              await _loadItems();
            } catch (e) {
              _showError('Erreur lors de la suppression: $e');
            }
          },
        );
      },
    );
  }
}
