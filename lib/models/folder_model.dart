import 'package:hive_flutter/hive_flutter.dart';
import 'package:tiled/models/media_item.dart';
part 'folder_model.g.dart';

@HiveType(typeId: 0)
class FolderModel extends HiveObject {
  @HiveField(0)
  String id; // Unique ID for the folder (can be a UUID)

  @HiveField(1)
  String name; // Name of the folder (e.g. "Birthday 2024")

  @HiveField(2)
  String? parentId; // If null = root folder, else it's a subfolder

  @HiveField(3)
  List<String> childFolderIds; // IDs of subfolders (optional for navigation)

  @HiveField(4)
  List<MediaItem> mediaItems; // List of photos/videos in this folder

  FolderModel({
    required this.id,
    required this.name,
    this.parentId,
    this.childFolderIds = const [],
    this.mediaItems = const [],
  });
}

