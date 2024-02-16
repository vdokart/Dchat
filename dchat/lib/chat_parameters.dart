class ChatParameters {
  static const String appName = 'DChat';
  static const String dbName = 'dchat.db';
  static const int dbVersion = 1;
  static const String chatTable = 'chats';
  static const String userTable = 'users';
  static const String idColumn = 'id';
  static const String senderColumn = 'sender';
  static const String messageColumn = 'message';
  static const String timestampColumn = 'timestamp';
  static const String usernameColumn = 'username';
  static const String passwordColumn = 'password';
  static const String createChatTableQuery = '''
    CREATE TABLE $chatTable(
      $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
      $senderColumn TEXT,
      $messageColumn TEXT,
      $timestampColumn TEXT
    )
  ''';
  static const String createUserTableQuery = '''
    CREATE TABLE $userTable(
      $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
      $usernameColumn TEXT,
      $passwordColumn TEXT
    )
  ''';
  static const String insertChatMessageQuery = '''
    INSERT INTO $chatTable($senderColumn, $messageColumn, $timestampColumn)
    VALUES(?, ?, ?)
  ''';
  static const String selectChatMessagesQuery = '''
    SELECT * FROM $chatTable
  ''';
  static const String insertUserQuery = '''
    INSERT INTO $userTable($usernameColumn, $passwordColumn)
    VALUES(?, ?)
  ''';
  static const String selectUserQuery = '''
    SELECT * FROM $userTable
    WHERE $usernameColumn = ?
    AND $passwordColumn = ?
  ''';
  static const String selectUserByUsernameQuery = '''
    SELECT * FROM $userTable
    WHERE $usernameColumn = ?
  ''';
  static const String selectUserByIdQuery = '''
    SELECT * FROM $userTable
    WHERE $idColumn = ?
  ''';
  static const String deleteUserQuery = '''
    DELETE FROM $userTable
    WHERE $idColumn = ?
  ''';
  static const String updateUserQuery = '''
    UPDATE $userTable
    SET $usernameColumn = ?, $passwordColumn = ?
    WHERE $idColumn = ?
  ''';
  static const String deleteChatMessageQuery = '''
    DELETE FROM $chatTable
    WHERE $idColumn = ?
  ''';
  static const String updateChatMessageQuery = '''
    UPDATE $chatTable
    SET $senderColumn = ?, $messageColumn = ?, $timestampColumn = ?
    WHERE $idColumn = ?
  ''';
  static const String deleteAllChatMessagesQuery = '''
    DELETE FROM $chatTable
  ''';
}
