import 'package:chasebank/screens/mainpage.dart';
import 'package:chasebank/widgets/constants.dart';
import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final String recipientName;
  final String accountNumber;
  final double amount;
  final String? sourceAccountLabel;
  final double? remainingBalance;

  const ConfirmationScreen({
    super.key,
    required this.recipientName,
    required this.accountNumber,
    required this.amount,
    this.sourceAccountLabel,
    this.remainingBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.background,
                size: 25.0,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Recipient'),
              subtitle: Text(recipientName),
            ),
            ListTile(
              title: const Text('Account Number'),
              subtitle: Text(accountNumber),
            ),
            ListTile(
              title: const Text('Amount'),
              subtitle: Text('\$${amount.toStringAsFixed(2)}'),
            ),
            if (sourceAccountLabel != null)
              ListTile(
                title: const Text('From account'),
                subtitle: Text(sourceAccountLabel!),
              ),
            if (remainingBalance != null)
              ListTile(
                title: const Text('Remaining balance'),
                subtitle: Text('\$${remainingBalance!.toStringAsFixed(2)}'),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A4AA6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                      color: AppColors.background,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MainPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
