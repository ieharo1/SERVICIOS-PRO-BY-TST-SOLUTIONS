class BusinessProfile {
  final int? id;
  final String companyName;
  final String? logoPath;
  final String phone;
  final String email;
  final String address;
  final String ruc;
  final String? signaturePath;
  final String currency;
  final double taxRate;

  BusinessProfile({
    this.id,
    required this.companyName,
    this.logoPath,
    required this.phone,
    required this.email,
    required this.address,
    required this.ruc,
    this.signaturePath,
    required this.currency,
    required this.taxRate,
  });

  BusinessProfile copyWith({
    int? id,
    String? companyName,
    String? logoPath,
    String? phone,
    String? email,
    String? address,
    String? ruc,
    String? signaturePath,
    String? currency,
    double? taxRate,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      logoPath: logoPath ?? this.logoPath,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      ruc: ruc ?? this.ruc,
      signaturePath: signaturePath ?? this.signaturePath,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}
