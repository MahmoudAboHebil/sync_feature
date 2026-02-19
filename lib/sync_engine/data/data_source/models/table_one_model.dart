import 'package:equatable/equatable.dart';
import 'package:sync_feature/core/isar_service/collections/table_one_collection.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/standard_table_record_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';

class TableOneModel extends StandardTableRecordModel with EquatableMixin {
  final String message;
  const TableOneModel({
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
  factory TableOneModel.fromJson(Map<String, dynamic> json) {
    return TableOneModel(
      entityId: json['id'],
      centerId: json['center_id'],
      byUser: json['by_user'],
      byDevice: json['by_device'],
      isDeleted: json['is_deleted'] as bool,
      version: json['version'] as int,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      message: json['message'],
    );
  }
  factory TableOneModel.fromCollection(TableOneCollection collection) {
    return TableOneModel(
      entityId: collection.entityId,
      centerId: collection.centerId,
      byUser: collection.byUser,
      byDevice: collection.byDevice,
      isDeleted: collection.isDeleted,
      version: collection.version,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
      message: collection.message,
    );
  }
  factory TableOneModel.fromEntity(TableOne entity) {
    return TableOneModel(
      entityId: entity.entityId,
      centerId: entity.centerId,
      byUser: entity.byUser,
      byDevice: entity.byDevice,
      isDeleted: entity.isDeleted,
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      message: entity.message,
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
  TableOneCollection toCollection() {
    return TableOneCollection()
      ..entityId = entityId
      ..centerId = centerId
      ..byUser = byUser
      ..byDevice = byDevice
      ..isDeleted = isDeleted
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..message = message;
  }
}
