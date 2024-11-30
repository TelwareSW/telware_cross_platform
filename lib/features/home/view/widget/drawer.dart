import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/user/view/screens/settings_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/user_profile_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      elevation: 20,
      backgroundColor: Palette.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _header(context, ref),
          _drawerItems(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userImageBytes = user?.photoBytes;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                minRadius: 34,
                backgroundImage:
                    userImageBytes != null ? MemoryImage(userImageBytes) : null,
                backgroundColor:
                    userImageBytes == null ? Palette.primary : null,
                child: userImageBytes == null
                    ? Text(
                        getInitials('${user!.screenFirstName} ${user.screenLastName}'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Palette.primaryText,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 18),
              // todo: take real user name and number
              Text(
                '${user!.screenFirstName} ${user.screenLastName}',
                style: const TextStyle(
                    color: Palette.primaryText, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                user.phone ,
                style: const TextStyle(
                    color: Palette.accentText, fontSize: Sizes.infoText),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.light_mode_rounded,
                      color: Palette.icons))
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
        _drawerItem(context, Icons.account_circle_outlined, 'My Profile',
            verticalPadding: 5, route: UserProfileScreen.route),
        const Divider(thickness: 0.3, color: Palette.black, height: 0),
        _drawerItem(context, Icons.people_alt_outlined, 'New Group'),
        _drawerItem(context, Icons.person_outline_rounded, 'Contacts'),
        _drawerItem(context, Icons.call_outlined, 'Calls'),
        _drawerItem(context, Icons.bookmark_outline_rounded, 'Saved Messages'),
        _drawerItem(context, Icons.settings_outlined, 'Settings',
            route: SettingsScreen.route),
        const Divider(thickness: 0.3, color: Palette.black, height: 0),
        _drawerItem(context, Icons.person_add_outlined, 'Invite Friends'),
        _drawerItem(context, Icons.info_outlined, 'TelWare Features'),
      ],
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title,
      {double verticalPadding = 0, String? route}) {
    return ListTile(
      // tileColor: Colors.red,
      contentPadding:
          EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 19),
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
          context.pop();
          context.push(route);
        } else {
          showToastMessage('Coming Soon...');
        }
      },
    );
  }
}
