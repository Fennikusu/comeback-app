// lib/views/home/widgets/daily_chest.dart

import 'package:flutter/material.dart';
import 'dart:async';

class DailyChest extends StatefulWidget {
  final Function onOpen;
  final bool isAvailable;
  final DateTime? lastClaimTime;

  const DailyChest({
    Key? key,
    required this.onOpen,
    required this.isAvailable,
    this.lastClaimTime,
  }) : super(key: key);

  @override
  State<DailyChest> createState() => _DailyChestState();
}

class _DailyChestState extends State<DailyChest> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpening = false;
  Timer? _timer;
  String _timeLeft = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onOpen();
        setState(() {
          _isOpening = false;
        });
        _controller.reset();
      }
    });

    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    if (widget.lastClaimTime == null) {
      setState(() {
        _timeLeft = '';
      });
      return;
    }

    final nextAvailable = widget.lastClaimTime!.add(const Duration(days: 1));
    final now = DateTime.now();
    final difference = nextAvailable.difference(now);

    if (difference.isNegative) {
      setState(() {
        _timeLeft = '';
      });
      return;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    setState(() {
      _timeLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  void _openChest() {
    if (!widget.isAvailable || _isOpening) return;
    setState(() {
      _isOpening = true;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isAvailable
              ? [Colors.amber[400]!, Colors.amber[600]!]
              : [Colors.grey[300]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (widget.isAvailable ? Colors.amber : Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openChest,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coffre journalier',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isAvailable
                            ? 'Appuyez pour ouvrir !'
                            : _timeLeft.isNotEmpty
                            ? 'Disponible dans $_timeLeft'
                            : 'Revenez demain',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isAvailable) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}