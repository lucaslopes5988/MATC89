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
  static const createTitle = 'Criar evento';
  static const createTitleLabel = 'Titulo';
  static const createSportLabel = 'Esporte';
  static const createLocationLabel = 'Local';
  static const createDateLabel = 'Data';
  static const createTimeLabel = 'Horario';
  static const createDescriptionLabel = 'Descricao';
  static const createMaxParticipantsLabel = 'Limite de vagas';
  static const createMaxParticipantsHint = 'Deixe vazio para sem limite';
  static const createWomenOnlyLabel = 'Somente mulheres';
  static const createSubmit = 'Publicar evento';
  static const createSuccess = 'Evento criado';
  static const createDateTimeRequired = 'Informe data e horario';
  static const createFutureDateRequired = 'Informe um horario futuro';
  static const requiredField = 'Campo obrigatorio';
  static const invalidMaxParticipants = 'Informe um numero maior que zero';
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
