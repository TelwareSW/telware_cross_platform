import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 20,
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
                  icon: const Icon(Icons.light_mode_rounded, color: Palette.icons))
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawerItems(BuildContext context) {
    return Wrap(
      children: <Widget>[
        // todo(ahmed): add routes to the drawer items when available
        _drawerItem(context, Icons.account_circle_outlined, 'My Profile', verticalPadding: 5),
        const Divider(thickness: 0.3, color: Palette.black, height: 0),
        _drawerItem(context, Icons.people_alt_outlined, 'New Group'),
        _drawerItem(context, Icons.person_outline_rounded, 'Contacts'),
        _drawerItem(context, Icons.call_outlined, 'Calls'),
        _drawerItem(context, Icons.bookmark_outline_rounded, 'Saved Messages'),
        _drawerItem(context, Icons.settings_outlined, 'Settings'),
        const Divider(thickness: 0.3, color: Palette.black, height: 0),
        _drawerItem(context, Icons.person_add_outlined, 'Invite Friends'),
        _drawerItem(context, Icons.info_outlined, 'TelWare Features'),
      ],
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, {double verticalPadding = 0, String? route}) {
    return ListTile(
      // tileColor: Colors.red,
      contentPadding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 19),
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
      onTap: () {
        if (route != null) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        } else {
          showToastMessage('Coming Soon...');
        }
      },
    );
  }
}