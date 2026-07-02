import 'package:profile/domain/model/gender_identity.dart';

abstract final class ProfileStrings {
  static const profileTitle = 'Meu perfil';
  static const genderIdentityLabel = 'Como você se identifica?';
  static const genderIdentityHint =
      'Essa informação é opcional e permite acesso a eventos exclusivos.';
  static const genderIdentitySaved = 'Identificação salva';
  static const genderIdentityNone = 'Não informado';
  static const signOut = 'Sair';
}

String genderIdentityLabel(GenderIdentity? identity) {
  return switch (identity) {
    GenderIdentity.woman => 'Mulher',
    GenderIdentity.man => 'Homem',
    GenderIdentity.nonBinary => 'Não-binário',
    GenderIdentity.preferNotToSay => 'Prefiro não dizer',
    null => ProfileStrings.genderIdentityNone,
  };
}
