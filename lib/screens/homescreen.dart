import 'dart:async';
import 'dart:math';

import 'package:chasebank/widgets/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chasebank/state/balance_store.dart';
import 'package:chasebank/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  late DateTime _now;
  Timer? _clockTimer;
  late final int _snapshotPoints;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _snapshotPoints = 100 + Random().nextInt(900);
    BalanceStore.bindToCurrentUser();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final current = DateTime.now();
      if (_now.minute != current.minute ||
          _now.hour != current.hour ||
          _now.day != current.day) {
        if (!mounted) return;
        setState(() {
          _now = current;
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    BalanceStore.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration: const BoxDecoration(color: AppColors.lightBlue),
                  child: _header()),
              const SizedBox(
                height: 18,
              ),
              _quickActions(),
              _snapshotCard(),
              _accountsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Header
  Widget _header() {
    final greeting = _greetingForTime(_now);
    final formattedDate = DateFormat('MMMM d, y', 'en_US').format(_now);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  greeting,
                  key: ValueKey(greeting),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.background),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  formattedDate,
                  key: ValueKey(formattedDate),
                  style: const TextStyle(color: AppColors.background),
                ),
              ),
              _userNameLine(),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Sign out',
                onPressed: () async {
                  await AuthServices().logout();
                  await BalanceStore.stopListening();
                  BalanceStore.resetLocal();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
              const CircleAvatar(
                backgroundColor: Color(0xFF0A4AA6),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userNameLine() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final name = (user.displayName ?? '').trim();
    final fallback = (user.email ?? '').trim();
    final label = name.isNotEmpty ? name : fallback;
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.background,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _greetingForTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    if (hour >= 18 && hour < 22) return 'Good evening';
    return 'Good night';
  }

  // 🔹 Quick Actions
  Widget _quickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            _actionButton('See statements'),
            const SizedBox(width: 10),
            _actionButton('Payment history'),
            const SizedBox(
              width: 10,
            ),
            _actionButton('send zelle ® '),
            const SizedBox(width: 10),
            _actionButton('+'),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF0A4AA6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: AppColors.lightBlue, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 🔹 Snapshot Card
  Widget _snapshotCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFF0A4AA6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Today\'s Snapshot\nWoo-hoo! You earned $_snapshotPoints points on a recent purchase.',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Accounts Section
  Widget _accountsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accounts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Tabs
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1.5, color: AppColors.lightBlue)),
                  width: double.infinity,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Overview'),
                  )),
              Container(
                  decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      border: Border.all(color: AppColors.lightBlue)),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                        [BalanceStore.checking, BalanceStore.savings],
                      ),
                      builder: (context, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Banking Accounts (2)',
                              style: TextStyle(color: AppColors.background),
                            ),
                            Text(
                              _currencyFormat.format(BalanceStore.totalBanking),
                              style: const TextStyle(
                                  color: AppColors.background, fontSize: 18),
                            )
                          ],
                        );
                      },
                    ),
                  )),
            ],
          ),

          _accountTileWithBalance(
            title: 'CHASE CHECKING (...3545)',
            subtitle: 'Available balance',
            amountListenable: BalanceStore.checking,
          ),

          _accountTileWithBalance(
            title: 'CHASE SAVINGS (...3546)',
            subtitle: 'Available balance',
            amountListenable: BalanceStore.savings,
          ),

          const Text(
            'Credit Cards (1)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          _accountTile(
            title: 'Freedom Unlimited',
            amount: '\$2,250.00',
            subtitle: 'Available credit',
          ),
        ],
      ),
    );
  }

  // 🔹 Account Tile
  Widget _accountTile({
    required String title,
    required String amount,
    required String subtitle,
  }) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightBlue),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black38),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountTileWithBalance({
    required String title,
    required String subtitle,
    required ValueListenable<double> amountListenable,
  }) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightBlue),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black38),
              ),
            ],
          ),
          ValueListenableBuilder<double>(
            valueListenable: amountListenable,
            builder: (context, value, _) {
              return Text(
                _currencyFormat.format(value),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
