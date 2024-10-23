import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Palette.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _header(context),
          _drawerItems(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      // margin: EdgeInsets.zero,
      padding: EdgeInsets.only(
          top: 12 + MediaQuery.of(context).padding.top,
          right: 12,
          left: 18,
          bottom: 8),
      color: Palette.drawerHeader,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                minRadius: 34,
                backgroundImage: NetworkImage(
                  'https://animenew.com.br/wp-content/uploads/2022/03/Este-e-o-PRIMEIRO-ESBOCO-do-VISUAL-de-Kamado-Tanjiro-em-Demon-Slayer-jpg.webp',
                  // fit: BoxFit.,
                ),
              ),
              SizedBox(height: 18),
              // todo: take real user name and number
              Text(
                'Ahmed Aladdin',
                style: TextStyle(
                    color: Palette.primaryText, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                '+20 011 00000001',
                style: TextStyle(
                    color: Palette.accentText, fontSize: Sizes.infoText),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.sunny, color: Palette.icons))
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawerItems(BuildContext context) {
    return Wrap(
      children: <Widget>[
        _drawerItem(context, Icons.account_circle_outlined, 'My Profile'),
      ],
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Palette.accentText),
      title: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
                color: Palette.primaryText, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
