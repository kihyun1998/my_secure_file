import 'dart:convert';
import 'dart:io';

class SimpleFileEncryption {
  // 전치 암호화를 위한 고정 키 패턴 (자리 재배치 순서)
  static const List<int> _transpositionKey = [3, 1, 4, 0, 2, 6, 5, 7];
  static const int _blockSize = 8;

  /// 텍스트를 전치 암호화로 암호화
  static String _encryptText(String plainText) {
    if (plainText.isEmpty) return '';

    String paddedText = _addPadding(plainText);
    StringBuffer encrypted = StringBuffer();

    for (int i = 0; i < paddedText.length; i += _blockSize) {
      String block = paddedText.substring(
          i,
          i + _blockSize > paddedText.length
              ? paddedText.length
              : i + _blockSize);
      encrypted.write(_encryptBlock(block));
    }

    return encrypted.toString();
  }

  /// 전치 암호화로 암호화된 텍스트를 복호화
  static String _decryptText(String encryptedText) {
    if (encryptedText.isEmpty) return '';

    StringBuffer decrypted = StringBuffer();

    for (int i = 0; i < encryptedText.length; i += _blockSize) {
      String block = encryptedText.substring(
          i,
          i + _blockSize > encryptedText.length
              ? encryptedText.length
              : i + _blockSize);
      decrypted.write(_decryptBlock(block));
    }

    return _removePadding(decrypted.toString());
  }

  /// 블록 단위 암호화 (자리 재배치)
  static String _encryptBlock(String block) {
    List<String> chars = List.filled(_blockSize, '\x00');

    for (int i = 0; i < block.length && i < _blockSize; i++) {
      chars[_transpositionKey[i]] = block[i];
    }

    return chars.join();
  }

  /// 블록 단위 복호화 (자리 재배치 복원)
  static String _decryptBlock(String block) {
    List<String> chars = List.filled(_blockSize, '\x00');

    // 암호화의 역과정
    for (int i = 0; i < block.length && i < _blockSize; i++) {
      int originalPos = _transpositionKey.indexOf(i);
      if (originalPos != -1) {
        chars[originalPos] = block[i];
      }
    }

    return chars.join();
  }

  /// 패딩 추가 (PKCS7 스타일)
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

  /// 간단한 문자 치환을 위한 문자열 변환 (스크램블링 대신)
  static String _simpleTransform(String input) {
    StringBuffer result = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      int charCode = input.codeUnitAt(i);
      // 간단한 XOR 변환 (키: 42)
      int transformed = charCode ^ 42;
      result.writeCharCode(transformed);
    }

    return result.toString();
  }

  /// 간단한 문자 치환 복원 (XOR는 자기 자신이 역함수)
  static String _simpleRestore(String input) {
    return _simpleTransform(input); // XOR는 동일한 연산으로 복원
  }

  /// 파일에 암호화된 데이터 쓰기
  static Future<void> writeEncryptedFile(String filePath, String data) async {
    // 1. 전치 암호화
    String encrypted = _encryptText(data);

    // 2. 간단한 문자 변환
    String transformed = _simpleTransform(encrypted);

    // 3. Base64 인코딩
    String base64Encoded = base64.encode(utf8.encode(transformed));

    // 4. 파일에 쓰기
    File file = File(filePath);
    await file.writeAsString(base64Encoded);
  }

  /// 파일에서 암호화된 데이터 읽고 복호화
  static Future<String> readEncryptedFile(String filePath) async {
    // 1. 파일에서 읽기
    File file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('파일이 존재하지 않습니다', filePath);
    }

    String base64Data = await file.readAsString();

    // 2. Base64 디코딩
    String transformed = utf8.decode(base64.decode(base64Data));

    // 3. 문자 변환 복원
    String encrypted = _simpleRestore(transformed);

    // 4. 전치 복호화
    return _decryptText(encrypted);
  }

  /// 디버깅용 - 단계별 테스트
  static void debugTest(String input) {
    print('=== 디버깅 테스트 ===');
    print('원본: "$input"');

    // 1단계: 전치 암호화
    String encrypted = _encryptText(input);
    print('1. 전치 암호화: "${encrypted.replaceAll('\x00', '\\0')}"');

    // 2단계: 간단한 문자 변환
    String transformed = _simpleTransform(encrypted);
    print(
        '2. 문자 변환: "${transformed.replaceAll('\x00', '\\0').replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"');

    // 3단계: Base64
    String base64Encoded = base64.encode(utf8.encode(transformed));
    print('3. Base64: "$base64Encoded"');

    print('\n=== 복호화 과정 ===');

    // 역과정 1: Base64 디코딩
    String decodedTransformed = utf8.decode(base64.decode(base64Encoded));
    print(
        '1. Base64 디코딩: "${decodedTransformed.replaceAll('\x00', '\\0').replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"');

    // 역과정 2: 문자 변환 복원
    String restoredEncrypted = _simpleRestore(decodedTransformed);
    print('2. 문자 변환 복원: "${restoredEncrypted.replaceAll('\x00', '\\0')}"');

    // 역과정 3: 전치 복호화
    String finalResult = _decryptText(restoredEncrypted);
    print('3. 전치 복호화: "$finalResult"');

    print('\n원본과 일치: ${input == finalResult}');
    print('========================\n');
  }

  /// 문자열 직접 암호화 (파일 저장 없이)
  static String encryptString(String plainText) {
    String encrypted = _encryptText(plainText);
    String transformed = _simpleTransform(encrypted);
    return base64.encode(utf8.encode(transformed));
  }

  /// 암호화된 문자열 직접 복호화
  static String decryptString(String encryptedBase64) {
    String transformed = utf8.decode(base64.decode(encryptedBase64));
    String encrypted = _simpleRestore(transformed);
    return _decryptText(encrypted);
  }
}
