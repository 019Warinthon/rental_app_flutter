import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _darkMode = false;

  bool get pushNotifications => _pushNotifications;
  bool get emailAlerts => _emailAlerts;
  bool get darkMode => _darkMode;

  void togglePushNotifications() {
    _pushNotifications = !_pushNotifications;
    notifyListeners();
  }

  void toggleEmailAlerts() {
    _emailAlerts = !_emailAlerts;
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }
}
