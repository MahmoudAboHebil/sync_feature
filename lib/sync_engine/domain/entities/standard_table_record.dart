abstract class StandardTableRecord {
  final String entityId;
  final String centerId;
  final String byUser;
  final String byDevice;
  final bool isDeleted;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StandardTableRecord({
    required this.entityId,
    required this.centerId,
    required this.byUser,
    required this.byDevice,
    required this.isDeleted,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });
  Map<String, dynamic> toJson();
  Object toCollection();
}
