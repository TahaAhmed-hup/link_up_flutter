import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/controllers/auth_controller.dart';
import 'package:link_up/models/user_model.dart';
import 'package:link_up/services/firestore_service.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  StreamSubscription<UserModel?>? _userSubscription;

  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final RxString _error = ''.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;
  bool get isEditing => _isEditing.value;
  String get error => _error.value;
  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    displayNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _userSubscription =
          _firestoreService.getUserStream(currentUserId).listen(
        (user) {
          _currentUser.value = user;

          if (user != null) {
            displayNameController.text = user.displayName;
            emailController.text = user.email;
          }
        },
        onError: (error) {
          _error.value = error.toString();
        },
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _userSubscription?.cancel();
      _userSubscription = null;
      _currentUser.value = null;

      await _authController.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (result == true) {
        _isLoading.value = true;

        await _userSubscription?.cancel();
        _userSubscription = null;
        _currentUser.value = null;

        await _authController.deleteAccount();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account');
    } finally {
      _isLoading.value = false;
    }
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;

    if (!_isEditing.value) {
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        emailController.text = user.email;
      }
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final user = _currentUser.value;
      if (user == null) return;

      final updateUser = user.copyWith(displayName: displayNameController.text);

      await _firestoreService.updateUser(updateUser);
      _isEditing.value = false;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update Profile');
    } finally {
      _isLoading.value = false;
    }
  }

  String getJoinedData() {
    final user = _currentUser.value;
    if (user == null) return '';

    final date = user.createdAt;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return 'Joined ${months[date.month - 1]} ${date.year}';
  }

  void clearError() {
    _error.value = '';
  }
}
