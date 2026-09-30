import 'package:get/get.dart';
import 'package:link_up/controllers/home_controller.dart';
import 'package:link_up/routes/app_routes.dart';
import 'package:link_up/screens/find_people_screen.dart';
import 'package:link_up/screens/home_screen.dart';

import '../controllers/friend_requests_controller.dart';
import '../controllers/friends_contoller.dart';
import '../controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/user_list_controller.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/friend_requests_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/main_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
      }),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    // GetPage(
    //   name: AppRoutes.chat,
    //   page: () => const ChatScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(ChatController());
    //   }),
    // ),
    GetPage(
      name: AppRoutes.userList,
      page: () => const FindPeopleScreen(),
      binding: BindingsBuilder(() {
        Get.put(UserListController());
      }),
    ),
    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendsScreen(),
      binding: BindingsBuilder(() {
        Get.put(FriendsController());
      }),
    ),
    GetPage(
      name: AppRoutes.friendRequests,
      page: () => const FriendRequestsScreen(),
      binding: BindingsBuilder(() {
        Get.put(FriendRequestsController());
      }),
    ),
    // GetPage(
    //   name: AppRoutes.notifications,
    //   page: () => const NotificationsScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(NotificationsController());
    //   }),
    // ),
  ];
}
