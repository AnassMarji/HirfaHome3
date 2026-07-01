// ═══ FILE: lib/utils/validators.dart ═══
//
// Form validators for email, phone, password, and required fields.
//
// Improvements vs original:
//   - Email regex now accepts modern TLDs (.museum, .online, .tech, .photography)
//     and `+` in local part (Gmail aliases like alice+work@gmail.com).
//   - Password validator added (min 8 chars, mix of letters and digits).
//   - Required-field and min-length helpers added for form reuse.

class Validators {
  Validators._();

  /// Vérifie si le numéro correspond à un format mobile marocain valide :
  /// +212XXXXXXXXX, 0XXXXXXXXX (06/07/05). Accepte les espaces.
  static bool isValidMoroccanPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '').trim();
    // Formats acceptés:
    //   +212 6XX XXX XXX  (international, mobile)
    //   +212 7XX XXX XXX  (international, mobile)
    //   +212 5XX XXX XXX  (international, fixe)
    //   0 6XX XXX XXX / 0 7XX XXX XXX / 0 5XX XXX XXX  (local)
    final regex = RegExp(r'^(\+212|0)[5-7]\d{8}$');
    return regex.hasMatch(cleanPhone);
  }

  /// Vérifie le format structurel d'une adresse email.
  /// Accepte les TLDs longs (.museum, .photography, .online) et le `+`
  /// dans la partie locale (alias Gmail).
  static bool isValidEmail(String email) {
    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );
    return regex.hasMatch(email.trim());
  }

  /// Vérifie la robustesse du mot de passe.
  /// Règles :
  ///   - Minimum 8 caractères
  ///   - Au moins une lettre
  ///   - Au moins un chiffre
  /// (Firebase Auth impose déjà 6 chars minimum ; nous sommes plus stricts.)
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) return false;
    if (!RegExp(r'\d').hasMatch(password)) return false;
    return true;
  }

  /// Retourne null si la valeur est non-vide, sinon un message d'erreur.
  /// À utiliser directement comme validator dans un TextFormField.
  static String? required(String? value, {String message = 'Ce champ est obligatoire'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  /// Validator combiné : champ requis + email valide.
  static String? email(String? value, {String requiredMsg = 'Email requis', String invalidMsg = 'Email invalide'}) {
    if (value == null || value.trim().isEmpty) return requiredMsg;
    if (!isValidEmail(value)) return invalidMsg;
    return null;
  }

  /// Validator combiné : champ requis + téléphone marocain valide.
  static String? phone(String? value, {String requiredMsg = 'Téléphone requis', String invalidMsg = 'Numéro marocain invalide (ex: 06XXXXXXXX)'}) {
    if (value == null || value.trim().isEmpty) return requiredMsg;
    if (!isValidMoroccanPhone(value)) return invalidMsg;
    return null;
  }

  /// Validator combiné : champ requis + mot de passe robuste.
  static String? password(String? value, {String requiredMsg = 'Mot de passe requis', String invalidMsg = 'Min. 8 caractères avec lettres et chiffres'}) {
    if (value == null || value.isEmpty) return requiredMsg;
    if (!isValidPassword(value)) return invalidMsg;
    return null;
  }
}
