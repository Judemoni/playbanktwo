//import 'package:chasebank/screens/send_review.dart';
import 'package:chasebank/state/balance_store.dart';
import 'package:chasebank/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayTransferScreen extends StatefulWidget {
  const PayTransferScreen({super.key});

  @override
  State<PayTransferScreen> createState() => _PayTransferScreenState();
}

class _PayTransferScreenState extends State<PayTransferScreen> {
  void _showActivity() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<List<TransactionEntry>>(
              valueListenable: BalanceStore.transactions,
              builder: (context, transactions, _) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (transactions.isEmpty)
                        const Text('No recent activity.')
                      else
                        ..._buildTransactionTiles(transactions),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTransactionTiles(
    List<TransactionEntry> transactions,
  ) {
    final tiles = <Widget>[];
    final dateFormat = DateFormat('MMM d, y');
    for (var i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final isPositive = tx.amount >= 0;
      final amountText =
          '${isPositive ? '+' : '-'}\$${tx.amount.abs().toStringAsFixed(2)}';
      final amountColor =
          isPositive ? AppColors.success : AppColors.textPrimary;
      tiles.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tx.title),
          subtitle: Text(dateFormat.format(tx.timestamp)),
          trailing: Text(
            amountText,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      if (i != transactions.length - 1) {
        tiles.add(const Divider(height: 1));
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        foregroundColor: AppColors.background,
        title: const Text(
          "Pay & Transfer",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  ActionTile(
                    icon: Icons.receipt_long,
                    label: "Pay bills",
                    onTap: () {
                      Navigator.pushNamed(context, '');
                    },
                  ),
                  ActionTile(
                    icon: Icons.send,
                    label: "Send money\nwith Zelle®",
                    onTap: () {
                      Navigator.pushNamed(context, '/enter_amount');
                    },
                  ),
                  ActionTile(
                    icon: Icons.payment,
                    label: "Withdraw",
                    onTap: () {
                      Navigator.pushNamed(context, '/withdraw');
                    },
                  ),
                  ActionTile(
                    icon: Icons.swap_horiz,
                    label: "Transfer to BTC\n(₿)",
                    onTap: () {
                      Navigator.pushNamed(context, '/transferToBtc');
                    },
                  ),
                  ActionTile(
                    icon: Icons.request_page,
                    label: "Request/Split\nwith Zelle®",
                    onTap: () {
                      Navigator.pushNamed(context, '');
                    },
                  ),
                  ActionTile(
                    icon: Icons.camera_alt,
                    label: "Deposit\nchecks",
                    onTap: () {
                      Navigator.pushNamed(context, '');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              MenuTile(
                title: "See activity",
                onTap: _showActivity,
              ),
              const MenuTile(title: "Manage recipients"),
              const MenuTile(title: "Settings"),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const MenuTile({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
