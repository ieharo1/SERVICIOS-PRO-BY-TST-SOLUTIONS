import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quote.dart';
import '../../../domain/entities/quote_item.dart';
import '../../../domain/entities/client.dart';
import '../../providers/quote_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/business_profile_provider.dart';

class QuoteFormScreen extends ConsumerStatefulWidget {
  final int? quoteId;
  final bool convertToOrder;

  const QuoteFormScreen({super.key, this.quoteId, this.convertToOrder = false});

  @override
  ConsumerState<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends ConsumerState<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  Client? _selectedClient;
  DateTime _date = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  String _status = 'Borrador';
  List<QuoteItem> _items = [];
  double _taxRate = 12.0;
  String _currency = 'USD';
  
  bool _isLoading = false;
  Quote? _existingQuote;
  String _quoteNumber = '';

  bool get isEditing => widget.quoteId != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final profileAsync = ref.read(businessProfileNotifierProvider);
    profileAsync.whenData((profile) {
      if (profile != null) {
        _taxRate = profile.taxRate;
        _currency = profile.currency;
      }
    });

    if (isEditing) {
      await _loadQuote();
    } else if (widget.convertToOrder && widget.quoteId != null) {
      await _loadQuote();
    } else {
      _quoteNumber = await ref.read(quotesNotifierProvider.notifier).getNextQuoteNumber();
    }
    setState(() {});
  }

  Future<void> _loadQuote() async {
    setState(() => _isLoading = true);
    final repository = ref.read(quoteRepositoryProvider);
    final quoteId = widget.quoteId ?? 0;
    final quote = await repository.getQuoteById(quoteId);
    if (quote != null) {
      _existingQuote = quote;
      _quoteNumber = quote.quoteNumber;
      _selectedClient = await ref.read(clientRepositoryProvider).getClientById(quote.clientId);
      _date = quote.date;
      _validUntil = quote.validUntil;
      _status = quote.status;
      _items = List.from(quote.items);
      _notesController.text = quote.notes ?? '';
      _taxRate = quote.taxRate;
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.total);
  double get _taxAmount => _subtotal * (_taxRate / 100);
  double get _total => _subtotal + _taxAmount;

  void _addItem() {
    setState(() {
      _items.add(QuoteItem(
        id: null,
        quoteId: _existingQuote?.id ?? 0,
        description: '',
        quantity: 1,
        unitPrice: 0,
        total: 0,
      ));
    });
  }

  void _updateItem(int index, QuoteItem item) {
    setState(() {
      _items[index] = item.copyWith(total: item.quantity * item.unitPrice);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _selectClient() async {
    final clients = await ref.read(clientRepositoryProvider).getAllClients();
    if (!mounted) return;
    
    final selected = await showModalBottomSheet<Client>(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return ListTile(
            title: Text(client.name),
            subtitle: Text(client.phone),
            onTap: () => Navigator.pop(context, client),
          );
        },
      ),
    );
    
    if (selected != null) {
      setState(() => _selectedClient = selected);
    }
  }

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un cliente')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un ítem')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_selectedClient == null || _selectedClient!.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un cliente válido')),
        );
      }
      return;
    }

    try {
      final quote = Quote(
        id: _existingQuote?.id,
        quoteNumber: _quoteNumber,
        clientId: _selectedClient!.id!,
        clientName: _selectedClient!.name,
        status: _status,
        date: _date,
        validUntil: _validUntil,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        subtotal: _subtotal,
        taxRate: _taxRate,
        taxAmount: _taxAmount,
        total: _total,
        items: _items,
        createdAt: _existingQuote?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await ref.read(quotesNotifierProvider.notifier).updateQuote(quote);
      } else {
        await ref.read(quotesNotifierProvider.notifier).addQuote(quote);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.convertToOrder ? 'Convertir a Orden' : (isEditing ? 'Editar Cotización' : 'Nueva Cotización')),
        actions: [
          if (isEditing && !widget.convertToOrder)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Cotización'),
                    content: const Text('¿Está seguro?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && _existingQuote != null) {
                  await ref.read(quotesNotifierProvider.notifier).deleteQuote(_existingQuote!.id!);
                  if (mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: _isLoading && isEditing && _existingQuote == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cotización: $_quoteNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  ListTile(
                                    title: Text(_selectedClient?.name ?? 'Seleccionar Cliente'),
                                    subtitle: Text(_selectedClient?.phone ?? 'Toca para seleccionar'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: _selectClient,
                                    tileColor: Colors.grey[100],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Fecha'),
                                            TextButton(
                                              onPressed: () async {
                                                final date = await showDatePicker(
                                                  context: context,
                                                  initialDate: _date,
                                                  firstDate: DateTime(2020),
                                                  lastDate: DateTime(2030),
                                                );
                                                if (date != null) setState(() => _date = date);
                                              },
                                              child: Text('${_date.day}/${_date.month}/${_date.year}'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Válido hasta'),
                                            TextButton(
                                              onPressed: () async {
                                                final date = await showDatePicker(
                                                  context: context,
                                                  initialDate: _validUntil,
                                                  firstDate: _date,
                                                  lastDate: DateTime(2030),
                                                );
                                                if (date != null) setState(() => _validUntil = date);
                                              },
                                              child: Text('${_validUntil.day}/${_validUntil.month}/${_validUntil.year}'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isEditing && !widget.convertToOrder) ...[
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _status,
                                      decoration: const InputDecoration(labelText: 'Estado'),
                                      items: AppConstants.quoteStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                      onChanged: (value) => setState(() => _status = value!),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Ítems', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ..._items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      initialValue: item.description,
                                      decoration: const InputDecoration(labelText: 'Descripción'),
                                      onChanged: (value) => _updateItem(index, item.copyWith(description: value)),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: item.quantity.toString(),
                                            decoration: const InputDecoration(labelText: 'Cantidad'),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) => _updateItem(index, item.copyWith(quantity: int.tryParse(value) ?? 1)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: item.unitPrice.toString(),
                                            decoration: const InputDecoration(labelText: 'Precio Unit.'),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) => _updateItem(index, item.copyWith(unitPrice: double.tryParse(value) ?? 0)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text('Total: \$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _removeItem(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Ítem'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(labelText: 'Notas adicionales', border: OutlineInputBorder()),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, -2))],
                    ),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal:'), Text('\$${_subtotal.toStringAsFixed(2)}')]),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Impuesto (${_taxRate}%):'), Text('\$${_taxAmount.toStringAsFixed(2)}')]),
                        const Divider(),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveQuote,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: _isLoading ? const CircularProgressIndicator() : Text(widget.convertToOrder ? 'Crear Orden de Trabajo' : 'Guardar Cotización'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
