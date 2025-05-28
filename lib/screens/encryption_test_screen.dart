import 'package:flutter/material.dart';
import 'package:my_secure_file/service/encryption_service.dart';
import 'package:path/path.dart' as path;

import '../widgets/action_buttons.dart';
import '../widgets/file_name_input.dart';
import '../widgets/folder_selector.dart';
import '../widgets/text_input_area.dart';

class EncryptionTestScreen extends StatefulWidget {
  const EncryptionTestScreen({super.key});

  @override
  _EncryptionTestScreenState createState() => _EncryptionTestScreenState();
}

class _EncryptionTestScreenState extends State<EncryptionTestScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  String? _selectedDirectory;
  String _statusMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'encrypted_data.txt'; // 기본 파일명
  }

  // 폴더 선택 콜백
  void _onDirectorySelected(String? directory) {
    setState(() {
      _selectedDirectory = directory;
      if (directory != null) {
        _statusMessage = '폴더 선택됨: $directory';
      } else {
        _statusMessage = '폴더 선택이 취소되었거나 오류가 발생했습니다.';
      }
    });
  }

  // 파일 쓰기
  Future<void> _writeFile() async {
    if (_selectedDirectory == null) {
      setState(() {
        _statusMessage = '먼저 폴더를 선택해주세요!';
      });
      return;
    }

    if (_fileNameController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '파일명을 입력해주세요!';
      });
      return;
    }

    if (_textController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '암호화할 텍스트를 입력해주세요!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '파일 쓰는 중...';
    });

    try {
      String filePath =
          path.join(_selectedDirectory!, _fileNameController.text.trim());

      await ImprovedEncryption.writeEncryptedFile(
          filePath, _textController.text);

      setState(() {
        _statusMessage = '✅ 파일이 성공적으로 암호화되어 저장되었습니다!\n경로: $filePath';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ 파일 쓰기 오류: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 파일 읽기
  Future<void> _readFile() async {
    if (_selectedDirectory == null) {
      setState(() {
        _statusMessage = '먼저 폴더를 선택해주세요!';
      });
      return;
    }

    if (_fileNameController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '파일명을 입력해주세요!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '파일 읽는 중...';
    });

    try {
      String filePath =
          path.join(_selectedDirectory!, _fileNameController.text.trim());

      String decryptedData =
          await ImprovedEncryption.readEncryptedFile(filePath);

      setState(() {
        _textController.text = decryptedData;
        _statusMessage = '✅ 파일이 성공적으로 복호화되었습니다!\n경로: $filePath';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ 파일 읽기 오류: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 텍스트 필드 클리어
  void _clearText() {
    setState(() {
      _textController.clear();
      _statusMessage = '텍스트가 클리어되었습니다.';
    });
  }

  // 간단한 암호화 테스트
  void _runSimpleTest() {
    setState(() {
      _statusMessage = '간단한 테스트 실행 중...';
    });

    try {
      String testInput = "Hello World!";

      // 디버그 정보를 콘솔에 출력
      ImprovedEncryption.debugTest(testInput);

      // 직접 암호화/복호화 테스트
      String encrypted = ImprovedEncryption.encryptString(testInput);
      String decrypted = ImprovedEncryption.decryptString(encrypted);

      setState(() {
        _statusMessage = '''✅ 간단한 테스트 완료!
원본: "$testInput"
복호화 결과: "$decrypted"
성공: ${testInput == decrypted}

자세한 디버그 정보는 콘솔을 확인하세요.''';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ 테스트 오류: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파일 암호화 테스트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 폴더 선택 섹션
            FolderSelector(
              selectedDirectory: _selectedDirectory,
              onDirectorySelected: _onDirectorySelected,
            ),

            SizedBox(height: 16),

            // 파일명 입력
            FileNameInput(
              controller: _fileNameController,
            ),

            SizedBox(height: 16),

            // 텍스트 입력 섹션
            Expanded(
              child: TextInputArea(
                controller: _textController,
                onClear: _clearText,
              ),
            ),

            SizedBox(height: 16),

            // 버튼 섹션
            ActionButtons(
              isLoading: _isLoading,
              onWrite: _writeFile,
              onRead: _readFile,
            ),

            SizedBox(height: 8),

            // 테스트 버튼
            ElevatedButton.icon(
              onPressed: _runSimpleTest,
              icon: Icon(Icons.bug_report),
              label: Text('간단한 암호화 테스트'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 16),

            // 상태 메시지
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _statusMessage.isEmpty ? '상태 메시지가 여기에 표시됩니다.' : _statusMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: _statusMessage.contains('❌')
                      ? Colors.red
                      : _statusMessage.contains('✅')
                          ? Colors.green
                          : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }
}
