import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/entities/settings.dart';
import 'package:iptvca/domain/repositories/settings_repository.dart';

class GetSettings {
  GetSettings(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, Settings>> call() async {
    return await _repository.getSettings();
  }
}

