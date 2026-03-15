class MainCallbacks {
  static void Function(bool?)? setDrawerVisibility;
  static void Function(bool?)? setMemberBarVisibility;
  static void Function(Exception)? showError;

  static void dispose() {
    MainCallbacks.setDrawerVisibility = null;
    MainCallbacks.setMemberBarVisibility = null;
    MainCallbacks.showError = null;
  }
}
