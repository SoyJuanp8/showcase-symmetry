import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class SignInWithGoogleUseCase implements UseCase<UserCredential?, void> {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase(this._authRepository);

  @override
  Future<UserCredential?> call({void params}) {
    return _authRepository.signInWithGoogle();
  }
}
