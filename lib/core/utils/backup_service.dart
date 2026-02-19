import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class BackupService {
  static Future<String> exportDatabase() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = path.join(dbPath, AppConstants.dbName);
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupPath = path.join(directory.path, 'servicios_pro_backup_$timestamp.db');
    
    final sourceFile = File(sourcePath);
    await sourceFile.copy(backupPath);
    
    return backupPath;
  }

  static Future<void> restoreDatabase(String backupPath) async {
    final dbPath = await getDatabasesPath();
    final targetPath = path.join(dbPath, AppConstants.dbName);
    
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('Archivo de respaldo no encontrado');
    }
    
    await backupFile.copy(targetPath);
  }

  static Future<List<FileSystemEntity>> getBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory(directory.path);
    
    if (!await dir.exists()) {
      return [];
    }
    
    final files = await dir.list().where((entity) => 
      entity is File && entity.path.contains('servicios_pro_backup_')
    ).toList();
    
    files.sort((a, b) => b.path.compareTo(a.path));
    
    return files;
  }

  static Future<void> deleteBackup(String backupPath) async {
    final file = File(backupPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
