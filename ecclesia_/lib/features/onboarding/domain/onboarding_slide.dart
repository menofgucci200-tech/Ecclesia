/// The static copy for one onboarding slide.
class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final String title;
  final String subtitle;
  final String description;
}

const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    title: 'Bienvenue sur Ecclesia !',
    subtitle:
        'Restez connecté à votre paroisse partout où vous allez, en toute sécurité.',
    description:
        'Rejoignez des milliers de fidèles et recevez toutes les informations '
        'de votre paroisse en un seul endroit.',
  ),
  OnboardingSlide(
    title: 'Suivez la vie de votre paroisse',
    subtitle:
        'Annonces, horaires de messe et actualités, directement sur votre téléphone.',
    description:
        'Ne manquez plus jamais un événement important de votre communauté paroissiale.',
  ),
  OnboardingSlide(
    title: 'Une seule paroisse, une seule communauté',
    subtitle: 'Rejoignez votre paroisse en quelques instants.',
    description:
        'Créez votre profil, retrouvez votre paroisse et participez pleinement '
        'à la vie de votre communauté.',
  ),
];
