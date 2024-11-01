import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/stories/repository/contacts_remote_repository.dart';

import '../../../../core/models/user_model.dart';


class ProfileHeader extends ConsumerWidget {
  final double factor;

  const ProfileHeader({super.key, this.factor = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userImageBytes = user?.photoBytes;

    Future<Uint8List?> _buildScreen()async{
      UserModel? newUser = await ref.watch(authLocalRepositoryProvider).getMe();


      if(newUser?.photo == user?.photo){ //user doesn't change his picture
        if(userImageBytes == null){
          // ref.watch(contactsRemoteRepositoryProvider).updateProfilePicture(storyImage);
        }
      }
    }

    return FutureBuilder(future: _buildScreen(), builder: (context,snapshot){
      return Padding(
        padding: EdgeInsets.fromLTRB(factor, 0, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundImage:
              userImageBytes != null ? MemoryImage(userImageBytes) : null,
              backgroundColor:
              userImageBytes == null ? Palette.primary : null,
              child: userImageBytes == null
                  ? Text(
                getInitials(user?.screenName ?? 'Moamen Hefny'),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Palette.primaryText,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.screenName ?? 'Moamen Hefny',
                  style: TextStyle(
                    fontSize: 14  + 6 * factor / 100,
                    fontWeight: FontWeight.bold,
                    color: Palette.primaryText,
                  ),
                ),
                Text(
                  user?.status ?? 'no status',
                  style: TextStyle(
                    fontSize: 10  + 6 * factor / 100,
                    color: Palette.accentText,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
