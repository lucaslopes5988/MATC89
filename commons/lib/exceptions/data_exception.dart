sealed class DataException implements Exception {
  const DataException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ConnectionException extends DataException {
  const ConnectionException([super.message = 'Sem conexão com a internet']);
}

final class ParseException extends DataException {
  const ParseException([super.message = 'Erro ao processar dados']);
}

final class StorageException extends DataException {
  const StorageException([super.message = 'Erro ao acessar armazenamento']);
}

final class FirebaseDataException extends DataException {
  const FirebaseDataException([super.message = 'Erro no Firebase']);
}
