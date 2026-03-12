import 'package:equatable/equatable.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';

class TableOne extends StandardTableRecord with EquatableMixin {
  final String message;
  const TableOne({
    required super.entityId,
    required this.message,
    required super.centerId,
    required super.byUser,
    required super.byDevice,
    required super.isDeleted,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
  });

  TableOne copyWith({
    String? message,
    String? entityId,
    String? centerId,
    String? byUser,
    String? byDevice,
    bool? isDeleted,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableOne(
      entityId: entityId ?? this.entityId,
      message: message ?? this.message,
      centerId: centerId ?? this.centerId,
      byUser: byUser ?? this.byUser,
      byDevice: byDevice ?? this.byDevice,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': entityId,
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
    message,
    byUser,
    byDevice,
    isDeleted,
    version,
    createdAt,
    updatedAt,
  ];
}
