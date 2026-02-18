import '../datasources/database_helper.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> isDarkMode() async {
    final value = await _dbHelper.getSetting('dark_mode');
    return value == 'true';
  }

  Future<void> setDarkMode(bool value) async {
    await _dbHelper.setSetting('dark_mode', value.toString());
  }
}
