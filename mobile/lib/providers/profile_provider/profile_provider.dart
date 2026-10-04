import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/failure.dart';

import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/profile_info/profile_model.dart';
import 'package:mobile/repository/profile_repo/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiProvider).dio);
});

/// Profil ma'lumotlari. Xatoda Failure throw qilinadi (AsyncValue.error).
final profileProvider = FutureProvider.autoDispose<ProfileModel>((ref) async {
  final result = await ref.watch(profileRepositoryProvider).fetchProfile();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// state = saqlanmoqdami (tugmani bloklash uchun).
/// Metodlar xato xabarini qaytaradi, muvaffaqiyatda null.
class ProfileController extends Notifier<bool> {
  @override
  bool build() => false;

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  Future<String?> update({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    File? avatar,
  }) async {
    state = true;
    final result = await _repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      avatar: avatar,
    );
    state = false;
    switch (result) {
      case Success():
        ref.invalidate(profileProvider);
        return null;
      case Error(:final failure):
        return _errorMessage(failure);
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = true;
    final result = await _repo.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    state = false;
    switch (result) {
      case Success():
        return null;
      case Error(:final failure):
        return _errorMessage(failure);
    }
  }

  Future<String?> deleteAccount() async {
    state = true;
    final result = await _repo.deleteAccount();
    state = false;
    switch (result) {
      case Success():
        return null;
      case Error(:final failure):
        return _errorMessage(failure);
    }
  }
  String _errorMessage(Failure failure) {
  if (failure is ValidationFailure) {
    final errors = failure.errors; // <-- ValidationFailure ichidagi map maydoni nomi
    if (errors.isNotEmpty) {
      final first = errors.values.first;
      return (first is List && first.isNotEmpty ? first.first : first).toString();
    }
  }
  return failure.message;
}
}

final profileControllerProvider =
    NotifierProvider<ProfileController, bool>(ProfileController.new);