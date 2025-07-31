import 'package:flutter/material.dart';

import 'package:fuenfzigohm/ui/welcome/pages/welcome_layout.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WelcomeLayout(),
    );
  }
}
