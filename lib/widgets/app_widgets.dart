import 'package:chasebank/widgets/constants.dart';
import 'package:flutter/material.dart';

Widget actionButton(String text) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.lightBlue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, color: AppColors.lightBlue),
    ),
  );
}

Widget actionChip(String text) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.lightBlue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(fontSize: 14)),
  );
}

Widget snapshotCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.insert_chart_outlined, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Snapshot  •  30 sec read\nYour money in this month is \$750.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}
