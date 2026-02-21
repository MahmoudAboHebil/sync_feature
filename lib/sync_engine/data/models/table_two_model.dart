import 'package:equatable/equatable.dart';
import 'package:sync_feature/core/isar_service/collections/table_two_collection.dart';
import 'package:sync_feature/sync_engine/data/models/standard_table_record_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_two.dart';

class TableTwoModel extends StandardTableRecordModel with EquatableMixin {
  final String message;
  final String forkeyTableOne;
  const TableTwoModel({
    required super.entityId,
    required this.forkeyTableOne,
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
    forkeyTableOne,
    centerId,
    message,
    byUser,
    byDevice,
    isDeleted,
    version,
    createdAt,
    updatedAt,
  ];
  factory TableTwoModel.fromJson(Map<String, dynamic> json) {
    return TableTwoModel(
      forkeyTableOne: json['table_one_id'],
      entityId: json['id'],
      centerId: json['center_id'],
      byUser: json['by_user'],
      byDevice: json['by_device'],
      isDeleted: json['is_deleted'] as bool,
      version: json['version'] as int,

      createdAt: DateTime.parse(json['created_at']).toUtc(),
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
      message: json['message'],
    );
  }
  factory TableTwoModel.fromCollection(TableTwoCollection collection) {
    return TableTwoModel(
      entityId: collection.entityId,
      centerId: collection.centerId,
      byUser: collection.byUser,
      byDevice: collection.byDevice,
      isDeleted: collection.isDeleted,
      version: collection.version,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
      message: collection.message,
      forkeyTableOne: collection.forKeyTableOne,
    );
  }
  factory TableTwoModel.fromEntity(TableTwo entity) {
    return TableTwoModel(
      entityId: entity.entityId,
      centerId: entity.centerId,
      byUser: entity.byUser,
      byDevice: entity.byDevice,
      isDeleted: entity.isDeleted,
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      message: entity.message,
      forkeyTableOne: entity.forkeyTableOne,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': entityId,
      'table_one_id': forkeyTableOne,
      'center_id': centerId,
      'by_user': byUser,
      'by_device': byDevice,
      'is_deleted': isDeleted,
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'message': message,
    };
  }

  @override
  TableTwoCollection toCollection() {
    return TableTwoCollection()
      ..entityId = entityId
      ..forKeyTableOne = forkeyTableOne
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
