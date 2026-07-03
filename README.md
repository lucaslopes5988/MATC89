# Playce - MATC89

Aplicativo Flutter para criar, descobrir e participar de eventos esportivos presenciais. O app usa Firebase para autenticação/dados e Google Maps/Places para mapa, busca de endereço e seleção de local.

## Requisitos

- Flutter SDK instalado e configurado.
- Android Studio ou Android SDK com cmdline-tools.
- Chrome para rodar no Web.
- Projeto Firebase com Authentication e Firestore habilitados.
- Chave do Google Maps com as APIs necessárias para cada plataforma.

## Instalação

Rode a resolução de dependências na raiz e nos pacotes internos:

```powershell
flutter pub get
cd features/events
flutter pub get
cd ../profile
flutter pub get
cd ../..
```

## Configuração de Chaves

Não suba chaves privadas ou arquivos locais de configuração para o GitHub. Estes arquivos já são ignorados pelo `.gitignore`:

- `android/app/google-services.json`
- `web/maps_config.js`
- `ios/Runner/Secrets.xcconfig`

### Firebase

O projeto precisa de Firebase Auth e Firestore.

Para Android, coloque o arquivo recebido do Firebase em:

```text
android/app/google-services.json
```

Para Web/Android, o arquivo `core/lib/firebase/firebase_options.dart` contém a configuração client-side do Firebase. Essa configuração não é uma chave de servidor, mas deve ser protegida com regras corretas no Firestore, domínios autorizados no Firebase Auth e restrições no Google Cloud sempre que possível.

### Google Maps no Web

Copie o exemplo:

```powershell
Copy-Item web/maps_config.js.example web/maps_config.js
```

Edite `web/maps_config.js` e substitua `YOUR_MAPS_API_KEY` pela chave do Google Maps.

A chave Web precisa ter:

- Maps JavaScript API
- Places API (New)

### Google Maps no Android

Adicione a chave no arquivo `android/local.properties`:

```properties
MAPS_API_KEY=SUA_CHAVE_DO_GOOGLE_MAPS
```

A chave Android precisa ter:

- Maps SDK for Android
- Places API (New), se a busca de endereços for usada no fluxo Android

### Google Maps no iOS

Crie o arquivo:

```text
ios/Runner/Secrets.xcconfig
```

Com o conteúdo:

```xcconfig
MAPS_API_KEY=SUA_CHAVE_DO_GOOGLE_MAPS
```

A chave iOS precisa ter:

- Maps SDK for iOS
- Places API (New), se a busca de endereços for usada no fluxo iOS

## Rodando o App

Web no Chrome:

```powershell
flutter run -d chrome --web-port 5175
```

Android:

```powershell
flutter devices
flutter run -d <device-id>
```

## Validação

Antes de enviar mudanças:

```powershell
flutter analyze
flutter test
flutter build web --debug
```

## Observações de Segurança

- Não commite `google-services.json`, `maps_config.js`, `Secrets.xcconfig` nem arquivos equivalentes com chaves locais.
- Restrinja a chave Web por domínio no Google Cloud.
- Restrinja chaves Android/iOS por package name/bundle id e fingerprint quando possível.
- Mantenha as regras do Firestore alinhadas ao fluxo de autenticação do app.
