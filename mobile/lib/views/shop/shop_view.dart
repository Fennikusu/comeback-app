// lib/views/shop/shop_view.dart
import 'package:comeback/views/shop/widgets/shop_item_card.dart';
import 'package:comeback/views/shop/widgets/unlock_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shop_item.dart';
import '../../viewmodels/shop_viewmodel.dart';

class ShopView extends StatefulWidget {
  const ShopView({Key? key}) : super(key: key);

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final viewModel = context.read<ShopViewModel>();
      await viewModel.loadAvailableItems();

      if (viewModel.newlyUnlockedItems.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder: (context) => UnlockDialog(
            unlockedItems: viewModel.newlyUnlockedItems,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Boutique'),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on),
                    const SizedBox(width: 4),
                    Text(
                      '${viewModel.currentCoins}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  'Photos de profil',
                  viewModel.availableItems['profile_pictures'] ?? [],
                  viewModel.currentCoins,
                ),
                _buildSection(
                  context,
                  'Bannières',
                  viewModel.availableItems['banners'] ?? [],
                  viewModel.currentCoins,
                ),
                _buildSection(
                  context,
                  'Titres',
                  viewModel.availableItems['titles'] ?? [],
                  viewModel.currentCoins,
                ),
                if (viewModel.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      viewModel.error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context,
      String title,
      List<ShopItem> items,
      int currentCoins,
      ) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ShopItemCard(
                item: item,
                currentCoins: currentCoins,
              );
            },
          ),
        ),
      ],
    );
  }
}