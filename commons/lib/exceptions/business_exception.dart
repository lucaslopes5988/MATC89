sealed class BusinessException implements Exception {
  const BusinessException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class UnauthorizedException extends BusinessException {
  const UnauthorizedException([super.message = 'Não autorizado']);
}

final class InvalidCredentialsException extends BusinessException {
  const InvalidCredentialsException([super.message = 'Credenciais inválidas']);
}

final class EmptyFieldException extends BusinessException {
  const EmptyFieldException([super.message = 'Campo obrigatório']);
}

final class NotFoundException extends BusinessException {
  const NotFoundException([super.message = 'Recurso não encontrado']);
}

final class OperationCancelledException extends BusinessException {
  const OperationCancelledException([super.message = 'Operação cancelada']);
}

final class EventFullException extends BusinessException {
  const EventFullException([super.message = 'Evento lotado']);
}
