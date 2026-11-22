import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';

import '../../domain/entities/subscription_access.dart';

class SubscriptionState {
  const SubscriptionState({this.access, this.loading = false, this.error});

  final SubscriptionAccess? access;
  final bool loading;
  final String? error;

  bool get canDiagnose =>
      !loading && access?.quota(PlanResource.diagnoses).exhausted == false;
}

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._load) : super(const SubscriptionState());

  final Future<SubscriptionAccess> Function() _load;
  String? _account;
  Future<void>? _pending;
  Timer? _boundary;
  int _generation = 0;

  Future<void> setAccount(String? account) async {
    if (isClosed || _account == account) return;
    _account = account;
    _generation++;
    _pending = null;
    _boundary?.cancel();
    emit(const SubscriptionState());
    await refresh();
  }

  Future<void> refresh() {
    if (isClosed || _account == null) return Future.value();
    final generation = _generation;
    return _pending ??= Future.microtask(() => _refresh(generation));
  }

  Future<void> refreshAfterChange() async {
    final generation = _generation;
    await _pending;
    if (generation == _generation) await refresh();
  }

  Future<void> _refresh(int generation) async {
    if (isClosed || generation != _generation) return;
    final existing = state.access;
    final now = DateTime.now();
    final valid =
        existing != null &&
        now.isBefore(existing.renewsAt) &&
        (existing.premiumUntil == null || now.isBefore(existing.premiumUntil!));
    emit(SubscriptionState(access: valid ? existing : null, loading: true));
    try {
      final access = await _load();
      if (isClosed || generation != _generation) return;
      emit(SubscriptionState(access: access));
      _boundary?.cancel();
      final expiry = access.premiumUntil;
      final next = expiry != null && expiry.isBefore(access.renewsAt)
          ? expiry
          : access.renewsAt;
      final delay = next.difference(DateTime.now());
      if (!delay.isNegative) {
        _boundary = Timer(delay + const Duration(seconds: 1), refresh);
      }
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(SubscriptionState(error: apiErrorMessage(error)));
      }
    } finally {
      if (generation == _generation) _pending = null;
    }
  }

  @override
  Future<void> close() {
    _boundary?.cancel();
    return super.close();
  }
}
