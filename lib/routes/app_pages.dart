import 'package:get/get.dart';
import 'package:tiled/pages/root_folder_tab.dart';
import 'package:tiled/pages/search_screen.dart';
import 'package:tiled/pages/request_screen.dart';
import 'package:tiled/pages/home_screen.dart';
import 'package:tiled/pages/sub_folder_screen.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/', page: () => RequestScreen()),
    GetPage(name: '/home', page: () => HomeScreen()),
    GetPage(name: '/folder', page: () => RootFolderTab()),
    GetPage(name: '/subfolder', page: () => SubFolderPage()),
    GetPage(name: '/search', page: () => SearchPage()),
  ];
}
