

class AppStrings {
  AppStrings._();

  static String t(String key, String lang) {
    assert(!key.contains(' '), 'AppStrings key "$key" must use underscores, not spaces');
    final langMap = _strings[key];
    if (langMap == null) return key;
    return langMap[lang] ?? langMap['fr'] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    // ── Catégories Métiers ──
    'plomberie': {
      'fr': 'Plomberie',
      'ar': 'السباكة',
      'en': 'Plumbing',
    },
    'electricite': {
      'fr': 'Électricité',
      'ar': 'الكهرباء',
      'en': 'Electricity',
    },
    'peinture': {
      'fr': 'Peinture',
      'ar': 'الدهان',
      'en': 'Painting',
    },
    'maconnerie': {
      'fr': 'Maçonnerie',
      'ar': 'البناء',
      'en': 'Masonry',
    },
    'menuiserie': {
      'fr': 'Menuiserie',
      'ar': 'النجارة',
      'en': 'Carpentry',
    },
    'climatisation': {
      'fr': 'Climatisation',
      'ar': 'التكييف',
      'en': 'Air Conditioning',
    },
    'nettoyage': {
      'fr': 'Nettoyage',
      'ar': 'التنظيف',
      'en': 'Cleaning',
    },
    'autre': {
      'fr': 'Autre',
      'ar': 'أخرى',
      'en': 'Other',
    },

    // ── États / Statuts des demandes normalisés ──
    'envoye': {
      'fr': 'Envoyé',
      'ar': 'تم الإرسال',
      'en': 'Sent',
    },
    'accepte': {
      'fr': 'Accepté',
      'ar': 'مقبول',
      'en': 'Accepted',
    },
    'en_cours': {
      'fr': 'En cours',
      'ar': 'جارٍ',
      'en': 'In progress',
    },
    'termine': {
      'fr': 'Terminé',
      'ar': 'منتهٍ',
      'en': 'Completed',
    },
    'refuse': {
      'fr': 'Refusé',
      'ar': 'مرفوض',
      'en': 'Refused',
    },
    'annule': {
      'fr': 'Annulé',
      'ar': 'ملغى',
      'en': 'Cancelled',
    },
    'en_attente': {
      'fr': 'En attente',
      'ar': 'قيد الانتظار',
      'en': 'Pending',
    },
    'acceptee': {
      'fr': 'Acceptée',
      'ar': 'مقبولة',
      'en': 'Accepted',
    },
    'terminee': {
      'fr': 'terminée(s)',
      'ar': 'منتهية',
      'en': 'done',
    },
    'terminees': {
      'fr': 'Terminées',
      'ar': 'المكتملة',
      'en': 'Completed',
    },
    'annulee': {
      'fr': 'Annulée',
      'ar': 'ملغاة',
      'en': 'Cancelled',
    },

    // ── Connexion & Authentification ──
    'bienvenue': {
      'fr': 'Bienvenue',
      'ar': 'مرحباً',
      'en': 'Welcome',
    },
    'connectez_vous': {
      'fr': 'Connectez-vous pour continuer',
      'ar': 'سجّل دخولك للمتابعة',
      'en': 'Sign in to continue',
    },
    'email': {
      'fr': 'Email',
      'ar': 'البريد الإلكتروني',
      'en': 'Email',
    },
    'email_hint': {
      'fr': 'votre adresse email',
      'ar': 'بريدك الإلكتروني',
      'en': 'your email address',
    },
    'mot_de_passe': {
      'fr': 'Mot de passe',
      'ar': 'كلمة المرور',
      'en': 'Password',
    },
    'mot_de_passe_oublié': {
      'fr': 'Mot de passe oublié ?',
      'ar': 'نسيت كلمة المرور؟',
      'en': 'Forgot password?',
    },
    'se_connecter': {
      'fr': 'Se connecter',
      'ar': 'تسجيل الدخول',
      'en': 'Sign in',
    },
    'pas_de_compte': {
      'fr': 'Pas encore de compte ?',
      'ar': 'ليس لديك حساب?',
      'en': 'No account yet?',
    },
    'creer_compte': {
      'fr': 'Créer un compte',
      'ar': 'إنشاء حساب',
      'en': 'Create an account',
    },

    // ── Écran d'inscription & Onboarding ──
    'creer_un_compte': {
      'fr': 'Créer un compte',
      'ar': 'إنشاء حساب جديد',
      'en': 'Create an Account',
    },
    'rejoindre_communaute': {
      'fr': 'Rejoignez notre communauté de professionnels.',
      'ar': 'انضم إلى مجتمعنا من المهنيين الحرفيين.',
      'en': 'Join our community of professionals.',
    },
    'nom_complet': {
      'fr': 'Nom complet',
      'ar': 'الاسم الكامل',
      'en': 'Full Name',
    },
    'nom_hint': {
      'fr': 'Votre nom et prénom',
      'ar': 'محمد العلمي',
      'en': 'Mohammed Alami',
    },
    'je_suis': {
      'fr': 'Je suis...',
      'ar': 'أنا...',
      'en': 'I am a...',
    },
    'option_client': {
      'fr': 'Client',
      'ar': 'عميل',
      'en': 'Client',
    },
    'option_artisan': {
      'fr': 'Artisan',
      'ar': 'حرفي',
      'en': 'Artisan',
    },
    'sinscrire': {
      'fr': "S'inscrire",
      'ar': 'إنشاء الحساب',
      'en': 'Sign Up',
    },
    'deja_compte': {
      'fr': 'Déjà un compte ?',
      'ar': 'لديك حساب؟',
      'en': 'Already have an account?',
    },

    // ── Nouveaux mots-clés d'onboarding ──
    'competences': {
      'fr': 'Compétences',
      'ar': 'المهارات',
      'en': 'Skills',
    },
    'choisir_competences': {
      'fr': 'Choisissez vos compétences',
      'ar': 'اختر مهاراتك',
      'en': 'Choose your skills',
    },
    'bio': {
      'fr': 'Biographie',
      'ar': 'السيرة الذاتية',
      'en': 'Biography',
    },
    'bio_hint': {
      'fr': 'Décrivez votre expérience et savoir-faire...',
      'ar': 'صف خبرتك ومهاراتك...',
      'en': 'Describe your experience and skills...',
    },
    'votre_ville': {
      'fr': 'Votre ville',
      'ar': 'مدينتك',
      'en': 'Your city',
    },
    'ville_hint': {
      'fr': 'Ex: Casablanca, Rabat...',
      'ar': 'مثال: الدار البيضاء، الرباط...',
      'en': 'e.g. Casablanca, Rabat...',
    },
    'tarif_horaire': {
      'fr': 'Tarif horaire (MAD/h)',
      'ar': 'السعر بالساعة (درهم/س)',
      'en': 'Hourly rate (MAD/h)',
    },
    'commencer': {
      'fr': "Commencer l'aventure",
      'ar': 'ابدأ المغامرة',
      'en': 'Get started',
    },
    'information_manquante': {
      'fr': 'Veuillez remplir votre biographie et votre ville.',
      'ar': 'يرجى ملء سيرتك الذاتية ومدينتك.',
      'en': 'Please fill in your biography and city.',
    },

    // ── Écrans Principaux & Navigation ──
    'bonjour': {
      'fr': 'Bonjour',
      'ar': 'مرحباً',
      'en': 'Hello',
    },
    'mes_demandes': {
      'fr': 'Mes Demandes',
      'ar': 'طلباتي',
      'en': 'My Requests',
    },
    'mes_interventions': {
      'fr': 'Mes Interventions',
      'ar': 'تدخلاتي',
      'en': 'My Interventions',
    },
    'aucune_intervention': {
      'fr': 'Aucune intervention pour l\'instant',
      'ar': 'لا توجد تدخلات حالياً',
      'en': 'No interventions yet',
    },
    'deconnexion': {
      'fr': 'Déconnexion',
      'ar': 'تسجيل الخروج',
      'en': 'Sign out',
    },
    'active': {
      'fr': 'active(s)',
      'ar': 'نشطة',
      'en': 'active',
    },
    'total': {
      'fr': 'total',
      'ar': 'المجموع',
      'en': 'total',
    },
    'toutes': {
      'fr': 'Toutes',
      'ar': 'الكل',
      'en': 'All',
    },
    'profil': {
      'fr': 'Profil',
      'ar': 'الملف الشخصi',
      'en': 'Profile',
    },
    'parametres': {
      'fr': 'Paramètres',
      'ar': 'الإعدادات',
      'en': 'Settings',
    },
    'langue': {
      'fr': 'Langue',
      'ar': 'اللغة',
      'en': 'Language',
    },

    // ── Formulaire de demande client ──
    'nouvelle_demande': {
      'fr': 'Nouvelle demande',
      'ar': 'طلب جديد',
      'en': 'New Request',
    },
    'tagline': {
      'fr': 'Décrivez votre besoin en quelques mots',
      'ar': 'صف حاجتك في بضع كلمات',
      'en': 'Describe your need',
    },
    'categorie': {
      'fr': 'Sélectionnez une catégorie',
      'ar': 'اختر الفئة',
      'en': 'Select a category',
    },
    'titre': {
      'fr': 'Titre',
      'ar': 'العنوان',
      'en': 'Title',
    },
    'titre_hint': {
      'fr': "Ex : Fuite d'eau dans la cuisine",
      'ar': 'مثال: تسرب مياه في المطبخ',
      'en': 'e.g. Water leak in the kitchen',
    },
    'description': {
      'fr': 'Description',
      'ar': 'الوصف',
      'en': 'Description',
    },
    'description_hint': {
      'fr': 'Décrivez le problème en détail…',
      'ar': 'صف المشكلة بالتفصيل…',
      'en': 'Describe the problem in detail…',
    },
    'adresse': {
      'fr': 'Adresse',
      'ar': 'العنوان',
      'en': 'Address',
    },
    'adresse_hint': {
      'fr': 'Ex : 12 Rue Hassan II, Casablanca',
      'ar': 'مثال: 12 شارع الحسن الثاني، الدار البيضاء',
      'en': 'e.g. 12 Hassan II St, Casablanca',
    },
    'prix': {
      'fr': 'Prix proposé',
      'ar': 'السعر المقترح',
      'en': 'Proposed price',
    },
    'prix_hint': {
      'fr': 'Montant en MAD (optionnel)',
      'ar': 'المبلغ بالدرهم (اختياري)',
      'en': 'Amount in MAD (optional)',
    },
    'mad': {
      'fr': 'MAD',
      'ar': 'درهم',
      'en': 'MAD',
    },
    'telephone': {
      'fr': 'Téléphone',
      'ar': 'الهاتف',
      'en': 'Phone',
    },
    'envoyer': {
      'fr': 'Envoyer la demande',
      'ar': 'إرسال الطلب',
      'en': 'Send Request',
    },
    'annuler_demande': {
      'fr': 'Annuler la demande',
      'ar': 'إلغاء الطلب',
      'en': 'Cancel Request',
    },
    'confirmer_annulation': {
      'fr': "Confirmer l'annulation",
      'ar': 'تأكيد الإلغاء',
      'en': 'Confirm Cancellation',
    },
    'confirmer_annulation_msg': {
      'fr': 'Voulez-vous vraiment annuler cette demande ?',
      'ar': 'هل تريد فعلاً إلغاء هذا الطلب؟',
      'en': 'Are you sure you want to cancel this request?',
    },
    'non': {
      'fr': 'Non',
      'ar': 'لا',
      'en': 'No',
    },
    'oui_annuler': {
      'fr': 'Oui, annuler',
      'ar': 'نعم، إلغاء',
      'en': 'Yes, cancel',
    },
    'succes': {
      'fr': 'Demande envoyée avec succès !',
      'ar': 'تم إرسال الطلب بنجاح!',
      'en': 'Request sent successfully!',
    },

    // ── Évaluation & Avis ──
    'noter_artisan': {
      'fr': "Noter l'artisan",
      'ar': 'تقييم الحرفي',
      'en': 'Rate the artisan',
    },
    'noter_msg': {
      'fr': 'Comment s’est passé le service ? Laissez une note.',
      'ar': 'كيف كانت الخدمة؟ اترك تقييماً.',
      'en': 'How was the service? Leave a rating.',
    },
    'votre_avis_commentaire': {
      'fr': 'Votre commentaire (optionnel)',
      'ar': 'تعليقك (اختياري)',
      'en': 'Your comment (optional)',
    },
    'plus_tard': {
      'fr': 'Plus tard',
      'ar': 'لاحقاً',
      'en': 'Later',
    },
    'envoyer_note': {
      'fr': 'Envoyer la note',
      'ar': 'إرسال التقييم',
      'en': 'Submit Rating',
    },
    'note_envoye': {
      'fr': 'Avis envoyé, merci !',
      'ar': 'تم إرسال التقييم، شكرا!',
      'en': 'Review submitted, thank you!',
    },
    'noter': {
      'fr': 'Noter',
      'ar': 'تقييم',
      'en': 'Rate',
    },
    'erreur_envoi_note': {
      'fr': "Échec de l'envoi de la note. Veuillez réessayer.",
      'ar': 'خطأ أثناء إرسال التقييم. يرجى المحاولة مرة أخرى.',
      'en': 'Failed to submit rating.',
    },

    // ── Espaces Artisan (Tableau de Bord & Gestion) ──
    'tableau_bord': {
      'fr': 'Tableau de bord',
      'ar': 'لوحة التحكم',
      'en': 'Dashboard',
    },
    'disponibles': {
      'fr': 'Disponibles',
      'ar': 'المتاحة',
      'en': 'Available',
    },
    'mes_chantiers': {
      'fr': 'Mes chantiers',
      'ar': 'مشاريعي',
      'en': 'My Jobs',
    },
    'aucune_disponible': {
      'fr': 'Aucune demande disponible pour le moment.',
      'ar': 'لا توجد طلبات متاحة حالياً.',
      'en': 'No requests available at the moment.',
    },
    'aucun_chantier': {
      'fr': "Vous n'avez pas encore de chantiers actifs ou terminés.",
      'ar': 'ليس لديك أي مشاريع نشطة أو منتهية بعد.',
      'en': 'You have no active or completed jobs yet.',
    },
    'accepter': {
      'fr': 'Accepter',
      'ar': 'قبول',
      'en': 'Accept',
    },
    'abandonner': {
      'fr': 'Abandonner',
      'ar': 'تخلي',
      'en': 'Abandon',
    },
    'accepter_demande_confirm_title': {
      'fr': 'Confirmer l’acceptation',
      'ar': 'تأكيد القبول',
      'en': 'Confirm Acceptance',
    },
    'accepter_demande_confirm_msg': {
      'fr': 'Accepter cette demande :',
      'ar': 'قبول هذا الطلب:',
      'en': 'Accept this request:',
    },
    'annuler': {
      'fr': 'Annuler',
      'ar': 'إلغاء',
      'en': 'Cancel',
    },
    'confirmer': {
      'fr': 'Confirmer',
      'ar': 'تأكيد',
      'en': 'Confirm',
    },
    'succes_acceptation': {
      'fr': 'Demande acceptée avec succès !',
      'ar': 'تم قبول الطلب بنجاح!',
      'en': 'Request accepted successfully!',
    },
    'erreur_generique': {
      'fr': 'Une erreur est survenue. Veuillez réessayer.',
      'ar': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
      'en': 'An error occurred. Please try again.',
    },
    'abandonner_confirm_title': {
      'fr': 'Abandonner la demande ?',
      'ar': 'التخلي عن الطلب؟',
      'en': 'Abandon Request?',
    },
    'abandonner_confirm_msg': {
      'fr': 'Cette demande retournera dans le pool disponible.',
      'ar': 'سيعود هذا الطلب إلى قائمة الطلبات المتاحة.',
      'en': 'This request will return to the available pool.',
    },
    'non_garder': {
      'fr': 'Non, la garder',
      'ar': 'لا، أرغب في الاحتفاظ بها',
      'en': 'No, keep it',
    },
    'oui_abandonner': {
      'fr': 'Abandonner',
      'ar': 'تخلي',
      'en': 'Yes, abandon',
    },
    'succes_abandon': {
      'fr': 'Demande abandonnée.',
      'ar': 'تم التخلي عن الطلب.',
      'en': 'Request abandoned.',
    },
    'marquer_terminee_titre': {
      'fr': 'Mark as Complete?',
      'ar': 'هل تريد تحديدها كمنتهية؟',
      'en': 'Mark as Complete?',
    },
    'marquer_terminee_msg': {
      'fr': 'Confirmez que cette mission est terminée.',
      'ar': 'يرجى تأكيد انتهاء هذه المهمة.',
      'en': 'Confirm that this mission is finished.',
    },
    'terminer': {
      'fr': 'Terminer',
      'ar': 'إنهاء',
      'en': 'Complete',
    },
    'noter_client_titre': {
      'fr': 'Noter le client',
      'ar': 'تقييم الزبون',
      'en': 'Rate the Client',
    },
    'noter_client_msg': {
      'fr': 'Comment s’est déroulé le travail avec ce client ?',
      'ar': 'كيف كان العمل مع هذا الزبون؟',
      'en': 'How was working with this client?',
    },

    // ── Rôles d'utilisateurs ──
    'client': {
      'fr': 'Client',
      'ar': 'زبون',
      'en': 'Client',
    },
    'artisan_role': {
      'fr': 'Artisan',
      'ar': 'حرفي',
      'en': 'Artisan',
    },

    // ── Éléments de Profil & Divers ──
    'email_copie': {
      'fr': 'Email copié dans le presse-papiers',
      'ar': 'تم نسخ البريد الإلكتروني',
      'en': 'Email copied to clipboard',
    },
    'a_propos': {
      'fr': 'À propos',
      'ar': 'حول التطبيق',
      'en': 'About',
    },
    'conditions_utilisation': {
      'fr': "Conditions d'utilisation",
      'ar': 'شروط الاستخدام',
      'en': 'Terms of Service',
    },
    'politique_confidentialite': {
      'fr': 'Politique de confidentialité',
      'ar': 'سياسة الخصوصية',
      'en': 'Privacy Policy',
    },
    'version_app': {
      'fr': 'Version 1.0.0',
      'ar': 'الإصدار 1.0.0',
      'en': 'Version 1.0.0',
    },
    'fait_avec_amour': {
      'fr': 'Fait avec ❤️ pour le Maroc',
      'ar': 'صُنع بـ ❤️ للمغرب',
      'en': 'Made with ❤️ for Morocco',
    },
    'about_text': {
      'fr': 'HirfaHome – la plateforme qui met en relation artisans qualifiés et clients au Maroc.',
      'ar': 'حرفتهوم – المنصة التي تربط الحرفيين المؤهلين بالزبائن في المغرب.',
      'en': 'HirfaHome – the platform that connects skilled artisans with clients in Morocco.',
    },
    'terms_text': {
      'fr': "Conditions d'utilisation à venir...",
      'ar': 'شروط الاستخدام قريبا...',
      'en': 'Terms of Service coming soon...',
    },
    'privacy_text': {
      'fr': 'Politique de confidentialité à venir...',
      'ar': 'سياسة الخصوصية قريبا...',
      'en': 'Privacy Policy coming soon...',
    },

    // ── Statistiques & Administration ──
    'demarrer': {
      'fr': 'Démarrer',
      'ar': 'ابدأ',
      'en': 'Start',
    },
    'statistiques': {
      'fr': 'Statistiques',
      'ar': 'إحصائيات',
      'en': 'Statistics',
    },
    'missions_terminees': {
      'fr': 'Missions terminées',
      'ar': 'المهام المنجزة',
      'en': 'Completed missions',
    },
    'taux_satisfaction': {
      'fr': 'Taux de satisfaction',
      'ar': 'نسبة الرضا',
      'en': 'Satisfaction rate',
    },
    'verifie_seulement': {
      'fr': 'Vérifiés seulement',
      'ar': 'الموثوقون فقط',
      'en': 'Verified only',
    },

    // ── Validation du formulaire et autres corrections ──
    'erreur_champs': {
      'fr': 'Veuillez remplir tous les champs obligatoires.',
      'ar': 'يرجى ملء جميع الحقول الإلزامية.',
      'en': 'Please fill in all required fields.',
    },
    'refuser': {
      'fr': 'Refuser',
      'ar': 'رفض',
      'en': 'Refuse',
    },
    'refuser_demande': {
      'fr': 'Refuser la demande ?',
      'ar': 'رفض الطلب؟',
      'en': 'Refuse this request?',
    },
    'succes_refus': {
      'fr': 'Demande refusée.',
      'ar': 'تم رفض الطلب.',
      'en': 'Request refused.',
    },
    'disponibilite': {
      'fr': 'Disponibilité',
      'ar': 'التوفر',
      'en': 'Availability',
    },
  };
}