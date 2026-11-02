import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm.dart';

enum FarmsStatus { initial, loading, success, failure }

class FarmsState extends Equatable {
  const FarmsState({
    this.status = FarmsStatus.initial,
    this.farms = const [],
    this.message,
  });

  final FarmsStatus status;
  final List<Farm> farms;
  final String? message;

  bool get isEmpty => status == FarmsStatus.success && farms.isEmpty;

  @override
  List<Object?> get props => [status, farms, message];
}

class FarmsCubit extends Cubit<FarmsState> {
  FarmsCubit(this._source) : super(const FarmsState());

  final FarmRemoteDataSource _source;

  Future<void> load() async {
    if (state.status == FarmsStatus.loading) return;
    emit(FarmsState(status: FarmsStatus.loading, farms: state.farms));
    try {
      final farms = await _source.getFarms();
      emit(FarmsState(status: FarmsStatus.success, farms: farms));
    } catch (error) {
      emit(
        FarmsState(
          status: FarmsStatus.failure,
          farms: state.farms,
          message: error.toString(),
        ),
      );
    }
  }
}
