import 'package:flutter/material.dart';

class ChangeDateButton extends StatelessWidget {
  const ChangeDateButton({super.key, required this.label, required this.onTap});

  final Function() onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(maxWidth: 100, minWidth: 55),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[300],
        ),
        child: Text(label),
      ),
    );
  }
}
