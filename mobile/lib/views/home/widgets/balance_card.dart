// lib/views/home/widgets/balance_card.dart

import 'package:flutter/material.dart';
import '../../../models/user.dart';

class BalanceCard extends StatelessWidget {
  final User user;
  final double lastSessionEarnings;

  const BalanceCard({
    Key? key,
    required this.user,
    required this.lastSessionEarnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Votre Solde',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${user.coins}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '💰',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (lastSessionEarnings != 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: lastSessionEarnings >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        lastSessionEarnings >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: lastSessionEarnings >= 0
                            ? Colors.green
                            : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lastSessionEarnings >= 0 ? '+' : ''}$lastSessionEarnings',
                        style: TextStyle(
                          color: lastSessionEarnings >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}