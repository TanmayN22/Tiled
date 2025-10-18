import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';
import 'package:tiled/controllers/nav_controller.dart';
import 'package:tiled/models/folder_model.dart';
import 'package:tiled/models/media_item.dart';
import 'package:tiled/app/home/view/home_screen.dart';
import 'package:tiled/routes/app_pages.dart';
import 'package:tiled/routes/app_routes.dart';

void main() async {
  // ensures flutter binding is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();

  Hive.registerAdapter(FolderModelAdapter());
  Hive.registerAdapter(MediaItemAdapter());

  // Opens a Hive box named "Folders" to store folder data.
  await Hive.openBox<FolderModel>('Folders');

  // Put your controller in GetX dependency injection
  Get.put(FolderController());

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final NavController navController = Get.put(NavController());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tiled',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}
