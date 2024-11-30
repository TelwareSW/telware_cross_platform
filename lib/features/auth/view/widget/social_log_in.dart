import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';

class SocialLogIn extends ConsumerWidget {
  const SocialLogIn({
    super.key,
  });

  static const double _size = 35;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
              height: 1,
              width: 250,
              decoration: const BoxDecoration(color: Palette.primaryText)),
        ),
        const Text('or Continue with'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _socialButton(
              img: 'google-g-white.png',
              onTap: ref.read(authViewModelProvider.notifier).googleLogIn,
              key: Keys.googleLogIn,
            ),
            _socialButton(
              img: 'github-icon-white.png',
              onTap: ref.read(authViewModelProvider.notifier).githubLogIn,
              key: Keys.githubLogIn,
            ),
          ],
        )
      ],
    );
  }

  Widget _socialButton(
          {required VoidCallback onTap,
          required String img,
          required Key key}) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        width: _size,
        height: _size,
        child: InkWell(
          key: key,
          onTap: onTap,
          child: Image.asset('assets/imgs/$img'),
        ),
      );
}
