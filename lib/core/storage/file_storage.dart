import 'dart:io';
import 'package:iptvca/core/storage/storage_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileStorage implements StorageInterface {
  FileStorage(this._storageDir);
  final Directory _storageDir;

  static Future<FileStorage> create() async {
    final directory = await getApplicationSupportDirectory();
    final storageDir = Directory(path.join(directory.path, 'storage'));
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    return FileStorage(storageDir);
  }

  File _getFileForKey(String key) {
    return File(path.join(_storageDir.path, '$key.json'));
  }

  @override
  Future<String?> getString(String key) async {
    try {
      final file = _getFileForKey(key);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      final file = _getFileForKey(key);
      await file.writeAsString(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      final file = _getFileForKey(key);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      if (await _storageDir.exists()) {
        await for (final entity in _storageDir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

