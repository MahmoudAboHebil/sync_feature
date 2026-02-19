import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/use_cases/use_case.dart';

class AddEntityLocalParams {
  final DBTable table;
  final Map<String, dynamic>? jsonEntity;
  final StandardTableRecord? entity;
  const AddEntityLocalParams({
    required this.table,
    required this.jsonEntity,
    required this.entity,
  });
}

class AddEntityLocal
    implements UseCase<Either<Failure, void>, AddEntityLocalParams> {
  final TableRepository _repository;
  const AddEntityLocal(this._repository);
  @override
  Future<Either<Failure, void>> call(AddEntityLocalParams params) async {
    return await _repository.insertEntityToTable(
      params.table,
      params.jsonEntity,
      params.entity,
    );
  }
}
