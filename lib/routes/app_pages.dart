import 'package:get/get.dart';
import 'package:tiled/app/folders/view/root_folder_tab.dart';
import 'package:tiled/app/search/view/search_screen.dart';
import 'package:tiled/app/home/view/request_screen.dart';
import 'package:tiled/app/home/view/home_screen.dart';
import 'package:tiled/app/folders/view/sub_folder_screen.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/', page: () => RequestScreen()),
    GetPage(name: '/home', page: () => HomeScreen()),
    GetPage(name: '/folder', page: () => RootFolderTab()),
    GetPage(name: '/subfolder', page: () => SubFolderPage()),
    GetPage(name: '/search', page: () => SearchPage()),
  ];
}
