import 'package:chasebank/screens/confirmation.dart';
import 'package:chasebank/widgets/constants.dart';
import 'package:chasebank/state/balance_store.dart';
import 'package:flutter/material.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _recipientController = TextEditingController();
  final _recipientFocusNode = FocusNode();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String _sourceAccount = 'CHECKING';

  final List<String> _recipientOptions = const [
    'Alex Morgan',
    'Jamie Lee',
    'Taylor Brooks',
    'Chris Evans',
    'Jordan Smith',
  ];

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
    _recipientFocusNode.dispose();
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
      final recipient = _recipientController.text.trim();
      final title =
          recipient.isEmpty ? 'Zelle transfer' : 'Zelle transfer to $recipient';
      BalanceStore.recordTransaction(
        title: title,
        amount: -amount,
        accountKey: _sourceAccount,
        type: 'send',
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
        foregroundColor: AppColors.background,
        title: const Text(
          'Send Money',
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  final query = textEditingValue.text.trim().toLowerCase();
                  if (query.isEmpty) {
                    return _recipientOptions;
                  }
                  return _recipientOptions.where(
                    (name) => name.toLowerCase().contains(query),
                  );
                },
                onSelected: (selection) {
                  _recipientController.text = selection;
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  if (textEditingController != _recipientController) {
                    textEditingController
                      ..text = _recipientController.text
                      ..selection = _recipientController.selection;
                  }
                  return TextFormField(
                    controller: _recipientController,
                    focusNode: _recipientFocusNode,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Recipient name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter recipient name'
                        : null,
                    onFieldSubmitted: (_) => onFieldSubmitted(),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _InputCard(
                label: 'Account number',
                controller: _accountController,
                hint: 'Enter account number',
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
              _InputCard(
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
                          'Send',
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

class _InputCard extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? prefix;
  final String? Function(String?)? validator;

  const _InputCard({
    required this.label,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.prefix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefix,
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
