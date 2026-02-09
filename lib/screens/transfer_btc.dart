import 'package:chasebank/screens/confirmation.dart';
import 'package:chasebank/widgets/constants.dart';
import 'package:chasebank/state/balance_store.dart';
import 'package:chasebank/widgets/input_card.dart';
import 'package:flutter/material.dart';

class TransferBtc extends StatefulWidget {
  const TransferBtc({super.key});

  @override
  State<TransferBtc> createState() => _TransferBtcState();
}

class _TransferBtcState extends State<TransferBtc> {
  final _formKey = GlobalKey<FormState>();

  final _recipientController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String _sourceAccount = 'CHECKING';

  bool isSending = false;

  double _availableBalance() {
    if (_sourceAccount == 'SAVINGS') {
      return BalanceStore.savings.value;
    }
    return BalanceStore.checking.value;
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _sendMoney() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;
    final startingBalance = _availableBalance();
    if (amount > startingBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient funds for this transfer.'),
        ),
      );
      return;
    }
    final remainingBalance = startingBalance - amount;

    setState(() => isSending = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => isSending = false);

      // Parse amount
      final amount = double.tryParse(_amountController.text) ?? 0;
      BalanceStore.send(accountKey: _sourceAccount, amount: amount);
      final wallet = _accountController.text.trim();
      final suffix = wallet.isEmpty
          ? ''
          : (wallet.length > 6 ? wallet.substring(wallet.length - 6) : wallet);
      final title = suffix.isEmpty ? 'BTC transfer' : 'BTC transfer to ...$suffix';
      BalanceStore.recordTransaction(
        title: title,
        amount: -amount,
        accountKey: _sourceAccount,
        type: 'btc',
      );

      // Navigate to confirmation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
            recipientName: _recipientController.text,
            accountNumber: _accountController.text,
            amount: amount,
            sourceAccountLabel: _sourceAccount == 'SAVINGS'
                ? 'Chase Savings (...3546)'
                : 'Chase Checking (...3545)',
            remainingBalance: remainingBalance,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: const Text('Transfer to BTC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              InputCard(
                label: 'Bitcoin Wallet',
                controller: _accountController,
                hint: 'Enter Bitcoin Wallet Address',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter account number';
                  }
                  if (value.length < 8) {
                    return 'Invalid account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _sourceAccount,
                decoration: InputDecoration(
                  labelText: 'From account',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'CHECKING',
                    child: Text('Chase Checking (...3545)'),
                  ),
                  DropdownMenuItem(
                    value: 'SAVINGS',
                    child: Text('Chase Savings (...3546)'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _sourceAccount = value);
                },
              ),
              const SizedBox(height: 16),
              InputCard(
                label: 'Amount',
                controller: _amountController,
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefix: const Text(
                  '\$ ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  if (amount > _availableBalance()) {
                    return 'Insufficient funds';
                  }
                  return null;
                },
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
                  onPressed: isSending ? null : _sendMoney,
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'send',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.background),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
