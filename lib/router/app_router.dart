import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:profile/profile.dart';

abstract final class AppRoutes {
  static const authGate = '/';
  static const login = AuthRoutes.login;
  static const mainShell = '/main';
}

typedef RouteBuilder = Route<dynamic> Function(RouteSettings settings);

abstract final class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routes = <String, RouteBuilder>{
      AppRoutes.authGate: (_) =>
          MaterialPageRoute<void>(builder: (_) => const AuthGatePage()),
      ...AuthRoutes.routes,
    };

    final builder = routes[settings.name];
    if (builder == null) {
      return MaterialPageRoute<void>(builder: (_) => const AuthGatePage());
    }

    return builder(settings);
  }
}

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final observeAuthState = GetIt.I.get<ObserveAuthStateUseCase>();

    return StreamBuilder(
      stream: observeAuthState.invoke(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashPage();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        return MainShellPage(user: user);
      },
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AuthStrings.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: PlayceColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: PlayceSpacing.lg),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MainShellPage extends StatefulWidget {
  const MainShellPage({required this.user, super.key});

  final User user;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  int _exploreRefreshKey = 0;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = GetIt.I.get<ProfileCubit>()..load(widget.user.id);
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final isWoman = switch (profileState) {
            ProfileLoadedState(:final profile) => profile.isWoman,
            ProfileActionLoadingState(:final profile) => profile.isWoman,
            _ => false,
          };

          final pages = [
            ExplorePage(
              key: ValueKey(_exploreRefreshKey),
              userId: widget.user.id,
              isWoman: isWoman,
            ),
            const _PlaceholderTab(
              title: EventsStrings.mapPlaceholderTitle,
              message: EventsStrings.mapPlaceholderMessage,
              icon: Icons.map_outlined,
            ),
            ProfilePage(
              userId: widget.user.id,
              email: widget.user.email,
              displayName: widget.user.displayName,
              photoUrl: widget.user.photoUrl,
              onSignOut: () => GetIt.I.get<SignOutUseCase>().invoke(),
            ),
          ];

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: pages),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openCreateEvent,
              icon: const Icon(Icons.add),
              label: const Text('Criar'),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Explorar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Mapa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCreateEvent() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateEventPage(
          userId: widget.user.id,
          userEmail: widget.user.email,
          userDisplayName: widget.user.displayName,
        ),
      ),
    );

    if (created == true && mounted) {
      setState(() {
        _currentIndex = 0;
        _exploreRefreshKey++;
      });
    }
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PlayceEmptyState(title: title, message: message, icon: icon);
  }
}
