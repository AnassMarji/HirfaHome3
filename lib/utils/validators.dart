// lib/utils/validators.dart
class Validators {
  Validators._();

  /// Vérifie si le numéro correspond à un format mobile marocain valide :
  /// +212XXXXXXXXX ou 06XXXXXXXX ou 07XXXXXXXX.
  static bool isValidMoroccanPhone(String phone) {
    final cleanPhone = phone.replaceAll(' ', '').trim();
    final RegExp regex = RegExp(r'^(?:\+212|0)([5-7]\d{8})$');
    return regex.hasMatch(cleanPhone);
  }

  /// Vérifie le format structurel d'une adresse email.
  static bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email.trim());
  }
}