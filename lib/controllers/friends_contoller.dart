import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/controllers/auth_controller.dart';
import 'package:link_up/models/friend_ship_model.dart';
import 'package:link_up/models/user_model.dart';
import 'package:link_up/routes/app_routes.dart';
import 'package:link_up/services/firestore_service.dart';

class FriendsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<FriendShipModel> _friendships = <FriendShipModel>[].obs;
  final RxList<UserModel> _friends = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;

  StreamSubscription? _friendshipsSubscriptions;

  List<FriendShipModel> get friendships => _friendships.toList();
  List<UserModel> get friends => _friends;
  List<UserModel> get filteredFriends => _filteredFriends;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    _loadFriends();

    debounce(
      _searchQuery,
      (_) => _filterFriends(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _friendshipsSubscriptions?.cancel();
    super.onClose();
   }
   
   void _loadFriends() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _friendshipsSubscriptions?.cancel();

      _friendshipsSubscriptions = _firestoreService.getFriendsStream(currentUserId).listen((friendshipsList) {
        _friendships.value = friendshipsList;
        _loadFriendsDetails(currentUserId, friendshipsList);
      });
    }
   }

   Future<void> _loadFriendsDetails(String currentUserId, List<FriendShipModel> friendshipsList) async {
   

    try {
      _isLoading.value = true;

      List<UserModel> friendsUsers = [];

      final futures = friendshipsList.map((friendship) async {
        String friendId = friendship.getOtherUserId(currentUserId);
        return await _firestoreService.getUser(friendId);
      }).toList();
      final results = await Future.wait(futures);

      for (var friend in results) {
        if (friend != null) {
          friendsUsers.add(friend);
        }
      }

      _friends.value = friendsUsers;
      _filterFriends();
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
   }
  }
  
  void _filterFriends() {
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredFriends.value = _friends;
    } else {
      _filteredFriends.value = _friends.where((friend) {
        return friend.displayName.toLowerCase().contains(query) ||
            friend.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> refreshFriends() async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _loadFriends();
    }
  }

  Future<void> removeFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Remove Friend'),
          content: Text('Are you sure you want to remove ${friend.displayName} from your friends?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _firestoreService.removeFriendship(currentUserId, friend.id);
          Get.snackbar('Success',
          "${friend.displayName} has been removed from your friends.",
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
          );
        }
      }
        
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove friend.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> blockFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Block User'),
          content: Text('Are you sure you want to block ${friend.displayName}? This will remove them from your friends and prevent them from contacting you.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Block'),
            ),
          ],
        ),
      );

      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _firestoreService.blockUser(currentUserId, friend.id);
          Get.snackbar('Success',
          "${friend.displayName} has been blocked.",
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
          );
        }
      }
        
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel friend) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        Get.toNamed(AppRoutes.chat, arguments: {
          'chatId':null, 
          'otherUser': friend,
          'isNewChat': true,
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start chat.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  String getLastSeenText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen);
      if (difference.inMinutes < 1) {
        return 'Last seen just now';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes} mins ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inHours} h ago';
      } else if (difference.inDays < 7) {
        return 'Last seen ${difference.inDays} d ago';
      } else {
        return 'Last seen ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }

  void openFriendRequests() {
    Get.toNamed(AppRoutes.friendRequests);
  }

  void clearError() {
    _error.value = '';
  }
}
