import 'package:sync_feature/core/error/netwrok_response.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

import '../enums/DB_Table.dart';

class SyncResponse {
  final Operation operation;
  final bool isError;
  final bool willTry;
  final NetworkResponse networkResponse;
  final Map<DBTable, List<String>>? deletedEntities;
  const SyncResponse({
    required this.networkResponse,
    required this.operation,
    required this.deletedEntities,
    required this.willTry,
    this.isError = false,
  });

  @override
  String toString() {
    return """
    operation = ${operation.id}
    networkResponse = ${networkResponse.toString()}
    isError     = ${isError}
    willTry     = ${willTry}
    deletedEntities     = ${deletedEntities}
    
    """;
  }
}
