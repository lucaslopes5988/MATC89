import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import 'package:auth/domain/usecase/auth_usecases.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends SafeCubit<LoginState> {
  LoginCubit(this._signInWithGoogleUseCase) : super(const LoginInitialState());

  final SignInWithGoogleUseCase _signInWithGoogleUseCase;

  Future<void> signIn() async {
    emit(const LoginLoadingState());

    final result = await _signInWithGoogleUseCase.invoke();
    switch (result) {
      case Ok(value: final user):
        emit(LoginSuccessState(user: user));
      case Error(error: final error) when error is ConnectionException:
        emit(const LoginErrorState(message: 'Sem conexão'));
      case Error(error: final error) when error is OperationCancelledException:
        emit(const LoginInitialState());
      case Error():
        emit(const LoginErrorState(message: 'Erro ao entrar'));
    }
  }
}
