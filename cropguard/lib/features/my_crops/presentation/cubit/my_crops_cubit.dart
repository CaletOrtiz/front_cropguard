import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';
import 'package:kroppi/features/my_crops/domain/entities/my_crop.dart';

enum MyCropsStatus { initial, loading, success, failure }

class MyCropsState extends Equatable {
  const MyCropsState({
    this.status = MyCropsStatus.initial,
    this.crops = const [],
    this.message,
  });

  final MyCropsStatus status;
  final List<MyCrop> crops;
  final String? message;

  bool get isEmpty => status == MyCropsStatus.success && crops.isEmpty;

  @override
  List<Object?> get props => [status, crops, message];
}

class MyCropsCubit extends Cubit<MyCropsState> {
  MyCropsCubit(this._source) : super(const MyCropsState());

  final MyCropsRemoteDataSource _source;

  Future<void> load() async {
    if (state.status == MyCropsStatus.loading) return;
    emit(MyCropsState(status: MyCropsStatus.loading, crops: state.crops));
    try {
      final crops = await _source.getCrops();
      emit(MyCropsState(status: MyCropsStatus.success, crops: crops));
    } catch (e) {
      emit(
        MyCropsState(
          status: MyCropsStatus.failure,
          crops: state.crops,
          message: e.toString(),
        ),
      );
    }
  }
}
