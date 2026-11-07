import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/core/errors/failures.dart';
import 'package:kroppi/features/loss_estimation/domain/entities/loss_estimation.dart';
import 'package:kroppi/features/loss_estimation/domain/repositories/loss_repository.dart';
import 'package:kroppi/features/loss_estimation/presentation/cubit/loss_form_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements LossRepository {}

LossInput _input(double expected) => LossInput(
  expectedYieldKg: expected,
  pricePerKg: 9000,
  currency: 'COP',
  periodFrom: DateTime(2026, 5, 1),
  periodTo: DateTime(2026, 11, 7),
);

final _preview = LossEstimation(
  plotId: 'p1',
  expectedYieldKg: 1200,
  harvestedKg: 900,
  lostKg: 300,
  lossPct: 25,
  pricePerKg: 9000,
  estimatedLossAmount: 2700000,
  periodFrom: DateTime(2026, 5, 1),
  periodTo: DateTime(2026, 11, 7),
);

void main() {
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(_input(1)));
  setUp(() => repository = _MockRepository());

  LossFormCubit build() => LossFormCubit(
    repository,
    plotId: 'p1',
    debounce: const Duration(milliseconds: 50),
  );

  blocTest<LossFormCubit, LossFormState>(
    'varios cambios rápidos producen una sola llamada de preview',
    setUp: () => when(
      () =>
          repository.preview(any(), any(), excludeId: any(named: 'excludeId')),
    ).thenAnswer((_) async => _preview),
    build: build,
    act: (cubit) async {
      cubit.inputChanged(_input(1000));
      cubit.inputChanged(_input(1100));
      cubit.inputChanged(_input(1200));
      await Future<void>.delayed(const Duration(milliseconds: 120));
    },
    verify: (_) {
      verify(() => repository.preview('p1', _input(1200))).called(1);
      verifyNoMoreInteractions(repository);
    },
    expect: () => [
      isA<LossFormState>().having((s) => s.previewLoading, 'loading', true),
      isA<LossFormState>()
          .having((s) => s.preview, 'preview', _preview)
          .having((s) => s.previewLoading, 'loading', false),
    ],
  );

  blocTest<LossFormCubit, LossFormState>(
    'datos inválidos no piden preview',
    build: build,
    act: (cubit) async {
      cubit.inputChanged(null);
      await Future<void>.delayed(const Duration(milliseconds: 80));
    },
    verify: (_) => verifyNever(
      () =>
          repository.preview(any(), any(), excludeId: any(named: 'excludeId')),
    ),
    expect: () => <LossFormState>[],
  );

  blocTest<LossFormCubit, LossFormState>(
    'error de preview y reintento conservan los datos',
    setUp: () {
      var calls = 0;
      when(
        () => repository.preview(
          any(),
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const NetworkFailure();
        return _preview;
      });
    },
    build: build,
    act: (cubit) async {
      cubit.inputChanged(_input(1200));
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await cubit.retryPreview();
    },
    expect: () => [
      isA<LossFormState>().having((s) => s.previewLoading, 'loading', true),
      isA<LossFormState>().having(
        (s) => s.previewFailure,
        'failure',
        isA<NetworkFailure>(),
      ),
      isA<LossFormState>()
          .having((s) => s.previewLoading, 'loading', true)
          .having((s) => s.previewFailure, 'failure', isNull),
      isA<LossFormState>().having((s) => s.preview, 'preview', _preview),
    ],
  );

  blocTest<LossFormCubit, LossFormState>(
    '422 por traslape marca el conflicto de periodo',
    setUp: () => when(() => repository.create(any(), any())).thenThrow(
      const ValidationFailure(
        'Este periodo se cruza con otra estimación ya guardada '
        '(01/01/2026 – 30/04/2026)',
      ),
    ),
    build: build,
    act: (cubit) => cubit.save(_input(1200)),
    expect: () => [
      isA<LossFormState>().having(
        (s) => s.status,
        'status',
        LossFormStatus.saving,
      ),
      isA<LossFormState>()
          .having((s) => s.status, 'status', LossFormStatus.ready)
          .having((s) => s.periodConflict, 'conflict', true)
          .having(
            (s) => s.saveFailure?.message,
            'message',
            contains('se cruza'),
          ),
    ],
  );

  blocTest<LossFormCubit, LossFormState>(
    'guardar con éxito',
    setUp: () => when(
      () => repository.create(any(), any()),
    ).thenAnswer((_) async => _preview),
    build: build,
    act: (cubit) => cubit.save(_input(1200)),
    expect: () => [
      isA<LossFormState>().having(
        (s) => s.status,
        'status',
        LossFormStatus.saving,
      ),
      isA<LossFormState>()
          .having((s) => s.status, 'status', LossFormStatus.saved)
          .having((s) => s.estimation, 'estimation', _preview),
    ],
  );

  blocTest<LossFormCubit, LossFormState>(
    'al editar, el preview excluye la propia estimación del traslape',
    setUp: () => when(
      () =>
          repository.preview(any(), any(), excludeId: any(named: 'excludeId')),
    ).thenAnswer((_) async => _preview),
    build: () => LossFormCubit(
      repository,
      plotId: 'p1',
      estimationId: 'est-1',
      debounce: const Duration(milliseconds: 50),
    ),
    act: (cubit) => cubit.inputChanged(_input(1200)),
    wait: const Duration(milliseconds: 120),
    verify: (_) => verify(
      () => repository.preview('p1', _input(1200), excludeId: 'est-1'),
    ).called(1),
  );
}
