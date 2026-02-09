import 'package:chasebank/widgets/constants.dart';
import 'package:flutter/material.dart';

class Plan extends StatefulWidget {
  const Plan({super.key});

  @override
  State<Plan> createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  final TextEditingController _taskController = TextEditingController();
  final List<_PlanItem> _items = [
    const _PlanItem(title: 'Review budget for February'),
    const _PlanItem(title: 'Set savings goal', isDone: true),
    const _PlanItem(title: 'Pay credit card bill'),
  ];

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.insert(0, _PlanItem(title: text));
      _taskController.clear();
    });
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      _items[index] = _items[index].copyWith(isDone: value ?? false);
    });
  }

  void _removeTask(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Plan & Track'),
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _PlannerInput(
              controller: _taskController,
              onSubmit: _addTask,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _PlannerTile(
                          title: item.title,
                          isDone: item.isDone,
                          onChanged: (value) => _toggleTask(index, value),
                          onDelete: () => _removeTask(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _PlannerInput({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: 'Add a task...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          width: 48,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A4AA6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _PlannerTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  const _PlannerTile({
    required this.title,
    required this.isDone,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          onChanged: onChanged,
          activeColor: const Color(0xFF0A4AA6),
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.black45 : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _PlanItem {
  final String title;
  final bool isDone;

  const _PlanItem({required this.title, this.isDone = false});

  _PlanItem copyWith({String? title, bool? isDone}) {
    return _PlanItem(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
