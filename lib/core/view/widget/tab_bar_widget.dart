import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class TabBarWidget extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  final bool isScrollable;
  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? padding;

  const TabBarWidget({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
    this.labelPadding,
    this.padding = const EdgeInsets.only(left: 4.0, right: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      padding: padding,
      isScrollable: isScrollable,
      dividerHeight: 0,
      dividerColor: Colors.transparent,
      tabAlignment: isScrollable ? TabAlignment.start : null,
      indicator: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(3),
        ),
        border: Border(
          top: BorderSide(
            color: Palette.primary,
            width: 4.0,
          ),
        ),
      ),
      indicatorPadding: const EdgeInsets.only(top: 44),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        color: Palette.primary,
      ),
      unselectedLabelColor: Palette.accentText,
      physics: const BouncingScrollPhysics(),
      labelPadding: labelPadding,
      tabs: tabs,
    );
  }
}