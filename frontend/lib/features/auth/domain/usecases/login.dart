import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class LoginUseCase implements UseCase<UserCredential?, LoginParams> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<UserCredential?> call({LoginParams? params}) {
    return _authRepository.login(
      email: params!.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
