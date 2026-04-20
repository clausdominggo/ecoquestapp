part of questapp;

class LaunchGate extends StatelessWidget {
  const LaunchGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionStore.hasAccessToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return FutureBuilder<bool>(
            future: SessionStore.hasTutorialBeenCompleted(),
            builder: (context, tutorialSnapshot) {
              if (!tutorialSnapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (tutorialSnapshot.data == false) {
                return const TutorialWizardScreen();
              }

              return const QuestMapScreen();
            },
          );
        }

        return const SplashScreen();
      },
    );
  }
}
