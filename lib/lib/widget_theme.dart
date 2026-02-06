import 'dart:collection';

import 'package:flutter/material.dart';

class LoginButtonColor extends WidgetStateColor {
  const LoginButtonColor() : super(_defaultColor);

  static const _defaultColor = 0xFF2196F3; // Blue

  @override
  Color resolve(Set<WidgetState> states) {
    return const Color(_defaultColor);
  }
}

class RegisterButtonColor extends WidgetStateColor {
  const RegisterButtonColor() : super(_defaultColor);

  static const _defaultColor = 0xFF4CAF50; // Green

  @override
  Color resolve(Set<WidgetState> states) {
    return const Color(_defaultColor);
  }
}

class CancelButtonColor extends WidgetStateColor {
  const CancelButtonColor() : super(_defaultColor);

  static const _defaultColor = 0xFFF44336; // Red

  @override
  Color resolve(Set<WidgetState> states) {
    return const Color(_defaultColor);
  }
}
