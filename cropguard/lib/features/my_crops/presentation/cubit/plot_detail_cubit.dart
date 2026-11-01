import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot_sample.dart';

enum PlotDetailStatus { initial, loading, success, failure }

class PlotDetailState extends Equatable {
  const PlotDetailState({
    this.status = PlotDetailStatus.initial,
    this.detail,
    this.samples = const [],
    this.message,
  });

  final PlotDetailStatus status;
  final PlotDetail? detail;
  final List<PlotSample> samples; // cronológico, listo para graficar
  final String? message;

  @override
  List<Object?> get props => [status, detail, samples, message];
}

class PlotDetailCubit extends Cubit<PlotDetailState> {
  PlotDetailCubit(this._source, this.plotId) : super(const PlotDetailState());

  final MyCropsRemoteDataSource _source;
  final String plotId;

  Future<void> load() async {
    if (isClosed || state.status == PlotDetailStatus.loading) return;
    emit(
      PlotDetailState(
        status: PlotDetailStatus.loading,
        detail: state.detail,
        samples: state.samples,
      ),
    );
    try {
      final results = await Future.wait([
        _source.getPlotDetail(plotId),
        _source.getSamples(plotId),
      ]);
      if (isClosed) return;
      emit(
        PlotDetailState(
          status: PlotDetailStatus.success,
          detail: results[0] as PlotDetail,
          samples: results[1] as List<PlotSample>,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        PlotDetailState(
          status: PlotDetailStatus.failure,
          detail: state.detail,
          samples: state.samples,
          message: e.toString(),
        ),
      );
    }
  }
}
