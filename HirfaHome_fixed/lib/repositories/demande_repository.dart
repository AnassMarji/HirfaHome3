// ═══ FILE: lib/repositories/demande_repository.dart ═══
import '../models/demande.dart';

abstract class DemandeRepository {
  Future<bool> create(Demande demande);
  Stream<List<Demande>> getByClientId(String clientId);
  Future<String> delete(String id, String status);
  Stream<List<Demande>> getPending();
  Stream<List<Demande>> getAcceptedByArtisanId(String artisanId);
  Future<void> accept(String id, String artisanId);
  Future<void> abandon(String id);
  Future<void> terminate(String id);
  Future<void> refuse(String id);
  Future<void> startWork(String id, {DateTime? dateIntervention}); // Signature mise à jour
}