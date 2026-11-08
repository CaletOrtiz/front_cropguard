import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/domain/usecases/get_diagnosis_history_usecase.dart';
import 'package:kroppi/features/home/domain/entities/home_dashboard.dart';

enum HomeStatus { initial, loading, success, failure }

enum RecentDiagnosesStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.dashboard,
    this.message,
    this.recentDiagnosesStatus = RecentDiagnosesStatus.initial,
    this.recentDiagnoses = const [],
    this.recentDiagnosesMessage,
  });

  final HomeStatus status;
  final HomeDashboard? dashboard;
  final String? message;
  final RecentDiagnosesStatus recentDiagnosesStatus;
  final List<DiagnosisRecord> recentDiagnoses;
  final String? recentDiagnosesMessage;

  @override
  List<Object?> get props => [
    status,
    dashboard,
    message,
    recentDiagnosesStatus,
    recentDiagnoses,
    recentDiagnosesMessage,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._source, this._getHistory) : super(const HomeState());

  final FarmRemoteDataSource _source;
  final GetDiagnosisHistoryUsecase _getHistory;

  Future<void> load() async {
    if (state.status == HomeStatus.loading) return;
    emit(
      const HomeState(
        status: HomeStatus.loading,
        recentDiagnosesStatus: RecentDiagnosesStatus.loading,
      ),
    );

    final dashboardFuture = _capture(_source.getDashboard());
    final recentDiagnosesFuture = _capture(_getHistory(pageSize: 3));
    final dashboardResult = await dashboardFuture;
    final recentDiagnosesResult = await recentDiagnosesFuture;

    emit(
      HomeState(
        status: dashboardResult.error == null
            ? HomeStatus.success
            : HomeStatus.failure,
        dashboard: dashboardResult.value,
        message: dashboardResult.error,
        recentDiagnosesStatus: recentDiagnosesResult.error == null
            ? RecentDiagnosesStatus.success
            : RecentDiagnosesStatus.failure,
        recentDiagnoses: recentDiagnosesResult.value ?? const [],
        recentDiagnosesMessage: recentDiagnosesResult.error,
      ),
    );
  }

  Future<_LoadResult<T>> _capture<T>(Future<T> request) async {
    try {
      return _LoadResult(value: await request);
    } catch (error) {
      return _LoadResult(error: error.toString());
    }
  }
}

class _LoadResult<T> {
  const _LoadResult({this.value, this.error});

  final T? value;
  final String? error;
}
