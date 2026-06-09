import 'package:events/domain/model/event.dart';

abstract final class EventsStrings {
  static const exploreTitle = 'Explorar eventos';
  static const exploreSubtitle = 'Encontre atividades perto de você';
  static const searchHint = 'Buscar eventos...';
  static const emptyTitle = 'Nenhum evento por aqui';
  static const emptyMessage =
      'Quando houver eventos no Firestore, eles aparecerão aqui.';
  static const womenOnlyBadge = 'Mulheres';
  static const slotsLeft = 'vagas';
  static const full = 'Lotado';
  static const join = 'Participar';
  static const mapPlaceholderTitle = 'Mapa em breve';
  static const mapPlaceholderMessage =
      'A visualização no Google Maps entra na próxima iteração.';
  static const profilePlaceholderTitle = 'Perfil em breve';
  static const profilePlaceholderMessage =
      'Eventos que você participa e organiza aparecerão aqui.';
}

String sportTypeLabel(SportType type) {
  return switch (type) {
    SportType.all => 'Todos',
    SportType.running => 'Corrida',
    SportType.soccer => 'Futebol',
    SportType.yoga => 'Yoga',
    SportType.cycling => 'Ciclismo',
    SportType.tennis => 'Tênis',
    SportType.hiit => 'HIIT',
    SportType.swimming => 'Natação',
    SportType.other => 'Outros',
  };
}
