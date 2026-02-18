class Client {
  final int? id;
  final String name;
  final String? identification;
  final String phone;
  final String email;
  final String address;
  final DateTime createdAt;

  Client({
    this.id,
    required this.name,
    this.identification,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdAt,
  });

  Client copyWith({
    int? id,
    String? name,
    String? identification,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      identification: identification ?? this.identification,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
