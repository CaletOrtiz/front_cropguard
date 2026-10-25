// core/usecases/usecase.dart
import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

class NoParams {
  const NoParams();
}
