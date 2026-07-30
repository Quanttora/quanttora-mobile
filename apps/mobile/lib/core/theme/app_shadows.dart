import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> strong = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 36,
      spreadRadius: 0,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: Color(0x332563EB),
      blurRadius: 24,
      spreadRadius: 2,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glowSuccess = [
    BoxShadow(
      color: Color(0x3316A34A),
      blurRadius: 24,
      spreadRadius: 2,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> none = [];
}