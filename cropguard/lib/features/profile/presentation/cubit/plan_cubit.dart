import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';

import '../../domain/usecases/create_premium_checkout_usecase.dart';

class PlanState extends Equatable {
  const PlanState({this.isCreatingCheckout = false, this.errorMessage});

  final bool isCreatingCheckout;
  final String? errorMessage;

  PlanState copyWith({
    bool? isCreatingCheckout,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlanState(
      isCreatingCheckout: isCreatingCheckout ?? this.isCreatingCheckout,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isCreatingCheckout, errorMessage];
}

class PlanCubit extends Cubit<PlanState> {
  PlanCubit({required this.createPremiumCheckout}) : super(const PlanState());

  final CreatePremiumCheckoutUsecase createPremiumCheckout;

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
