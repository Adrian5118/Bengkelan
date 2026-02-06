import 'package:mysql_utils/mysql_utils.dart';

class DatabaseHandler {
  DatabaseHandler._();

  final String _host = "";
  final int _port = 3306;
  final String _username = "root";
  final String _password = "";
  final String _dbName = "bengkelan_db";

  late MysqlUtils? _db;
  static final DatabaseHandler _handler = DatabaseHandler._();

  factory DatabaseHandler() {
    return _handler;
  }

  static void open(Map<String, Object> entries) {
    // Host
    if (!entries.containsKey("host")) {
      throw Exception("Host not set");
    }
    if (entries["host"] is! String) {
      throw Exception("Host must be a string");
    }

    // Port
    if (!entries.containsKey("port")) {
      throw Exception("Port not set");
    }
    if (entries["port"] is! int) {
      throw Exception("Port must be an integer");
    }

    // Username
    if (!entries.containsKey("username")) {
      throw Exception("Username not set");
    }
    if (entries["username"] is! String) {
      throw Exception("Username must be a string");
    }

    // Password
    if (!entries.containsKey("password")) {
      throw Exception("Password not set");
    }
    if (entries["password"] is! String) {
      throw Exception("Password must be a string");
    }

    // Database Name
    if (!entries.containsKey("dbName")) {
      throw Exception("Database name not set");
    }
    if (entries["dbName"] is! String) {
      throw Exception("Database name must be a string");
    }

    // Finally
    _handler._db = MysqlUtils(
      settings: MysqlUtilsSettings(
        host: entries["host"] as String,
        port: entries["port"] as int,
        user: entries["username"] as String,
        password: entries["password"] as String,
        db: entries["dbName"] as String,
        secure: false,
      ),
    );
  }

  static MysqlUtils get() {
    if (_handler._db == null) {
      throw Exception("Database handler not yet initialized");
    }

    return _handler._db!;
  }
}
