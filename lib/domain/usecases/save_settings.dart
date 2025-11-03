import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/entities/settings.dart';
import 'package:iptvca/domain/repositories/settings_repository.dart';

class SaveSettings {
  SaveSettings(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(Settings settings) async {
    return await _repository.saveSettings(settings);
  }
}

