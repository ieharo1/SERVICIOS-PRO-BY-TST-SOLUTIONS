import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/work_order.dart';
import '../../../domain/entities/client.dart';
import '../../providers/work_order_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/quote_provider.dart';

class WorkOrderFormScreen extends ConsumerStatefulWidget {
  final int? workOrderId;

  const WorkOrderFormScreen({super.key, this.workOrderId});

  @override
  ConsumerState<WorkOrderFormScreen> createState() => _WorkOrderFormScreenState();
}

class _WorkOrderFormScreenState extends ConsumerState<WorkOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observationsController = TextEditingController();
  
  Client? _selectedClient;
  DateTime _date = DateTime.now();
  String _status = 'Pendiente';
  String _quoteNumber = '';
  int? _quoteId;
  double _total = 0.0;
  
  bool _isLoading = false;
  WorkOrder? _existingOrder;
  String _orderNumber = '';

  bool get isEditing => widget.workOrderId != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (isEditing) {
      await _loadOrder();
    } else {
      _orderNumber = await ref.read(workOrdersNotifierProvider.notifier).getNextOrderNumber();
    }
    setState(() {});
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final repository = ref.read(workOrderRepositoryProvider);
    final order = await repository.getWorkOrderById(widget.workOrderId!);
    if (order != null) {
      _existingOrder = order;
      _orderNumber = order.orderNumber;
      _selectedClient = await ref.read(clientRepositoryProvider).getClientById(order.clientId);
      _date = order.date;
      _status = order.status;
      _quoteNumber = order.quoteNumber;
      _quoteId = order.quoteId;
      _total = order.total;
      _observationsController.text = order.observations ?? '';
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
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

  Future<void> _selectQuote() async {
    final quotes = await ref.read(quoteRepositoryProvider).getAllQuotes();
    if (!mounted) return;
    
    final selected = await showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final quote = quotes[index];
          return ListTile(
            title: Text(quote.quoteNumber),
            subtitle: Text('${quote.clientName} - \$${quote.total.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.pop(context, quote);
            },
          );
        },
      ),
    );
    
    if (selected != null) {
      setState(() {
        _quoteNumber = selected.quoteNumber;
        _quoteId = selected.id;
        _total = selected.total;
      });
    }
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null || _selectedClient!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un cliente')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final order = WorkOrder(
        id: _existingOrder?.id,
        orderNumber: _orderNumber,
        quoteId: _quoteId,
        quoteNumber: _quoteNumber.isEmpty ? 'N/A' : _quoteNumber,
        clientId: _selectedClient!.id!,
        clientName: _selectedClient!.name,
        status: _status,
        date: _date,
        observations: _observationsController.text.trim().isEmpty ? null : _observationsController.text.trim(),
        total: _total,
        createdAt: _existingOrder?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await ref.read(workOrdersNotifierProvider.notifier).updateWorkOrder(order);
      } else {
        await ref.read(workOrdersNotifierProvider.notifier).addWorkOrder(order);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Orden' : 'Nueva Orden'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Orden'),
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
                if (confirm == true && _existingOrder != null) {
                  await ref.read(workOrdersNotifierProvider.notifier).deleteWorkOrder(_existingOrder!.id!);
                  if (mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: _isLoading && isEditing && _existingOrder == null
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
                                  Text('Orden: $_orderNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                  ListTile(
                                    title: Text(_quoteNumber.isEmpty ? 'Seleccionar Cotización (opcional)' : _quoteNumber),
                                    subtitle: Text(_quoteNumber.isEmpty ? 'Toca para seleccionar' : '\$${_total.toStringAsFixed(2)}'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: _selectQuote,
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
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _status,
                                    decoration: const InputDecoration(labelText: 'Estado'),
                                    items: AppConstants.orderStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (value) => setState(() => _status = value!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _observationsController,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
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
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveOrder,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: _isLoading ? const CircularProgressIndicator() : Text(isEditing ? 'Actualizar Orden' : 'Crear Orden'),
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
