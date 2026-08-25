import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fuenfzigohm/repository/setting_repository.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/ui/welcome/bloc/welcome_bloc.dart';
import 'package:fuenfzigohm/ui/welcome/pages/welcome_page.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WelcomeBloc>(
      create: (context) => WelcomeBloc(
        settingRepository: context.read<SettingRepository>(),
      )..add(WelcomeFetchStatusEvent()),
      child: BlocBuilder<WelcomeBloc, WelcomeState>(
        builder: (context, state) {
          if (state.status == WelcomeStatus.courseSelected) {
            return Learningmodule();
          }
          return BlocListener<WelcomeBloc, WelcomeState>(
            listener: (context, state) {
              if (state.status == WelcomeStatus.courseSelected) {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/learn", (r) => false);
              }
            },
            child: WelcomePage(),
          );
        },
      ),
    );
  }
}
