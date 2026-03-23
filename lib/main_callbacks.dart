import 'package:flutter/material.dart';

class MainCallbacks {
  static void Function(bool?)? setDrawerVisibility;
  static void Function(bool?)? setMemberBarVisibility;
  static void Function(Exception)? showError;
  static void Function(Widget?)? setPage;

  static void dispose() {
    MainCallbacks.setDrawerVisibility = null;
    MainCallbacks.setMemberBarVisibility = null;
    MainCallbacks.showError = null;
    MainCallbacks.setPage = null;
  }
}
