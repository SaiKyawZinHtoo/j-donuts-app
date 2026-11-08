part of '../../home_import.dart';

class GetHomeUseCase {
  final HomeRepository _repository;

  const GetHomeUseCase(this._repository);

  Future<Result<HomeBundle>> call() => _repository.getHome();
}
