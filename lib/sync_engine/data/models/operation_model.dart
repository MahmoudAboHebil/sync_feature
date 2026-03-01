import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/user_role.dart';
import 'package:sync_feature/core/isar_service/collections/operation_collection.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

import '../../../core/enums/operation_status.dart';

class OperationModel extends Equatable {
  final int? id;
  final String centerId;
  final String operationId;
  final String entityId;
  final OperationAction action;
  final DBTable table;
  final Map<String, dynamic> json;
  final int version;
  final UserRole userRole;
  final String createdBy;
  final DateTime createdAt;
  final int retryCount;
  final DateTime lastAttemptAt;
  final DateTime nextRetryAt;
  final OperationState status;

  const OperationModel({
    this.id,
    required this.operationId,
    required this.entityId,
    required this.centerId,
    required this.action,
    required this.table,
    required this.json,
    required this.version,
    required this.userRole,
    required this.createdBy,
    required this.createdAt,
    required this.retryCount,
    required this.lastAttemptAt,
    required this.nextRetryAt,
    required this.status,
  });
  @override
  List<Object?> get props => [
    operationId,
    id,
    entityId,
    centerId,
    action,
    table,
    json,
    version,
    userRole,
    createdBy,
    createdAt,
    retryCount,
    lastAttemptAt,
    nextRetryAt,
    status,
  ];

  OperationCollection toCollection() {
    late final Map<String, dynamic> jsonWithoutDataTime = {};
    for (final v in json.entries) {
      if (v.value is DateTime) {
        jsonWithoutDataTime[v.key] = (v.value as DateTime)
            .toUtc()
            .toIso8601String();
      } else {
        jsonWithoutDataTime[v.key] = v.value;
      }
    }
    return OperationCollection()
      ..operationId = operationId
      ..entityId = entityId
      ..centerId = centerId
      ..action = action.name
      ..table = table.name
      ..payload = jsonEncode(jsonWithoutDataTime)
      ..version = version
      ..userRole = userRole.name
      ..createdBy = createdBy
      ..createdAt = createdAt
      ..retryCount = retryCount
      ..lastAttemptAt = lastAttemptAt
      ..nextRetryAt = nextRetryAt
      ..status = status.name;
  }

  Operation toOperation() {
    return Operation(
      id: operationId,
      entityId: entityId,
      centerId: centerId,
      action: action,
      table: table,
      json: json,
      version: version,
      userRole: userRole,
      createdBy: createdBy,
      createdAt: createdAt,
      lastAttemptAt: lastAttemptAt,
      nextRetryAt: nextRetryAt,
      status: status,
      retryCount: retryCount,
    );
  }

  factory OperationModel.fromOperation(Operation operation) {
    return OperationModel(
      operationId: operation.id,
      entityId: operation.entityId,
      centerId: operation.centerId,
      action: operation.action,
      table: operation.table,
      json: operation.json,
      version: operation.version,
      userRole: operation.userRole,
      createdBy: operation.createdBy,
      createdAt: operation.createdAt,
      lastAttemptAt: operation.lastAttemptAt,
      retryCount: operation.retryCount,
      nextRetryAt: operation.nextRetryAt,
      status: operation.status,
    );
  }

  factory OperationModel.fromCollection(
    OperationCollection operationCollection,
  ) {
    return OperationModel(
      id: operationCollection.id,
      operationId: operationCollection.operationId,
      entityId: operationCollection.entityId,
      centerId: operationCollection.centerId,
      action: OperationAction.getOperationActionFromString(
        operationCollection.action,
      ),
      table: DBTable.getDBTableFromString(operationCollection.table),
      json: jsonDecode(operationCollection.payload),
      version: operationCollection.version,
      userRole: UserRole.getUserRoleFromString(operationCollection.userRole),
      createdBy: operationCollection.createdBy,
      createdAt: operationCollection.createdAt,
      nextRetryAt: operationCollection.nextRetryAt,
      lastAttemptAt: operationCollection.lastAttemptAt,
      retryCount: operationCollection.retryCount,
      status: OperationState.getOperationStateFromString(
        operationCollection.status,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "operation_id": operationId,
      "table": table.name,
      "action": action.name,
      "entity_id": entityId,
      "version": version,
      "center_id": centerId,
      "user_role": userRole.name,
      "table_record": json,
    };
  }
}
