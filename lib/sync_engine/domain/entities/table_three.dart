import 'package:equatable/equatable.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';

class TableThree extends StandardTableRecord with EquatableMixin {
  final String message;
  final String forKeyTableTwo;

  const TableThree({
    required super.entityId,
    required this.message,
    required this.forKeyTableTwo,
    required super.centerId,
    required super.byUser,
    required super.byDevice,
    required super.isDeleted,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': entityId,
      'table_two_id': forKeyTableTwo,
      'center_id': centerId,
      'by_user': byUser,
      'by_device': byDevice,
      'is_deleted': isDeleted,
      'version': version,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'message': message,
    };
  }

  @override
  List<Object> get props => [
    entityId,
    centerId,
    forKeyTableTwo,
    message,
    byUser,
    byDevice,
    isDeleted,
    version,
    createdAt,
    updatedAt,
  ];
}
