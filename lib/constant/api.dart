class Api {
  static const String baseUrl =
      "http://192.168.1.10/d_follow_up_php/"; //เปลี่ยนเป็น IP
  static const String getCustomers = "${baseUrl}get_customers.php";
  static const String add_report = "${baseUrl}add_report.php";
  static const String report = "${baseUrl}report.php";
  static const String delete_report = "${baseUrl}delete_report.php";
  static const String login = "${baseUrl}login.php";
  static const String get_report_detail = "${baseUrl}get_report_detail.php";
  static const String update_status = "${baseUrl}update_status.php";
  static const String get_users = "${baseUrl}get_users.php";
  static const String add_users = "${baseUrl}add_users.php";
  static const String delete_user = "${baseUrl}delete_user.php";
  static const String edit_user = "${baseUrl}edit_user.php";
  static const String update_report = "${baseUrl}update_report.php";
}
