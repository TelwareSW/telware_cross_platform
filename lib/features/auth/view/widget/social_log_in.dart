import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class SocialLogIn extends StatelessWidget {
  const SocialLogIn({
    super.key,
  });

  static const double _size = 35;

  @override
  Widget build(BuildContext context) {
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
            _socialButton(img: 'google-g-white.png', onTap: () {}),
            _socialButton(img: 'facebook-f-white.png', onTap: () {}),
            _socialButton(img: 'github-icon-white.png', onTap: () {}),
          ],
        )
      ],
    );
  }

  Widget _socialButton({required VoidCallback onTap, required String img}) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        width: _size,
        height: _size,
        child: InkWell(
          onTap: onTap,
          child: Image.asset('assets/imgs/$img'),
        ),
      );
}
