import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/stories_list_with_names.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class ExpandedStoriesSection extends StatelessWidget
    implements PreferredSizeWidget {
  ExpandedStoriesSection({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: kIsWeb ? kToolbarHeight : kToolbarHeight + 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Flexible(child: StoriesListWithNames()),
              ],
            ),
          ),
        ],
      );},
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
