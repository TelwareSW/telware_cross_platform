import 'package:flutter/material.dart';

class Session {
  final String title;
  final List<SessionOption> options;
  final String trailing;

  Session({required this.title, required this.options, required this.trailing});
}

class SessionOption {
  final IconData icon;
  final String phoneName;
  final String telegramVersion;
  final String location;
  final String state;
  final Color? color;
  final void Function()? onTap;

  SessionOption({
    required this.icon,
    required this.phoneName,
    required this.telegramVersion,
    required this.location,
    required this.state,
    this.color,
    this.onTap,
  });
}