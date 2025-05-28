import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FolderSelector extends StatelessWidget {
  final String? selectedDirectory;
  final Function(String?) onDirectorySelected;

  const FolderSelector({
    super.key,
    required this.selectedDirectory,
    required this.onDirectorySelected,
  });

  Future<void> _selectDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      onDirectorySelected(selectedDirectory);
    } catch (e) {
      // 에러는 부모 위젯에서 처리
      onDirectorySelected(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '📁 폴더 선택',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _selectDirectory,
              icon: Icon(Icons.folder_open),
              label: Text(selectedDirectory == null ? '폴더 선택하기' : '폴더 변경하기'),
            ),
            if (selectedDirectory != null) ...[
              SizedBox(height: 8),
              Text(
                '선택된 폴더: $selectedDirectory',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
