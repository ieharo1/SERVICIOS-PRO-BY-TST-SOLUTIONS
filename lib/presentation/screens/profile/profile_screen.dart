import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/business_profile.dart';
import '../../providers/business_profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _rucController = TextEditingController();
  final _currencyController = TextEditingController();
  final _taxRateController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profileAsync = ref.read(businessProfileNotifierProvider);
    profileAsync.whenData((profile) {
      if (profile != null) {
        _companyNameController.text = profile.companyName;
        _phoneController.text = profile.phone;
        _emailController.text = profile.email;
        _addressController.text = profile.address;
        _rucController.text = profile.ruc;
        _currencyController.text = profile.currency;
        _taxRateController.text = profile.taxRate.toString();
      } else {
        _currencyController.text = 'USD';
        _taxRateController.text = '12';
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    _currencyController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = BusinessProfile(
        id: null,
        companyName: _companyNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        ruc: _rucController.text.trim(),
        currency: _currencyController.text.trim(),
        taxRate: double.tryParse(_taxRateController.text) ?? 12.0,
      );

      await ref.read(businessProfileNotifierProvider.notifier).saveProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado correctamente')),
        );
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
    final profileAsync = ref.watch(businessProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.store, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Datos del Negocio',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Empresa *',
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _rucController,
                          decoration: const InputDecoration(
                            labelText: 'RUC *',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El RUC es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono *',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El teléfono es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El email es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección *',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La dirección es requerida';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Configuración Fiscal',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _currencyController,
                          decoration: const InputDecoration(
                            labelText: 'Moneda *',
                            prefixIcon: Icon(Icons.monetization_on),
                            hintText: 'Ej: USD, EUR, etc.',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La moneda es requerida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _taxRateController,
                          decoration: const InputDecoration(
                            labelText: 'Porcentaje de Impuesto (%) *',
                            prefixIcon: Icon(Icons.percent),
                            hintText: 'Ej: 12 para 12%',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El impuesto es requerido';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Ingrese un número válido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar Perfil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
