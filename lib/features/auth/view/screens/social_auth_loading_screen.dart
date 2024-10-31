import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';

class SocialAuthLoadingScreen extends ConsumerStatefulWidget {
  const SocialAuthLoadingScreen({super.key, required this.secretSessionId});
  static const String route = '/social-auth-loading';

  final String secretSessionId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SocialAuthLoadingScreenState();
}

class _SocialAuthLoadingScreenState
    extends ConsumerState<SocialAuthLoadingScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).authorizeOAuth(widget.secretSessionId);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (_, state) {
      if (state.type == AuthStateType.fail) {
        showToastMessage(state.message!);
        context.go(Routes.logIn);
      } else if (state.type == AuthStateType.authenticated) {
        context.push(Routes.home);
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
