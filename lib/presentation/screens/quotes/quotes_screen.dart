import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/quote_provider.dart';
import '../../providers/business_profile_provider.dart';
import '../../../core/utils/pdf_service.dart';

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(filteredQuotesProvider);
    final searchQuery = ref.watch(quoteSearchQueryProvider);
    final statusFilter = ref.watch(quoteStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/quotes/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar cotizaciones...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              ref.read(quoteSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ref.read(quoteSearchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: statusFilter == null,
                        onSelected: (_) {
                          ref.read(quoteStatusFilterProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 8),
                      ...AppConstants.quoteStatuses.map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: statusFilter == status,
                          onSelected: (_) {
                            ref.read(quoteStatusFilterProvider.notifier).state = status;
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: quotes.when(
              data: (quoteList) {
                if (quoteList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No hay cotizaciones', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/quotes/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Nueva Cotización'),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(quotesNotifierProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: quoteList.length,
                    itemBuilder: (context, index) {
                      final quote = quoteList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(quote.quoteNumber),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(quote.clientName),
                              Text(
                                '\$${quote.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                onPressed: () => _generatePdf(context, ref, quote),
                              ),
                              _StatusChip(status: quote.status),
                            ],
                          ),
                          onTap: () => context.push('/quotes/edit/${quote.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/quotes/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context, WidgetRef ref, quote) async {
    final profileAsync = ref.read(businessProfileNotifierProvider);
    profileAsync.whenData((profile) async {
      if (profile == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configure su perfil de negocio primero')),
          );
        }
        return;
      }
      try {
        await PdfService.shareQuotePdf(business: profile, quote: quote);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al generar PDF: $e')),
          );
        }
      }
    });
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Borrador':
        color = Colors.grey;
        break;
      case 'Enviada':
        color = Colors.blue;
        break;
      case 'Aprobada':
        color = Colors.green;
        break;
      case 'Rechazada':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
