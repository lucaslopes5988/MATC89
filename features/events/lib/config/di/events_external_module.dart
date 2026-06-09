import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@module
abstract class EventsExternalModule {
  @lazySingleton
  FirebaseFirestore provideFirestore() => FirebaseFirestore.instance;
}
