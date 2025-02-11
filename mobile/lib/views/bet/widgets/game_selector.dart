import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/bet_viewmodel.dart';

class GameSelector extends StatelessWidget {
  final List<String> games = ['League of Legends', 'Valorant'];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BetViewModel>(context);

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          final isSelected = game == viewModel.selectedGame;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () => viewModel.changeGame(game),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    game,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}