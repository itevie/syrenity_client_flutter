class MainCallbacks {
  static void Function(bool?)? setDrawerVisibility;
  static void Function(Exception)? showError;

  static void dispose() {
    MainCallbacks.setDrawerVisibility = null;
    MainCallbacks.showError = null;
  }
}
