import 'package:flutter/material.dart';

class OptionSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const OptionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Option Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _OptionButton(
                  title: "CALL (CE)",
                  value: "CE",
                  selected: selected == "CE",
                  selectedColor: Colors.green,
                  onTap: () => onChanged("CE"),
                ),
              ),
              Expanded(
                child: _OptionButton(
                  title: "PUT (PE)",
                  value: "PE",
                  selected: selected == "PE",
                  selectedColor: Colors.red,
                  onTap: () => onChanged("PE"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String title;
  final String value;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _OptionButton({
    required this.title,
    required this.value,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
