import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart'; // 파일 이름에 맞게 수정

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    ),
  );
}