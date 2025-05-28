import 'package:flutter/material.dart';

class FileNameInput extends StatelessWidget {
  final TextEditingController controller;

  const FileNameInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '📄 파일명',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'example.txt',
                suffixIcon: Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
