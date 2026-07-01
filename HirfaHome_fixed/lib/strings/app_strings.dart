

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

    // ── Login screen (hero + bottom sheets) ──
    'app_tagline': {
      'fr': "Trouvez l'artisan qu'il vous faut",
      'ar': 'اعثر على الحرفي المناسب لك',
      'en': 'Find the right artisan for you',
    },
    'ou': {
      'fr': 'ou',
      'ar': 'أو',
      'en': 'or',
    },
    'continue_with_google': {
      'fr': 'Continuer avec Google',
      'ar': 'متابعة مع Google',
      'en': 'Continue with Google',
    },
    'forgot_password_title': {
      'fr': 'Mot de passe oublié',
      'ar': 'نسيت كلمة المرور',
      'en': 'Forgot password',
    },
    'forgot_password_description': {
      'fr': 'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
      'ar': 'أدخل بريدك الإلكتروني لتستلم رابط إعادة التعيين.',
      'en': 'Enter your email address to receive a reset link.',
    },
    'forgot_password_send': {
      'fr': 'Envoyer le lien',
      'ar': 'إرسال الرابط',
      'en': 'Send link',
    },
    'forgot_password_success_title': {
      'fr': 'Email envoyé !',
      'ar': 'تم إرسال البريد!',
      'en': 'Email sent!',
    },
    'forgot_password_success_message': {
      'fr': "Si l'adresse {email} correspond à un compte, vous recevrez un email avec les instructions.",
      'ar': 'إذا كان العنوان {email} مرتبطًا بحساب، ستستلم بريدًا بالتعليمات.',
      'en': 'If the address {email} matches an account, you will receive an email with instructions.',
    },
    'verify_email_sheet_title': {
      'fr': 'Vérifiez votre email',
      'ar': 'تحقق من بريدك الإلكتروني',
      'en': 'Verify your email',
    },
    'verify_email_sheet_description': {
      'fr': 'Un lien de vérification a été envoyé à {email}. Cliquez dessus pour activer votre compte.',
      'ar': 'تم إرسال رابط التحقق إلى {email}. اضغط عليه لتفعيل حسابك.',
      'en': 'A verification link has been sent to {email}. Click it to activate your account.',
    },
    'verify_email_sheet_resend': {
      'fr': 'Renvoyer le lien',
      'ar': 'إعادة إرسال الرابط',
      'en': 'Resend link',
    },
    'verify_email_sheet_resent': {
      'fr': 'Email de vérification renvoyé.',
      'ar': 'تمت إعادة إرسال بريد التحقق.',
      'en': 'Verification email resent.',
    },
    'ok': {
      'fr': 'OK',
      'ar': 'حسنًا',
      'en': 'OK',
    },
    'login_invalid_email': {
      'fr': 'Adresse email invalide.',
      'ar': 'البريد الإلكتروني غير صالح.',
      'en': 'Invalid email address.',
    },
    'login_password_too_short': {
      'fr': 'Le mot de passe doit contenir au moins 6 caractères.',
      'ar': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.',
      'en': 'Password must be at least 6 characters.',
    },

    // ── Client home screen ──
    'nav_home': {
      'fr': 'Accueil', 'ar': 'الرئيسية', 'en': 'Home',
    },
    'nav_search': {
      'fr': 'Rechercher', 'ar': 'بحث', 'en': 'Search',
    },
    'nav_demandes': {
      'fr': 'Demandes', 'ar': 'طلباتي', 'en': 'Requests',
    },
    'nav_profile': {
      'fr': 'Profil', 'ar': 'الملف', 'en': 'Profile',
    },
    'home_greeting_morning': {
      'fr': 'Bonjour', 'ar': 'صباح الخير', 'en': 'Good morning',
    },
    'home_greeting_afternoon': {
      'fr': 'Bon après-midi', 'ar': 'مساء الخير', 'en': 'Good afternoon',
    },
    'home_greeting_evening': {
      'fr': 'Bonsoir', 'ar': 'مساء الخير', 'en': 'Good evening',
    },
    'home_greeting_default': {
      'fr': 'Bonjour', 'ar': 'مرحباً', 'en': 'Hello',
    },
    'home_subtitle': {
      'fr': 'Que pouvez-vous faire aujourd\'hui ?',
      'ar': 'ما الذي يمكنك فعله اليوم؟',
      'en': 'What can we do for you today?',
    },
    'home_section_categories': {
      'fr': 'Catégories', 'ar': 'الفئات', 'en': 'Categories',
    },
    'home_section_nearby': {
      'fr': 'Artisans à proximité', 'ar': 'حرفيون قريبون', 'en': 'Nearby artisans',
    },
    'home_section_recent_demandes': {
      'fr': 'Demandes récentes', 'ar': 'طلبات حديثة', 'en': 'Recent requests',
    },
    'home_section_active_demandes': {
      'fr': 'Demandes en cours', 'ar': 'الطلبات الجارية', 'en': 'Active requests',
    },
    'home_action_view_all': {
      'fr': 'Voir tout', 'ar': 'عرض الكل', 'en': 'View all',
    },
    'home_action_new_request': {
      'fr': 'Nouvelle demande', 'ar': 'طلب جديد', 'en': 'New request',
    },
    'home_stat_total': {
      'fr': 'Total', 'ar': 'المجموع', 'en': 'Total',
    },
    'home_stat_active': {
      'fr': 'En cours', 'ar': 'جارٍ', 'en': 'Active',
    },
    'home_stat_done': {
      'fr': 'Terminées', 'ar': 'منتهية', 'en': 'Done',
    },
    'home_empty_demandes_title': {
      'fr': 'Aucune demande pour le moment',
      'ar': 'لا توجد طلبات حاليا',
      'en': 'No requests yet',
    },
    'home_empty_demandes_message': {
      'fr': 'Créez votre première demande d\'intervention en un instant.',
      'ar': 'أنشئ طلب التدخل الأول في لحظات.',
      'en': 'Create your first intervention request in seconds.',
    },
    'home_search_prompt_title': {
      'fr': 'Trouvez un artisan',
      'ar': 'ابحث عن حرفي',
      'en': 'Find an artisan',
    },
    'home_search_prompt_subtitle': {
      'fr': 'Plomberie, électricité, peinture et plus',
      'ar': 'سباكة، كهرباء، دهان وأكثر',
      'en': 'Plumbing, electrical, painting and more',
    },

    // ── Artisan detail screen ──
    'artisan_no_rating': {
      'fr': 'Pas encore noté',
      'ar': 'لم يُقيّم بعد',
      'en': 'Not rated yet',
    },
    'artisan_reviews_count': {
      'fr': '{count} avis client{s}',
      'ar': '{count} تقييم',
      'en': '{count} review{s}',
    },
    'artisan_reviews_placeholder': {
      'fr': 'Les avis détaillés seront disponibles prochainement.',
      'ar': 'ستتاح التقييمات التفصيلية قريبًا.',
      'en': 'Detailed reviews will be available soon.',
    },
    'artisan_tab_about': {
      'fr': 'À propos',
      'ar': 'حول',
      'en': 'About',
    },
    'artisan_tab_portfolio': {
      'fr': 'Portfolio',
      'ar': 'أعمال',
      'en': 'Portfolio',
    },
    'artisan_tab_reviews': {
      'fr': 'Avis',
      'ar': 'تقييمات',
      'en': 'Reviews',
    },
    'artisan_cta_send_request': {
      'fr': 'Envoyer une demande',
      'ar': 'إرسال طلب',
      'en': 'Send request',
    },
    'artisan_cta_chat': {
      'fr': 'Discuter',
      'ar': 'محادثة',
      'en': 'Chat',
    },
    'artisan_experience_years': {
      'fr': '{count} an{s} d\'expérience',
      'ar': '{count} سنة خبرة',
      'en': '{count} year{s} of experience',
    },
    'artisan_verified': {
      'fr': 'Vérifié',
      'ar': 'موثّق',
      'en': 'Verified',
    },
    'artisan_not_verified': {
      'fr': 'Non vérifié',
      'ar': 'غير موثّق',
      'en': 'Not verified',
    },

    // ── Artisan home / dashboard ──
    'artisan_nav_dashboard': {
      'fr': 'Tableau de bord', 'ar': 'لوحة التحكم', 'en': 'Dashboard',
    },
    'artisan_nav_demandes': {
      'fr': 'Mes demandes', 'ar': 'طلباتي', 'en': 'My requests',
    },
    'artisan_nav_portfolio': {
      'fr': 'Portfolio', 'ar': 'أعمال', 'en': 'Portfolio',
    },
    'artisan_nav_profile': {
      'fr': 'Profil', 'ar': 'الملف', 'en': 'Profile',
    },
    'artisan_dash_pending_title': {
      'fr': 'Demandes en attente',
      'ar': 'طلبات قيد الانتظار',
      'en': 'Pending requests',
    },
    'artisan_dash_started_toast': {
      'fr': "Travail démarré et date d'intervention planifiée.",
      'ar': 'تم بدء العمل وتحديد تاريخ التدخل.',
      'en': 'Work started and intervention date scheduled.',
    },
    'artisan_portfolio_title': {
      'fr': 'Portfolio', 'ar': 'أعمال', 'en': 'Portfolio',
    },
    'artisan_portfolio_add_photo': {
      'fr': 'Ajouter une photo',
      'ar': 'إضافة صورة',
      'en': 'Add a photo',
    },
    'filter_all': {
      'fr': 'Toutes', 'ar': 'الكل', 'en': 'All',
    },
    'artisan_portfolio_delete_title': {
      'fr': 'Supprimer cette image ?',
      'ar': 'حذف هذه الصورة؟',
      'en': 'Delete this image?',
    },
    'artisan_portfolio_delete_confirm': {
      'fr': "Cette action supprimera définitivement l'image de votre portfolio.",
      'ar': 'سيؤدي هذا الإجراء إلى حذف الصورة من معرض أعمالك نهائيًا.',
      'en': 'This will permanently remove the image from your portfolio.',
    },
    'artisan_portfolio_delete_success': {
      'fr': 'Image retirée avec succès.',
      'ar': 'تم حذف الصورة بنجاح.',
      'en': 'Image removed successfully.',
    },
    'artisan_portfolio_error': {
      'fr': 'Erreur : {error}',
      'ar': 'خطأ: {error}',
      'en': 'Error: {error}',
    },

    // ── Availability screen ──
    'artisan_availability_saved': {
      'fr': 'Disponibilités sauvegardées !',
      'ar': 'تم حفظ أوقات التوفر!',
      'en': 'Availability saved!',
    },
    'artisan_availability_save_error': {
      'fr': 'Erreur lors de la sauvegarde : {error}',
      'ar': 'خطأ أثناء الحفظ: {error}',
      'en': 'Error saving: {error}',
    },
    'artisan_availability_save': {
      'fr': 'Enregistrer le planning',
      'ar': 'حفظ الجدول',
      'en': 'Save schedule',
    },

    // ── Settings screen ──
    'artisan_settings_title': {
      'fr': 'Paramètres', 'ar': 'الإعدادات', 'en': 'Settings',
    },
    'artisan_settings_delete_account': {
      'fr': 'Supprimer définitivement',
      'ar': 'حذف نهائي',
      'en': 'Delete permanently',
    },
    'artisan_settings_delete_title': {
      'fr': 'Supprimer votre compte ?',
      'ar': 'حذف حسابك؟',
      'en': 'Delete your account?',
    },
    'artisan_settings_delete_warning': {
      'fr': 'Action irréversible. Toutes vos données seront définitivement supprimées.',
      'ar': 'إجراء لا رجعة فيه. سيتم حذف جميع بياناتك نهائيًا.',
      'en': 'Irreversible action. All your data will be permanently deleted.',
    },
    'artisan_settings_error': {
      'fr': 'Erreur : {error}',
      'ar': 'خطأ: {error}',
      'en': 'Error: {error}',
    },

    // ── Onboarding ──
    'artisan_onboarding_error': {
      'fr': 'Erreur: {error}',
      'ar': 'خطأ: {error}',
      'en': 'Error: {error}',
    },

    // ── Common artisan actions ──
    'common_delete': {
      'fr': 'Supprimer', 'ar': 'حذف', 'en': 'Delete',
    },
    'common_accept': {
      'fr': 'Accepter', 'ar': 'قبول', 'en': 'Accept',
    },
    'common_refuse': {
      'fr': 'Refuser', 'ar': 'رفض', 'en': 'Refuse',
    },
    'common_start_work': {
      'fr': 'Démarrer', 'ar': 'بدء', 'en': 'Start',
    },
    'common_complete': {
      'fr': 'Terminer', 'ar': 'إنهاء', 'en': 'Complete',
    },
    'nav_notifications': {
      'fr': 'Notifications', 'ar': 'الإشعارات', 'en': 'Notifications',
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

    // ── Notifications (FCM) ──
    'notif_new_demande_title': {
      'fr': 'Nouvelle demande reçue',
      'ar': 'لديك طلب جديد',
      'en': 'New request received',
    },
    'notif_new_demande_body': {
      'fr': 'Un client vous a envoyé une nouvelle demande',
      'ar': 'أرسل لك عميل طلبًا جديدًا',
      'en': 'A client sent you a new request',
    },
    'notif_status_update_title': {
      'fr': 'Mise à jour de votre demande',
      'ar': 'تحديث طلبك',
      'en': 'Request status update',
    },
    'notif_status_accepte': {
      'fr': 'Votre demande a été acceptée !',
      'ar': 'تم قبول طلبك!',
      'en': 'Your request has been accepted!',
    },
    'notif_status_refuse': {
      'fr': 'Votre demande a été refusée.',
      'ar': 'تم رفض طلبك.',
      'en': 'Your request has been refused.',
    },
    'notif_status_en_cours': {
      'fr': "L'artisan est en route.",
      'ar': 'الحرفي في الطريق.',
      'en': 'The artisan is on the way.',
    },
    'notif_status_termine': {
      'fr': "Mission terminée. Pensez à noter l'artisan !",
      'ar': 'اكتملت المهمة. لا تنسَ تقييم الحرفي!',
      'en': 'Mission completed. Remember to rate the artisan!',
    },
    'notif_status_default': {
      'fr': 'Le statut de votre demande a été mis à jour.',
      'ar': 'تم تحديث حالة طلبك.',
      'en': 'Your request status has been updated.',
    },
    'notif_new_message_title': {
      'fr': 'Nouveau message',
      'ar': 'رسالة جديدة',
      'en': 'New message',
    },

    // ── Chat Screen ──
    'chat_online': {
      'fr': 'En ligne',
      'ar': 'متصل',
      'en': 'Online',
    },
    'chat_offline': {
      'fr': 'Hors ligne',
      'ar': 'غير متصل',
      'en': 'Offline',
    },
    'chat_empty_title': {
      'fr': 'Début de la conversation',
      'ar': 'بداية المحادثة',
      'en': 'Start of conversation',
    },
    'chat_empty_message': {
      'fr': 'Envoyez votre premier message pour démarrer la discussion.',
      'ar': 'أرسل أول رسالة لبدء المحادثة.',
      'en': 'Send your first message to start the conversation.',
    },
    'chat_input_hint': {
      'fr': 'Écrivez votre message…',
      'ar': 'اكتب رسالتك…',
      'en': 'Type your message…',
    },
    'chat_linked_to_request': {
      'fr': 'Lié à la demande',
      'ar': 'مرتبط بالطلب',
      'en': 'Linked to request',
    },
    'chat_send_error': {
      'fr': "Erreur d'envoi du message. Réessayez.",
      'ar': 'حدث خطأ أثناء إرسال الرسالة. حاول مجددًا.',
      'en': 'Failed to send message. Please retry.',
    },
    'chat_auth_error': {
      'fr': "Erreur d'authentification. Reconnectez-vous.",
      'ar': 'خطأ في المصادقة. سجّل الدخول مجددًا.',
      'en': 'Authentication error. Please sign in again.',
    },
    'chat_load_error': {
      'fr': 'Impossible de charger les messages.',
      'ar': 'تعذر تحميل الرسائل.',
      'en': 'Could not load messages.',
    },

    // ── Verify Email Screen ──
    'verify_email_title': {
      'fr': 'Vérifiez votre boîte mail',
      'ar': 'تحقق من بريدك الإلكتروني',
      'en': 'Check your inbox',
    },
    'verify_email_description': {
      'fr': "Un lien de confirmation a été envoyé. Cliquez dessus pour activer votre compte.",
      'ar': 'تم إرسال رابط التأكيد. اضغط عليه لتفعيل حسابك.',
      'en': 'A confirmation link has been sent. Click it to activate your account.',
    },
    'verify_email_resend': {
      'fr': "Renvoyer l'email",
      'ar': 'إعادة إرسال البريد',
      'en': 'Resend email',
    },
    'verify_email_resent': {
      'fr': 'Email renvoyé. Vérifiez votre boîte de réception.',
      'ar': 'تمت إعادة إرسال البريد. تحقق من صندوق الوارد.',
      'en': 'Email resent. Check your inbox.',
    },
    'verify_email_resent_hint': {
      'fr': 'Si vous ne recevez rien, vérifiez vos spams.',
      'ar': 'إذا لم تتلقَّ شيئًا، تحقق من مجلد الرسائل غير المرغوب فيها.',
      'en': 'If you receive nothing, check your spam folder.',
    },

    // ── Common ──
    'cancel': {
      'fr': 'Annuler',
      'ar': 'إلغاء',
      'en': 'Cancel',
    },
    'retry': {
      'fr': 'Réessayer',
      'ar': 'إعادة المحاولة',
      'en': 'Retry',
    },
    'loading': {
      'fr': 'Chargement…',
      'ar': 'جارٍ التحميل…',
      'en': 'Loading…',
    },
    'error_generic': {
      'fr': 'Une erreur est survenue',
      'ar': 'حدث خطأ',
      'en': 'An error occurred',
    },
    'error_loading': {
      'fr': 'Erreur lors du chargement des données',
      'ar': 'حدث خطأ أثناء تحميل البيانات',
      'en': 'Error loading data',
    },
    'no_data': {
      'fr': 'Aucune donnée à afficher',
      'ar': 'لا توجد بيانات للعرض',
      'en': 'No data to display',
    },
    'no_results': {
      'fr': 'Aucun résultat trouvé',
      'ar': 'لم يتم العثور على نتائج',
      'en': 'No results found',
    },

    // ── Settings screen ──
    'settings_account': {'fr': 'COMPTE', 'ar': 'الحساب', 'en': 'ACCOUNT'},
    'settings_preferences': {'fr': 'PRÉFÉRENCES', 'ar': 'التفضيلات', 'en': 'PREFERENCES'},
    'settings_security': {'fr': 'SÉCURITÉ', 'ar': 'الأمان', 'en': 'SECURITY'},
    'settings_danger_zone': {'fr': 'ZONE DANGEREUSE', 'ar': 'منطقة الخطر', 'en': 'DANGER ZONE'},
    'settings_profile_photo': {'fr': 'Photo de profil', 'ar': 'صورة الملف', 'en': 'Profile photo'},
    'settings_full_name': {'fr': 'Nom complet', 'ar': 'الاسم الكامل', 'en': 'Full name'},
    'settings_phone': {'fr': 'Téléphone', 'ar': 'الهاتف', 'en': 'Phone'},
    'settings_language': {'fr': 'Langue', 'ar': 'اللغة', 'en': 'Language'},
    'settings_dark_mode': {'fr': 'Mode sombre', 'ar': 'الوضع الداكن', 'en': 'Dark mode'},
    'settings_notifications': {'fr': 'Notifications', 'ar': 'الإشعارات', 'en': 'Notifications'},
    'settings_change_password': {'fr': 'Changer le mot de passe', 'ar': 'تغيير كلمة المرور', 'en': 'Change password'},
    'settings_delete_account': {'fr': 'Supprimer mon compte', 'ar': 'حذف حسابي', 'en': 'Delete account'},
    'coming_soon': {'fr': 'Bientôt disponible', 'ar': 'قريباً', 'en': 'Coming soon'},
    'artisan_tarif': {'fr': 'Tarif horaire', 'ar': 'السعر بالساعة', 'en': 'Hourly rate'},
    'artisan_disponibilite': {'fr': 'DISPONIBILITÉ', 'ar': 'التوفر', 'en': 'AVAILABILITY'},
    'phone_label': {'fr': 'Numéro de téléphone', 'ar': 'رقم الهاتف', 'en': 'Phone number'},
    'phone_invalid': {'fr': 'Numéro marocain invalide (06XXXXXXXX)', 'ar': 'رقم مغربي غير صالح', 'en': 'Invalid Moroccan number'},
    'search_title': {'fr': 'Annuaire des Artisans', 'ar': 'دليل الحرفيين', 'en': 'Artisan Directory'},
    'search_hint': {'fr': 'Rechercher un artisan, ville…', 'ar': 'ابحث عن حرفي، مدينة…', 'en': 'Search artisan, city…'},
    'search_no_results': {'fr': 'Aucun artisan trouvé', 'ar': 'لم يتم العثور على حرفيين', 'en': 'No artisans found'},
    'search_no_data': {'fr': "Aucun artisan n'est encore inscrit.", 'ar': 'لم يسجل أي حرفي بعد.', 'en': 'No artisans registered yet.'},
    'search_adjust_filters': {'fr': "Essayez d'ajuster vos critères de recherche.", 'ar': 'حاول تعديل معايير البحث.', 'en': 'Try adjusting your search criteria.'},
    'search_filters': {'fr': 'Filtres avancés', 'ar': 'مرشحات متقدمة', 'en': 'Advanced filters'},
    'search_budget': {'fr': 'Budget', 'ar': 'الميزانية', 'en': 'Budget'},
    'search_reset': {'fr': 'Réinitialiser', 'ar': 'إعادة تعيين', 'en': 'Reset'},
    'search_apply': {'fr': 'Appliquer', 'ar': 'تطبيق', 'en': 'Apply'},
    'search_new': {'fr': 'Nouveau', 'ar': 'جديد', 'en': 'New'},
    'detail_share_soon': {'fr': 'Partage bientôt disponible', 'ar': 'المشاركة قريباً', 'en': 'Sharing coming soon'},
    'detail_photos_optional': {'fr': 'Photos du problème (optionnel)', 'ar': 'صور المشكلة (اختياري)', 'en': 'Problem photos (optional)'},
    'detail_location_optional': {'fr': 'Ma position (optionnel)', 'ar': 'موقعي (اختياري)', 'en': 'My location (optional)'},
    'detail_enable_gps': {'fr': 'Activez le GPS', 'ar': 'فعّل GPS', 'en': 'Enable GPS'},
    'detail_availability': {'fr': 'Disponibilité', 'ar': 'التوفر', 'en': 'Availability'},
    'detail_contact': {'fr': 'Contact', 'ar': 'اتصال', 'en': 'Contact'},
    'detail_before': {'fr': 'AVANT', 'ar': 'قبل', 'en': 'BEFORE'},
    'detail_after': {'fr': 'APRÈS', 'ar': 'بعد', 'en': 'AFTER'},
    'detail_no_portfolio': {'fr': 'Aucune réalisation pour l\'instant', 'ar': 'لا توجد أعمال حالياً', 'en': 'No portfolio yet'},
    'geo_error': {'fr': 'Geolocalisation echouee', 'ar': 'فشل تحديد الموقع', 'en': 'Geolocation failed'},
    'admin_title': {'fr': 'Back-office Administrateur', 'ar': 'لوحة الإدارة', 'en': 'Admin Back-office'},
    'admin_delete_title': {'fr': 'Supprimer cet artisan ?', 'ar': 'حذف هذا الحرفي؟', 'en': 'Delete this artisan?'},
    'admin_delete_warning': {'fr': 'Cette action est irréversible.', 'ar': 'هذا الإجراء لا رجعة فيه.', 'en': 'This action is irreversible.'},
    'admin_artisan_deleted': {'fr': 'Artisan supprimé', 'ar': 'تم حذف الحرفي', 'en': 'Artisan deleted'},
    'admin_artisan_validated': {'fr': 'Artisan validé avec succès !', 'ar': 'تم تثبيت الحرفي بنجاح!', 'en': 'Artisan validated successfully!'},
    'admin_validation_error': {'fr': 'Erreur de validation', 'ar': 'خطأ في التحقق', 'en': 'Validation error'},
    'admin_ban_title': {"fr": "Bannir l'artisan ?", "ar": "حظر الحرفي؟", "en": "Ban this artisan?"},
    'admin_ban_warning': {"fr": "Cette action bloquera ses accès et marquera l'utilisateur comme banni.", "ar": "سيؤدي هذا إلى حظر وصوله ووضع علامة محظور.", "en": "This will block access and mark the user as banned."},
    'admin_ban': {'fr': 'Bannir', 'ar': 'حظر', 'en': 'Ban'},
    'admin_banned': {'fr': 'Artisan banni avec succès.', 'ar': 'تم حظر الحرفي بنجاح.', 'en': 'Artisan banned successfully.'},
    'admin_cin_label': {"fr": "Justificatif d'Identité (CIN) :", "ar": "وثيقة الهوية (البطاقة الوطنية):", "en": "ID Document (CIN):"},
    'admin_no_cin': {"fr": "Aucun justificatif uploadé par l'artisan.", "ar": "لم يرفع الحرفي أي وثيقة.", "en": "No document uploaded by the artisan."},
    'admin_close': {'fr': 'Fermer', 'ar': 'إغلاق', 'en': 'Close'},
    'admin_verification': {'fr': 'Vérification', 'ar': 'تحقق', 'en': 'Verification'},
    'admin_city': {'fr': 'Ville', 'ar': 'المدينة', 'en': 'City'},
    'admin_no_pending': {'fr': 'Aucun artisan en attente de vérification.', 'ar': 'لا يوجد حرفي في انتظار التحقق.', 'en': 'No artisans pending verification.'},
    'admin_no_verified': {'fr': 'Aucun artisan vérifié et actif pour le moment.', 'ar': 'لا يوجد حرفي موثق ونشط حالياً.', 'en': 'No verified active artisans yet.'},
    'admin_no_categories': {'fr': 'Aucune catégorie. Ajoutez-en une !', 'ar': 'لا توجد فئات. أضف واحدة!', 'en': 'No categories. Add one!'},
    'admin_validate': {'fr': 'Valider le compte', 'ar': 'تثبيت الحساب', 'en': 'Validate account'},
    'profile_take_photo': {'fr': 'Prendre une photo', 'ar': 'التقاط صورة', 'en': 'Take a photo'},
    'profile_choose_gallery': {'fr': 'Choisir depuis la galerie', 'ar': 'اختيار من المعرض', 'en': 'Choose from gallery'},
    'profile_photo_updated': {'fr': 'Photo de profil mise à jour !', 'ar': 'تم تحديث صورة الملف!', 'en': 'Profile photo updated!'},
    'profile_transfer_error': {'fr': 'Erreur lors du transfert', 'ar': 'خطأ أثناء النقل', 'en': 'Transfer error'},
    'profile_saved': {'fr': 'Fichier enregistré avec succès !', 'ar': 'تم حفظ الملف بنجاح!', 'en': 'File saved successfully!'},
    'profile_delete_image_title': {'fr': 'Supprimer cette image ?', 'ar': 'حذف هذه الصورة؟', 'en': 'Delete this image?'},
    'profile_image_removed': {'fr': 'Image retirée avec succès.', 'ar': 'تم حذف الصورة بنجاح.', 'en': 'Image removed successfully.'},
    'profile_delete_error': {'fr': 'Erreur lors de la suppression', 'ar': 'خطأ أثناء الحذف', 'en': 'Delete error'},
    'profile_updated': {'fr': 'Profil mis à jour avec succès !', 'ar': 'تم تحديث الملف بنجاح!', 'en': 'Profile updated successfully!'},
    'profile_title': {'fr': 'Mon Profil', 'ar': 'ملفي الشخصي', 'en': 'My Profile'},
    'profile_save': {'fr': 'Enregistrer', 'ar': 'حفظ', 'en': 'Save'},
    'profile_add_realization': {'fr': 'Ajouter une réalisation', 'ar': 'إضافة عمل', 'en': 'Add a realization'},
    'profile_retry': {'fr': 'Réessayer', 'ar': 'إعادة المحاولة', 'en': 'Retry'},
  };
}