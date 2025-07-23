import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/controllers/nav_controller.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavController navController = Get.find();
    final List<IconData> navIcons = [Icons.home, Icons.folder, Icons.search];

    return Obx(() {
      return Container(
        height: 65,
        margin: const EdgeInsets.only(right: 35, left: 35, bottom: 50),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              navIcons.map((icon) {
                int index = navIcons.indexOf(icon);
                bool isSelected = navController.selectedIndex.value == index;

                return GestureDetector(
                  onTap: () {
                    navController.changeTab(index);
                  },
                  child: Icon(
                    icon,
                    size: 30,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                );
              }).toList(),
        ),
      );
    });
  }
}
