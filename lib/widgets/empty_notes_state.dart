import 'package:flutter/material.dart';

class EmptyNotesState extends StatelessWidget {
  const EmptyNotesState({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Colors.grey.shade500;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.22,
              child: Icon(
                Icons.sticky_note_2_outlined,
                size: 148,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa có ghi chú nào, hãy tạo mới nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
