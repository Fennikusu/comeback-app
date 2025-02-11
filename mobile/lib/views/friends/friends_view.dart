// lib/views/friends/friends_view.dart
import 'package:comeback/views/friends/widgets/friend_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/friends_viewmodel.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({Key? key}) : super(key: key);

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  final _friendIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<FriendsViewModel>().loadFriends()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Amis'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Column(
            children: [
              // Section Ajouter un ami
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _friendIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID ami',
                          hintText: 'Entrez l\'ID d\'un ami',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final friendId = _friendIdController.text.trim();
                        if (friendId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez entrer un ID')),
                          );
                          return;
                        }
                        final success = await viewModel.addFriend(friendId);
                        if (success && mounted) {
                          _friendIdController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ami ajouté avec succès')),
                          );
                        }
                      },
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ),

              // Message d'erreur
              if (viewModel.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    viewModel.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Liste des amis
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.friends.isEmpty
                    ? const Center(child: Text('Aucun ami trouvé'))
                    : ListView.builder(
                  itemCount: viewModel.friends.length,
                  itemBuilder: (context, index) {
                    final friend = viewModel.friends[index];
                    return FriendCard(
                      friend: friend,
                      onRemove: () async {
                        final success = await viewModel.removeFriend(friend.id);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ami supprimé')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}