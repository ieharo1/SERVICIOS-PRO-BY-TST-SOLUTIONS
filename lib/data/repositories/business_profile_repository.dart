import 'package:sqflite/sqflite.dart';
import '../datasources/database_helper.dart';
import '../../domain/entities/business_profile.dart';

class BusinessProfileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<BusinessProfile?> getProfile() async {
    final db = await _dbHelper.database;
    final result = await db.query('business_profile', limit: 1);
    
    if (result.isEmpty) return null;
    
    final map = result.first;
    return BusinessProfile(
      id: map['id'] as int?,
      companyName: map['company_name'] as String,
      logoPath: map['logo_path'] as String?,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      ruc: map['ruc'] as String,
      signaturePath: map['signature_path'] as String?,
      currency: map['currency'] as String,
      taxRate: (map['tax_rate'] as num).toDouble(),
    );
  }

  Future<int> saveProfile(BusinessProfile profile) async {
    final db = await _dbHelper.database;
    
    final existing = await getProfile();
    
    final data = {
      'company_name': profile.companyName,
      'logo_path': profile.logoPath,
      'phone': profile.phone,
      'email': profile.email,
      'address': profile.address,
      'ruc': profile.ruc,
      'signature_path': profile.signaturePath,
      'currency': profile.currency,
      'tax_rate': profile.taxRate,
    };
    
    if (existing != null) {
      await db.update(
        'business_profile',
        data,
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return existing.id!;
    } else {
      return await db.insert('business_profile', data);
    }
  }
}
