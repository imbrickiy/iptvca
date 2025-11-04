import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/core/storage/storage_interface.dart';
import 'package:iptvca/data/models/settings_model.dart';
import 'package:iptvca/domain/entities/settings.dart';
import 'package:iptvca/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final StorageInterface _storage;

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final jsonString = await _storage.getString(AppConstants.settingsKey);
      if (jsonString == null) {
        return Right(const SettingsModel());
      }
      final json = await compute(_decodeSettingsJson, jsonString);
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
      final json = await compute(_encodeSettingsJson, settingsModel.toJson());
      final success = await _storage.setString(AppConstants.settingsKey, json);
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

  static Map<String, dynamic> _decodeSettingsJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static String _encodeSettingsJson(Map<String, dynamic> json) {
    return jsonEncode(json);
  }
}

