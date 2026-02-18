import 'quote_item.dart';

class Quote {
  final int? id;
  final String quoteNumber;
  final int clientId;
  final String clientName;
  final String status;
  final DateTime date;
  final DateTime validUntil;
  final String? notes;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final List<QuoteItem> items;
  final DateTime createdAt;

  Quote({
    this.id,
    required this.quoteNumber,
    required this.clientId,
    required this.clientName,
    required this.status,
    required this.date,
    required this.validUntil,
    this.notes,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.items,
    required this.createdAt,
  });

  Quote copyWith({
    int? id,
    String? quoteNumber,
    int? clientId,
    String? clientName,
    String? status,
    DateTime? date,
    DateTime? validUntil,
    String? notes,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    List<QuoteItem>? items,
    DateTime? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      date: date ?? this.date,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote_number': quoteNumber,
      'client_id': clientId,
      'client_name': clientName,
      'status': status,
      'date': date.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'notes': notes,
      'subtotal': subtotal,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total': total,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map, {List<QuoteItem>? items}) {
    return Quote(
      id: map['id'] as int?,
      quoteNumber: map['quote_number'] as String,
      clientId: map['client_id'] as int,
      clientName: map['client_name'] as String,
      status: map['status'] as String,
      date: DateTime.parse(map['date'] as String),
      validUntil: DateTime.parse(map['valid_until'] as String),
      notes: map['notes'] as String?,
      subtotal: (map['subtotal'] as num).toDouble(),
      taxRate: (map['tax_rate'] as num).toDouble(),
      taxAmount: (map['tax_amount'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      items: items ?? [],
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
