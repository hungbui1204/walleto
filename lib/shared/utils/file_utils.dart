import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// English:
  /// If set, we want to save all files into a specific folder.
  ///
  /// Japanese:
  /// 設定されている場合、すべてのファイルを特定のフォルダに保存することを望みます。
  static String? defaultDir;

  /// English:
  /// Returns the path to the cookie directory.
  ///
  /// If the platform is not web, it retrieves the application document directory
  /// and appends '/cookies/' to the path. If the document directory cannot be
  /// obtained, an empty string is returned. If the platform is web, an empty
  /// string is returned.
  ///
  /// Japanese:
  /// クッキーディレクトリへのパスを返します。
  ///
  /// プラットフォームがWebでない場合、アプリケーションのドキュメントディレクトリを取得し、
  /// パスに「/cookies/」を追加します。ドキュメントディレクトリを取得できない場合は、
  /// 空の文字列が返されます。プラットフォームがWebの場合は、空の文字列が返されます。
  static Future<String> getCookiePath() async {
    if (!kIsWeb) {
      final appDocDir = await _getDocumentDir();

      if (appDocDir == null) {
        return '';
      }

      return '${appDocDir.path}/cookies/';
    } else {
      return '';
    }
  }

  /// English:
  /// Read content of file by file-name
  ///
  /// Example:
  /// ```dart
  /// final fileContent = await FileUtils.readFile('temp-file.txt');
  ///
  /// // read png image from cached folder
  /// final pngContent = await FileUtils.readFile('my-avatar.png', temporary: true);
  /// ```
  ///
  /// Japanese:
  /// ファイル名でファイルのコンテンツを読み取ります
  ///
  /// 例：
  /// ```dart
  /// final fileContent = await FileUtils.readFile('temp-file.txt');
  ///
  /// // キャッシュフォルダからpng画像を読み取る
  /// final pngContent = await FileUtils.readFile('my-avatar.png', temporary: true);
  /// ```
  static Future<Uint8List?> readFile(String filename, {bool temporary = false}) async {
    final theFile = await _getFile(filename, temporary: temporary);
    if (theFile != null) {
      return await theFile.readAsBytes();
    }

    return null;
  }

  /// English:
  /// Write content to a file by file-name.
  ///
  /// Japanese:
  /// ファイル名でファイルにコンテンツを書き込みます。
  static Future<File> writeFileAsBytes(
    String filename,
    List<int> bytes, {
    bool temporary = false,
    bool download = false,
    bool override = false,
  }) async {
    final theFile = await _getFile(filename, temporary: temporary, download: download);
    if (theFile == null) {
      final newFilePath = await _filePath(filename, temporary: temporary, download: download);

      final file = await File(newFilePath).writeAsBytes(bytes);

      // Android only
      // Android 10+ requires the MediaScanner to be called to refresh media files
      if (Platform.isAndroid) {
        await MediaScanner.loadMedia(path: file.path);
      }

      return file;
    } else {
      if (override) {
        return await theFile.writeAsBytes(bytes);
      } else {
        final oldFileName = filename.split('.').toList();
        var fileExtension = '';
        if (oldFileName.length > 1) {
          fileExtension = '.${oldFileName.removeLast()}';
        }

        final newFileName =
            '${oldFileName.join('.')}_${(DateTime.now().millisecondsSinceEpoch) / 1000}$fileExtension';

        return await writeFileAsBytes(newFileName, bytes, temporary: temporary, override: override);
      }
    }
  }

  /// English:
  /// Write content to a file by file-name.
  ///
  /// Japanese:
  /// ファイル名でファイルにコンテンツを書き込みます。
  static Future<File> writeFileAsString(
    String filename,
    String content, {
    bool temporary = false,
    bool download = false,
    bool override = false,
  }) async {
    final theFile = await _getFile(filename, temporary: temporary, download: download);
    if (theFile == null) {
      final newFilePath = await _filePath(filename, temporary: temporary, download: download);

      return await File(newFilePath).writeAsString(content);
    } else {
      if (override) {
        return await theFile.writeAsString(content);
      } else {
        final oldFileName = filename.split('.').toList();
        var fileExtension = '';
        if (oldFileName.length > 1) {
          fileExtension = '.${oldFileName.removeLast()}';
        }

        final newFileName =
            '${oldFileName.join('.')}_${(DateTime.now().millisecondsSinceEpoch) / 1000}$fileExtension';

        return await writeFileAsString(
          newFileName,
          content,
          temporary: temporary,
          override: override,
        );
      }
    }
  }

  static bool isExistFile(String filePath) {
    return File(filePath).existsSync();
  }

  static bool isExistFolder(String folderPath) {
    return Directory(folderPath).existsSync();
  }

  static bool isFolder(String filePath) {
    return FileSystemEntity.typeSync(filePath) == FileSystemEntityType.directory;
  }

  static Future<bool> removeFile(String filePath) async {
    try {
      await File(filePath).delete(recursive: true);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// English:
  /// Get temporary directory for App. If `defaultDir` is not set, all files will not be save into
  /// a specific folder.
  ///
  /// A temporary directory (cache) that the system can clear at any time.
  ///
  /// Return `null` if there are any exception.
  ///
  /// Japanese:
  /// アプリの一時ディレクトリを取得します。 `defaultDir`が設定されていない場合、
  /// すべてのファイルは特定のフォルダに保存されません。
  ///
  /// システムは、いつでもクリアできる一時ディレクトリ（キャッシュ）です。
  ///
  /// 例外がある場合は、`null`を返します。
  static Future<Directory?> _getTemporaryDir() async {
    try {
      final directory = await getTemporaryDirectory();
      final tempDirPath = '${directory.path}${defaultDir != null ? '/$defaultDir' : ''}';
      final tempDir = Directory(tempDirPath);
      if (!(await tempDir.exists())) {
        return await tempDir.create(recursive: true);
      }

      return tempDir;
    } on MissingPlatformDirectoryException catch (_) {}

    return null;
  }

  /// English:
  /// Get document directory for App. If `defaultDir` is not set, all files will not be save into
  /// a specific folder.
  ///
  /// The system clears the directory only when the app is deleted.
  ///
  /// Return `null` if there are any exception.
  ///
  /// Japanese:
  /// アプリのドキュメントディレクトリを取得します。 `defaultDir`が設定されていない場合、
  /// すべてのファイルは特定のフォルダに保存されません。
  ///
  /// システムは、アプリが削除されたときにのみディレクトリをクリアします。
  ///
  /// 例外がある場合は、`null`を返します。
  static Future<Directory?> _getDocumentDir() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final documentPath = '${directory.path}${defaultDir != null ? '/$defaultDir' : ''}';
      final documentDir = Directory(documentPath);
      if (!(await documentDir.exists())) {
        return await documentDir.create(recursive: true);
      }

      return documentDir;
    } on MissingPlatformDirectoryException catch (_) {}

    return null;
  }

  /// English:
  /// Get download directory for App. If `defaultDir` is not set, all files will not be save into
  /// a specific folder.
  ///
  /// The system clears the directory only when the app is deleted.
  ///
  /// Return `null` if there are any exception.
  ///
  /// Japanese:
  /// アプリのダウンロードディレクトリを取得します。 `defaultDir`が設定されていない場合、
  /// すべてのファイルは特定のフォルダに保存されません。
  ///
  /// システムは、アプリが削除されたときにのみディレクトリをクリアします。
  ///
  /// 例外がある場合は、`null`を返します。
  static Future<Directory?> _getDownloadDir() async {
    try {
      final directory =
          Platform.isAndroid
              ? Directory('/storage/emulated/0/Download')
              : await getApplicationDocumentsDirectory();
      final documentPath = '${directory.path}${defaultDir != null ? '/$defaultDir' : ''}';
      final downloadDir = Directory(documentPath);
      if (!(await downloadDir.exists())) {
        return await downloadDir.create(recursive: true);
      }

      return downloadDir;
    } on MissingPlatformDirectoryException catch (_) {}

    return null;
  }

  /// English:
  /// Get file object from filename. If file is not exists, return `null`.
  ///
  /// Japanese:
  /// ファイル名からファイルオブジェクトを取得します。ファイルが存在しない場合は、`null`を返します。
  static Future<File?> _getFile(
    String filename, {
    bool temporary = false,
    bool download = false,
  }) async {
    final filePath = await _filePath(filename, temporary: temporary, download: download);
    final file = File(filePath);

    return (await file.exists()) ? file : null;
  }

  /// English:
  /// Return `file-path` according to either download folder or temporary folder or document folder.
  ///
  /// Japanese:
  /// ダウンロードフォルダまたは一時フォルダまたはドキュメントフォルダに応じて、`ファイルパス`を返します。
  static Future<String> _filePath(
    String filename, {
    bool temporary = false,
    bool download = false,
  }) async {
    if (temporary) {
      return '${(await _getTemporaryDir())?.path ?? ''}/$filename';
    }

    return download
        ? '${(await _getDownloadDir())?.path ?? ''}/$filename'
        : '${(await _getDocumentDir())?.path ?? ''}/$filename';
  }
}
