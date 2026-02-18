class QuoteItem {
  final int? id;
  final int quoteId;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  QuoteItem({
    this.id,
    required this.quoteId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  QuoteItem copyWith({
    int? id,
    int? quoteId,
    String? description,
    int? quantity,
    double? unitPrice,
    double? total,
  }) {
    return QuoteItem(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote_id': quoteId,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
    };
  }

  factory QuoteItem.fromMap(Map<String, dynamic> map) {
    return QuoteItem(
      id: map['id'] as int?,
      quoteId: map['quote_id'] as int,
      description: map['description'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
    );
  }
}
