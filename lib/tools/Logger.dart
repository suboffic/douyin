class Logger {
  /* 普通输出 */
  static void Log(String title, {Object value}) {
    if (value != null) {
      print(
          ">>> 🔫Log: title: $title \n>>> 🔫Log: value:$value \n>>> 🔫Log: -End");
    } else {
      print(">>> 🔫Log: title: $title");
    }
  }

  /* 警告输出 */
  static void LogWarning(String title, {Object value}) {
    if (value != null) {
      print(
          ">>> 💊LogWarning: title: $title \n>>> 💊LogWarning: value:$value \n>>> 💊LogWarning: -End");
    } else {
      print(">>> 💊LogWarning: title: $title");
    }
  }

  /* 错误输出 */
  static void LogError(String title, {Object value}) {
    if (value != null) {
      print(
          ">>> 💉LogError: title: $title \n>>> 💉LogError: value:$value \n>>> 💉LogError: -End");
    } else {
      print(">>> 💉LogError: title: $title");
    }
  }
}
