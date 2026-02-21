import 'package:equatable/equatable.dart';
import 'package:sync_feature/sync_engine/data/models/standard_table_record_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';

import '../../../../core/isar_service/collections/table_five_collection.dart';

class TableFiveModel extends StandardTableRecordModel with EquatableMixin {
  final String message;
  final String forKeyTableThree;
  final String forKeyTableFour;
  const TableFiveModel({
    required super.entityId,
    required this.message,
    required this.forKeyTableFour,
    required this.forKeyTableThree,
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
    forKeyTableFour,
    forKeyTableThree,
    centerId,
    message,
    byUser,
    byDevice,
    isDeleted,
    version,
    createdAt,
    updatedAt,
  ];

  factory TableFiveModel.fromJson(Map<String, dynamic> json) {
    return TableFiveModel(
      entityId: json['id'],
      forKeyTableFour: json['table_four_id'],
      forKeyTableThree: json['table_three_id'],
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

  factory TableFiveModel.fromCollection(TableFiveCollection collection) {
    return TableFiveModel(
      entityId: collection.entityId,
      centerId: collection.centerId,
      byUser: collection.byUser,
      byDevice: collection.byDevice,
      isDeleted: collection.isDeleted,
      version: collection.version,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
      message: collection.message,
      forKeyTableFour: collection.forKeyTableFour,
      forKeyTableThree: collection.forKeyTableThree,
    );
  }
  factory TableFiveModel.fromEntity(TableFive entity) {
    return TableFiveModel(
      entityId: entity.entityId,
      centerId: entity.centerId,
      byUser: entity.byUser,
      byDevice: entity.byDevice,
      isDeleted: entity.isDeleted,
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      message: entity.message,
      forKeyTableFour: entity.forKeyTableFour,
      forKeyTableThree: entity.forKeyTableThree,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': entityId,
      'table_three_id': forKeyTableThree,
      'table_four_id': forKeyTableFour,
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
  TableFiveCollection toCollection() {
    return TableFiveCollection()
      ..entityId = entityId
      ..forKeyTableThree = forKeyTableThree
      ..forKeyTableFour = forKeyTableFour
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
