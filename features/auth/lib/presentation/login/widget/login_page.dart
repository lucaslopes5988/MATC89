import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:auth/presentation/login/bloc/login_cubit.dart';
import 'package:auth/presentation/login/bloc/login_state.dart';
import 'package:auth/presentation/strings.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I.get<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginErrorState) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoadingState;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PlayceGradientHeader(
                  title: AuthStrings.appName,
                  subtitle: AuthStrings.loginSubtitle,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(PlayceSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AuthStrings.loginTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: PlayceSpacing.xl),
                        PlaycePrimaryButton(
                          label: AuthStrings.googleSignIn,
                          icon: Icons.g_mobiledata_rounded,
                          isLoading: isLoading,
                          onPressed: () => context.read<LoginCubit>().signIn(),
                        ),
                        const SizedBox(height: PlayceSpacing.lg),
                        Text(
                          AuthStrings.firebaseSetupHint,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: PlayceColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
