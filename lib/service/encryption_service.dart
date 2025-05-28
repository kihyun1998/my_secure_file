import 'dart:convert';
import 'dart:io';

class ImprovedEncryption {
  // 다중 라운드를 위한 서로 다른 키들
  static const List<List<int>> _transpositionKeys = [
    [3, 1, 4, 0, 2, 6, 5, 7], // 라운드 1
    [5, 2, 7, 1, 4, 0, 6, 3], // 라운드 2
    [1, 6, 3, 5, 0, 7, 2, 4], // 라운드 3
  ];

  // 치환 테이블 (문자 자체를 바꿈)
  static const String _substitutionTable =
      'zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const String _originalTable =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';

  static const int _blockSize = 8;
  static const int _rounds = 3;

  /// 개선된 암호화 - 치환 + 다중 라운드 전치 + XOR
  static String _improvedEncrypt(String plainText) {
    if (plainText.isEmpty) return '';

    String text = plainText;

    // 1단계: 치환 암호화 (문자 자체를 바꿈)
    text = _substituteText(text);

    // 2단계: 패딩 추가
    text = _addPadding(text);

    // 3단계: 다중 라운드 전치 암호화
    for (int round = 0; round < _rounds; round++) {
      text = _multiRoundTransposition(text, round);
    }

    // 4단계: XOR 변환 (라운드별로 다른 키)
    text = _multiXorTransform(text);

    return text;
  }

  /// 개선된 복호화
  static String _improvedDecrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';

    String text = encryptedText;

    // 역순으로 복원
    // 4단계: XOR 복원
    text = _multiXorRestore(text);

    // 3단계: 다중 라운드 전치 복원 (역순)
    for (int round = _rounds - 1; round >= 0; round--) {
      text = _multiRoundTranspositionReverse(text, round);
    }

    // 2단계: 패딩 제거
    text = _removePadding(text);

    // 1단계: 치환 복원
    text = _restoreSubstitution(text);

    return text;
  }

  /// 치환 암호화 (각 문자를 다른 문자로 바꿈)
  static String _substituteText(String text) {
    StringBuffer result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      int index = _originalTable.indexOf(char);

      if (index != -1) {
        result.write(_substitutionTable[index]);
      } else {
        result.write(char); // 테이블에 없으면 그대로
      }
    }

    return result.toString();
  }

  /// 치환 복원
  static String _restoreSubstitution(String text) {
    StringBuffer result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      int index = _substitutionTable.indexOf(char);

      if (index != -1) {
        result.write(_originalTable[index]);
      } else {
        result.write(char);
      }
    }

    return result.toString();
  }

  /// 다중 라운드 전치 암호화
  static String _multiRoundTransposition(String text, int round) {
    StringBuffer result = StringBuffer();
    List<int> key = _transpositionKeys[round % _transpositionKeys.length];

    for (int i = 0; i < text.length; i += _blockSize) {
      String block = text.substring(
          i, i + _blockSize > text.length ? text.length : i + _blockSize);
      result.write(_transpositionBlock(block, key));
    }

    return result.toString();
  }

  /// 다중 라운드 전치 복원
  static String _multiRoundTranspositionReverse(String text, int round) {
    StringBuffer result = StringBuffer();
    List<int> key = _transpositionKeys[round % _transpositionKeys.length];

    for (int i = 0; i < text.length; i += _blockSize) {
      String block = text.substring(
          i, i + _blockSize > text.length ? text.length : i + _blockSize);
      result.write(_transpositionBlockReverse(block, key));
    }

    return result.toString();
  }

  /// 블록 전치
  static String _transpositionBlock(String block, List<int> key) {
    List<String> chars = List.filled(_blockSize, '\x00');

    for (int i = 0; i < block.length && i < _blockSize; i++) {
      chars[key[i]] = block[i];
    }

    return chars.join();
  }

  /// 블록 전치 복원
  static String _transpositionBlockReverse(String block, List<int> key) {
    List<String> chars = List.filled(_blockSize, '\x00');

    for (int i = 0; i < block.length && i < _blockSize; i++) {
      int originalPos = key.indexOf(i);
      if (originalPos != -1) {
        chars[originalPos] = block[i];
      }
    }

    return chars.join();
  }

  /// 다중 XOR 변환 (각 문자마다 다른 키)
  static String _multiXorTransform(String input) {
    StringBuffer result = StringBuffer();
    List<int> xorKeys = [42, 17, 89, 156, 73, 201, 38, 124]; // 8개 키

    for (int i = 0; i < input.length; i++) {
      int charCode = input.codeUnitAt(i);
      int keyIndex = i % xorKeys.length;
      int transformed = charCode ^ xorKeys[keyIndex];
      result.writeCharCode(transformed);
    }

    return result.toString();
  }

  /// 다중 XOR 복원
  static String _multiXorRestore(String input) {
    return _multiXorTransform(input); // XOR는 자기 역함수
  }

  /// 패딩 추가
  static String _addPadding(String text) {
    int padding = _blockSize - (text.length % _blockSize);
    if (padding == 0) padding = _blockSize;

    String paddingChar = String.fromCharCode(padding);
    return text + (paddingChar * padding);
  }

  /// 패딩 제거
  static String _removePadding(String text) {
    if (text.isEmpty) return text;

    int paddingLength = text.codeUnitAt(text.length - 1);
    if (paddingLength > 0 && paddingLength <= _blockSize) {
      return text.substring(0, text.length - paddingLength);
    }

    return text;
  }

  /// 파일에 암호화하여 저장
  static Future<void> writeEncryptedFile(String filePath, String data) async {
    String encrypted = _improvedEncrypt(data);
    String base64Encoded = base64.encode(utf8.encode(encrypted));

    File file = File(filePath);
    await file.writeAsString(base64Encoded);
  }

  /// 파일에서 복호화하여 읽기
  static Future<String> readEncryptedFile(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('파일이 존재하지 않습니다', filePath);
    }

    String base64Data = await file.readAsString();
    String encrypted = utf8.decode(base64.decode(base64Data));
    return _improvedDecrypt(encrypted);
  }

  /// 디버깅용 테스트
  static void debugTest(String input) {
    print('=== 개선된 암호화 테스트 ===');
    print('원본: "$input"');

    String encrypted = _improvedEncrypt(input);
    print(
        '암호화: "${encrypted.replaceAll('\x00', '\\0').replaceAll('\n', '\\n')}"');

    String decrypted = _improvedDecrypt(encrypted);
    print('복호화: "$decrypted"');

    print('성공: ${input == decrypted}');
    print('================================\n');
  }

  /// 문자열 직접 암호화
  static String encryptString(String plainText) {
    String encrypted = _improvedEncrypt(plainText);
    return base64.encode(utf8.encode(encrypted));
  }

  /// 문자열 직접 복호화
  static String decryptString(String encryptedBase64) {
    String encrypted = utf8.decode(base64.decode(encryptedBase64));
    return _improvedDecrypt(encrypted);
  }
}
