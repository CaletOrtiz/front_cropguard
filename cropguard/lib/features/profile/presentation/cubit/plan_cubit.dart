import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/auth/domain/entities/app_user.dart';
import 'package:kroppi/features/auth/domain/usecases/get_current_user_usecase.dart';

import '../../domain/usecases/create_premium_checkout_usecase.dart';

class PlanState extends Equatable {
  const PlanState({
    this.user,
    this.isRefreshingProfile = false,
    this.isCreatingCheckout = false,
    this.errorMessage,
  });

  final AppUser? user;
  final bool isRefreshingProfile;
  final bool isCreatingCheckout;
  final String? errorMessage;

  PlanState copyWith({
    AppUser? user,
    bool? isRefreshingProfile,
    bool? isCreatingCheckout,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlanState(
      user: user ?? this.user,
      isRefreshingProfile: isRefreshingProfile ?? this.isRefreshingProfile,
      isCreatingCheckout: isCreatingCheckout ?? this.isCreatingCheckout,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    user,
    isRefreshingProfile,
    isCreatingCheckout,
    errorMessage,
  ];
}

class PlanCubit extends Cubit<PlanState> {
  PlanCubit({
    required this.getCurrentUser,
    required this.createPremiumCheckout,
    AppUser? initialUser,
  }) : super(PlanState(user: initialUser));

  final GetCurrentUserUsecase getCurrentUser;
  final CreatePremiumCheckoutUsecase createPremiumCheckout;

  Future<void> refreshProfile() async {
    if (state.isRefreshingProfile) return;
    emit(state.copyWith(isRefreshingProfile: true, clearError: true));

    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw StateError('No se encontró el perfil de tu cuenta.');
      }
      if (!isClosed) {
        emit(state.copyWith(user: user, isRefreshingProfile: false));
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isRefreshingProfile: false,
            errorMessage: apiErrorMessage(error),
          ),
        );
      }
    }
  }

  Future<Uri?> createCheckout() async {
    if (state.isCreatingCheckout) return null;
    emit(state.copyWith(isCreatingCheckout: true, clearError: true));

    try {
      return await createPremiumCheckout();
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: apiErrorMessage(error)));
      }
      return null;
    } finally {
      if (!isClosed) emit(state.copyWith(isCreatingCheckout: false));
    }
  }
}
