import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/stories/view/widget/stories_list_with_names.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../view_model/contact_view_model.dart';

class ExpandedStoriesSection extends ConsumerWidget {
  const ExpandedStoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(usersViewModelProvider.notifier).fetchContacts();
    final isLoading = ref.watch(usersViewModelProvider.select((state) => state.isLoading));
    debugPrint('Building ExpandedStoriesSection...');

    return LayoutBuilder(
      builder: (context, constraints) {
        return isLoading ? const CircularProgressIndicator() : const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: kIsWeb ? kToolbarHeight : kToolbarHeight + 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: StoriesListWithNames(),
            ),
          ],
        );
      },
    );
  }
}
