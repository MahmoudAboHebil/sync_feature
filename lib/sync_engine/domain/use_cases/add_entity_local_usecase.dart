import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/use_cases/use_case.dart';

class AddEntityLocalUseCaseParams {
  final DBTable table;
  final Map<String, dynamic>? jsonEntity;
  final StandardTableRecord? entity;
  const AddEntityLocalUseCaseParams({
    required this.table,
    required this.jsonEntity,
    required this.entity,
  });
}

class AddEntityLocalUseCase
    implements UseCase<Either<Failure, void>, AddEntityLocalUseCaseParams> {
  final TableRepository _repository;
  const AddEntityLocalUseCase(this._repository);
  @override
  Future<Either<Failure, void>> call(AddEntityLocalUseCaseParams params) async {
    return await _repository.insertEntityToTable(
      params.table,
      params.jsonEntity,
      params.entity,
    );
  }
}
