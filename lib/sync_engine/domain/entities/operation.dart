import 'package:equatable/equatable.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/operation_status.dart';
import 'package:sync_feature/core/enums/user_role.dart';

class Operation extends Equatable {
  final String centerId;
  final String id;
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

  const Operation({
    required this.id,
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

  Operation copyWith({
    String? centerId,
    String? id,
    String? entityId,
    OperationAction? action,
    DBTable? table,
    Map<String, dynamic>? json,
    int? version,
    UserRole? userRole,
    String? createdBy,
    DateTime? createdAt,
    int? retryCount,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
    OperationState? status,
  }) {
    return Operation(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      centerId: centerId ?? this.centerId,
      action: action ?? this.action,
      table: table ?? this.table,
      json: json ?? this.json,
      version: version ?? this.version,
      userRole: userRole ?? this.userRole,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [
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
}
