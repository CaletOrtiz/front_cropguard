import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/features/auth/domain/entities/app_user.dart';

import '../../domain/entities/update_profile_params.dart';
import '../../domain/usecases/update_profile_usecase.dart';

enum EditProfileStatus { idle, saving, success, failure }

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.idle,
    this.user,
    this.message,
  });

  final EditProfileStatus status;

  /// Perfil ya guardado (solo en `success`).
  final AppUser? user;

  /// Mensaje de error (solo en `failure`).
  final String? message;

  bool get isSaving => status == EditProfileStatus.saving;

  @override
  List<Object?> get props => [status, user, message];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._updateProfile) : super(const EditProfileState());

  final UpdateProfileUsecase _updateProfile;

  Future<void> save(UpdateProfileParams params) async {
    if (state.isSaving) return;
    emit(const EditProfileState(status: EditProfileStatus.saving));
    try {
      final user = await _updateProfile(params);
      emit(EditProfileState(status: EditProfileStatus.success, user: user));
    } catch (error) {
      emit(
        EditProfileState(
          status: EditProfileStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
