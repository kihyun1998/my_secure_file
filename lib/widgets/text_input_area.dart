import 'package:flutter/material.dart';

class TextInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const TextInputArea({
    super.key,
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '✏️ 텍스트 입력/출력',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: onClear,
                  icon: Icon(Icons.clear, size: 16),
                  label: Text('클리어'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '암호화할 텍스트를 입력하거나\n파일에서 읽은 내용이 여기에 표시됩니다...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
