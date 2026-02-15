import 'package:equatable/equatable.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
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
  });
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
  ];
}
