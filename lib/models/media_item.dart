import 'package:hive_flutter/hive_flutter.dart';
part 'media_item.g.dart';

@HiveType(typeId: 1)
class MediaItem extends HiveObject{
  @HiveField(0)
  String id; // Unique ID for the media

  @HiveField(1)
  String path; // File path on device

  @HiveField(2)
  String type; // "image" or "video"

  @HiveField(3)
  DateTime createdAt; // When it was added to the app

  MediaItem({
    required this.id,
    required this.path,
    required this.type,
    required this.createdAt,
  });
}
