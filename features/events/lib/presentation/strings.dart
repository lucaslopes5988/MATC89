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
  static const leave = 'Cancelar presenca';
  static const joinSuccess = 'Presenca confirmada';
  static const leaveSuccess = 'Presenca cancelada';
  static const detailsTitle = 'Detalhes do evento';
  static const detailsButton = 'Detalhes';
  static const detailsDate = 'Data e horario';
  static const detailsLocation = 'Local';
  static const detailsHost = 'Criador';
  static const detailsParticipants = 'Participantes';
  static const detailsAlreadyJoined = 'Voce ja confirmou presenca.';
  static const detailsHostJoined =
      'Voce criou este evento e ja esta confirmado.';
  static const detailsFull = 'Evento lotado.';
  static const hostCannotLeave = 'Criador confirmado';
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
  static const womenOnlyRestricted = 'Este evento é exclusivo para mulheres';
  static const mapPlaceholderTitle = 'Mapa em breve';
  static const mapPlaceholderMessage =
      'A visualização no Google Maps entra na próxima iteração.';
  static const locationPickerLabel = 'Localização no mapa';
  static const locationPickerUseMyLocation = 'Usar minha localização';
  static const locationPickerHint = 'Toque no mapa para marcar o local';
  static const locationPermissionTitle = 'Permissão de localização';
  static const locationPermissionMessage =
      'Precisamos da sua localização para mostrar o mapa.';
  static const locationPermissionDenied =
      'Permissão negada. Abra as configurações para ativar.';
  static const locationPermissionOpenSettings = 'Abrir configurações';
  static const locationSearching = 'Buscando local...';
  static const locationFound = 'Local encontrado no mapa';
  static const locationNotFound = 'Local não encontrado. Tente outro endereço.';
  static const locationSearchError = 'Erro ao buscar local';
  static const locationSearchEmpty = 'Digite o nome do local para buscar';
  static const locationSearchAction = 'Buscar no mapa';
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
