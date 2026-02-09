import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:async';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateUserDisplayName>(_onUpdateUserDisplayName);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // Cancel existing subscription if any
    await _authStateSubscription?.cancel();

    // Subscribe to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        // We can't emit directly from the listener because it's async and outside the bloc's event loop in a clean way without add(),
        // but since we are inside _onAppStarted we can't emit for *future* events here easily unless we add a new event type.
        // However, for simplicity, checking currentUser initially is fine,
        // BUT to support real-time updates (like profile photo), we should add a specific event 'AuthUserChanged'.
        add(AuthUserChanged(user));
      } else {
        add(const AuthUserChanged(null));
      }
    });
  }

  Future<void> _onAuthUserChanged(
      AuthUserChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final credential = await _loginUseCase(
        params: LoginParams(email: event.email, password: event.password),
      );
      if (credential?.user != null) {
        emit(Authenticated(credential!.user!));
      } else {
        emit(const AuthError('Login failed: User is null'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapErrorToMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Pause subscription to avoid auto-login triggering Authenticated state
    _authStateSubscription?.pause();
    try {
      final credential = await _registerUseCase(
        params: RegisterParams(
          email: event.email,
          password: event.password,
          name: event.name,
        ),
      );
      if (credential?.user != null) {
        // Sign out immediately to force manual login
        await _logoutUseCase();
        emit(RegistrationSuccess());
      } else {
        emit(const AuthError('Registration failed: User is null'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapErrorToMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    } finally {
      // Resume subscription
      _authStateSubscription?.resume();
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(Unauthenticated());
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final credential = await _signInWithGoogleUseCase();
      if (credential?.user != null) {
        emit(Authenticated(credential!.user!));
      } else {
        // credential is null if user cancelled the sign in
        emit(Unauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapErrorToMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateUserDisplayName(
      UpdateUserDisplayName event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.updateDisplayName(event.name);
      // Determine current state to re-emit with updated user
      // Actually, authStateChanges stream should handle the update since we reload user in repo.
      // But just in case, we can manually emit if needed. The stream is safer.
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  String _mapErrorToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Server error. Please try again later.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
