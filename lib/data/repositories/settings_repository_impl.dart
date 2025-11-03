import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/core/storage/storage_interface.dart';
import 'package:iptvca/data/models/settings_model.dart';
import 'package:iptvca/domain/entities/settings.dart';
import 'package:iptvca/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final StorageInterface _storage;
  static const String _settingsKey = 'app_settings';

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final jsonString = await _storage.getString(_settingsKey);
      if (jsonString == null) {
        return Right(const SettingsModel());
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final settings = SettingsModel.fromJson(json);
      return Right(settings);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка получения настроек: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(Settings settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      final json = jsonEncode(settingsModel.toJson());
      final success = await _storage.setString(_settingsKey, json);
      if (!success) {
        return Left(CacheFailure(message: 'Ошибка сохранения настроек'));
      }
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка сохранения настроек: $e'));
    }
  }
}

