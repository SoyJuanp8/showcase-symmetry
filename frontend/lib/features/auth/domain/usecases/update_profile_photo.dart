import '../repository/auth_repository.dart';
import '../../../../core/usecase/usecase.dart';

class UpdateProfilePhotoUseCase implements UseCase<void, String> {
  final AuthRepository _authRepository;

  UpdateProfilePhotoUseCase(this._authRepository);

  @override
  Future<void> call({String? params}) {
    return _authRepository.updateProfilePhoto(params!);
  }
}
