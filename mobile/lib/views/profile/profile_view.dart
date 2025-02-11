// lib/views/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'widgets/profile_header.dart';
import 'widgets/customization_section.dart';
import 'dart:developer' as dev;

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileViewModel>().loadUnlockedItems());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = viewModel.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Utilisateur non connecté')),
          );
        }

        // Logs pour déboguer
        dev.log('=== DEBUG PROFILE VIEW ===');
        dev.log('User ID: ${user.id}');
        dev.log('Profile picture: ${user.profilePicture}');
        dev.log('Banner: ${user.banner}');
        dev.log('Profile picture asset: ${user.profilePictureAsset?.filePath}');
        dev.log('Banner asset: ${user.bannerAsset?.filePath}');
        dev.log('==========================');

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Bannière avec dégradé
                      ProfileHeader(
                        user: user,
                        bannerHeight: 300,
                        avatarRadius: 50,
                      ),
                      // Dégradé pour assurer la lisibilité
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Contenu principal
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.monetization_on,
                            value: user.coins.toString(),
                            label: 'Coins',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.trending_up,
                            value: user.totalEarnings?.toString() ?? '0',
                            label: 'Total gagné',
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Sections de personnalisation
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomizationSection(
                      title: 'Photos de profil',
                      items: viewModel.unlockedProfilePictures,
                      selectedId: user.profilePicture,
                      onSelect: (id) => viewModel.updateProfilePicture(id),
                      type: 'profile_picture',
                    ),
                  ),

                  const Divider(height: 1),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomizationSection(
                      title: 'Bannières',
                      items: viewModel.unlockedBanners,
                      selectedId: user.banner,
                      onSelect: (id) => viewModel.updateBanner(id),
                      type: 'banner',
                    ),
                  ),

                  const Divider(height: 1),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomizationSection(
                      title: 'Titres',
                      items: viewModel.unlockedTitles,
                      selectedId: user.title,
                      onSelect: (id) => viewModel.updateTitle(id),
                      type: 'title',
                    ),
                  ),

                  // Message d'erreur
                  if (viewModel.error.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
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