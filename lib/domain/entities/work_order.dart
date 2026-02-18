class WorkOrder {
  final int? id;
  final String orderNumber;
  final int? quoteId;
  final String quoteNumber;
  final int clientId;
  final String clientName;
  final String status;
  final DateTime date;
  final String? observations;
  final String? clientSignaturePath;
  final double total;
  final DateTime createdAt;

  WorkOrder({
    this.id,
    required this.orderNumber,
    this.quoteId,
    required this.quoteNumber,
    required this.clientId,
    required this.clientName,
    required this.status,
    required this.date,
    this.observations,
    this.clientSignaturePath,
    required this.total,
    required this.createdAt,
  });

  WorkOrder copyWith({
    int? id,
    String? orderNumber,
    int? quoteId,
    String? quoteNumber,
    int? clientId,
    String? clientName,
    String? status,
    DateTime? date,
    String? observations,
    String? clientSignaturePath,
    double? total,
    DateTime? createdAt,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      quoteId: quoteId ?? this.quoteId,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      date: date ?? this.date,
      observations: observations ?? this.observations,
      clientSignaturePath: clientSignaturePath ?? this.clientSignaturePath,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'quote_id': quoteId,
      'quote_number': quoteNumber,
      'client_id': clientId,
      'client_name': clientName,
      'status': status,
      'date': date.toIso8601String(),
      'observations': observations,
      'client_signature_path': clientSignaturePath,
      'total': total,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkOrder.fromMap(Map<String, dynamic> map) {
    return WorkOrder(
      id: map['id'] as int?,
      orderNumber: map['order_number'] as String,
      quoteId: map['quote_id'] as int?,
      quoteNumber: map['quote_number'] as String,
      clientId: map['client_id'] as int,
      clientName: map['client_name'] as String,
      status: map['status'] as String,
      date: DateTime.parse(map['date'] as String),
      observations: map['observations'] as String?,
      clientSignaturePath: map['client_signature_path'] as String?,
      total: (map['total'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
