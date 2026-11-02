import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/home/domain/entities/home_dashboard.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.dashboard,
    this.message,
  });

  final HomeStatus status;
  final HomeDashboard? dashboard;
  final String? message;

  @override
  List<Object?> get props => [status, dashboard, message];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._source) : super(const HomeState());

  final FarmRemoteDataSource _source;

  Future<void> load() async {
    if (state.status == HomeStatus.loading) return;
    emit(const HomeState(status: HomeStatus.loading));
    try {
      final dashboard = await _source.getDashboard();
      emit(HomeState(status: HomeStatus.success, dashboard: dashboard));
    } catch (error) {
      emit(HomeState(status: HomeStatus.failure, message: error.toString()));
    }
  }
}
