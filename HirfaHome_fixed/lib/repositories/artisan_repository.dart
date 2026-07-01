// lib/repositories/artisan_repository.dart
import '../models/app_user.dart';

abstract class ArtisanRepository {
  Stream<List<AppUser>> getArtisans();
  Future<AppUser?> getArtisanById(String uid);
}