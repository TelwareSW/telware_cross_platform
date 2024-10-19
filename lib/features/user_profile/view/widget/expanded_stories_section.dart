import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/stories_list_with_names.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../view_model/user_view_model.dart';

class ExpandedStoriesSection extends ConsumerWidget
    implements PreferredSizeWidget {
  ExpandedStoriesSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(usersViewModelProvider.notifier).fetchUsers();
    print('fsdfsdfds');
    final viewModelState = ref.watch(usersViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {

        return viewModelState.isLoading ? CircularProgressIndicator() : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: kIsWeb ? kToolbarHeight : kToolbarHeight + 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StoriesListWithNames(),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
