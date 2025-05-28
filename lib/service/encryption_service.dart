import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

    for (int i = 0; i < block.length && i < _blockSize; i++) {
      chars[i] = block[_transpositionKey[i]];
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

  /// 추가 난독화를 위한 문자열 뒤섞기
  static String _scrambleString(String input) {
    List<String> chars = input.split('');
    Random random = Random(42); // 고정 시드로 일관성 보장

    for (int i = chars.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      String temp = chars[i];
      chars[i] = chars[j];
      chars[j] = temp;
    }

    return chars.join();
  }

  /// 뒤섞인 문자열 복원
  static String _unscrambleString(String input) {
    List<String> chars = input.split('');
    List<int> indices = [];
    Random random = Random(42); // 동일한 시드 사용

    for (int i = chars.length - 1; i > 0; i--) {
      indices.add(random.nextInt(i + 1));
    }

    for (int i = 0; i < indices.length; i++) {
      int originalI = chars.length - 1 - i;
      int j = indices[i];
      String temp = chars[originalI];
      chars[originalI] = chars[j];
      chars[j] = temp;
    }

    return chars.join();
  }

  /// 파일에 암호화된 데이터 쓰기
  static Future<void> writeEncryptedFile(String filePath, String data) async {
    // 1. 전치 암호화
    String encrypted = _encryptText(data);

    // 2. 추가 난독화
    String scrambled = _scrambleString(encrypted);

    // 3. Base64 인코딩
    String base64Encoded = base64.encode(utf8.encode(scrambled));

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
    String scrambled = utf8.decode(base64.decode(base64Data));

    // 3. 난독화 해제
    String encrypted = _unscrambleString(scrambled);

    // 4. 전치 복호화
    return _decryptText(encrypted);
  }
}
