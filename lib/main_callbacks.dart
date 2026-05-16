import 'package:flutter/material.dart';

class MainCallbacks {
  static void Function(bool?)? setDrawerVisibility;
  static void Function((Widget, Widget)?)? setSidebar;
  static void Function(Exception)? showError;
  static void Function(Widget?)? setPage;

  static void dispose() {
    MainCallbacks.setDrawerVisibility = null;
    MainCallbacks.setSidebar = null;
    MainCallbacks.showError = null;
    MainCallbacks.setPage = null;
  }
}
