import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:link_up/controllers/main_controller.dart';
import 'package:link_up/screens/friends_screen.dart';
import 'package:link_up/theme/app_theme.dart';

import 'find_people_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends GetView<MainController>{
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          // HomeScreen(),
          // FriendsScreen(),
          // UserListScreen(),
          Container(),
          const FriendsScreen(),
           const FindPeopleScreen(),
           const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Obx(()=> BottomNavigationBar(
        currentIndex: controller.currentIndex,
        onTap: controller.changeTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        elevation: 8,
         items: [
          BottomNavigationBarItem(
            icon: _buildIconWithBadge(Icons.chat_outlined, controller.getUnreadCount()),
            activeIcon: _buildIconWithBadge(Icons.chat, controller.getUnreadCount()),
            label: 'Chats',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_search_outlined),
            activeIcon: Icon(Icons.person_search),
            label: 'Find Friends',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Profiles',
          ),

         ],
        
      ))
    );
  }

  Widget _buildIconWithBadge(IconData icon, int badgeCount) {
    return Stack(
      children: [
        Icon(icon),
        if (badgeCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }
}