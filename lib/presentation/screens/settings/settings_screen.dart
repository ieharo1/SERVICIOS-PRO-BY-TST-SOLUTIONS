import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/backup_service.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Apariencia'),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambiar entre modo claro y oscuro'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setDarkMode(value);
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Acerca de'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de - TST Solutions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Información de Contacto'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showContactDialog(context),
          ),
          const Divider(),
          const _SectionHeader(title: 'App'),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Términos y Condiciones'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Términos y condiciones')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Política de Privacidad'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Política de privacidad')),
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Datos'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Exportar Respaldo'),
            subtitle: const Text('Crear copia de seguridad de la base de datos'),
            onTap: () => _createBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Importar Respaldo'),
            subtitle: const Text('Restaurar desde archivo de respaldo'),
            onTap: () => _showRestoreDialog(context),
          ),
          const Divider(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${AppConstants.appName}\nVersión 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.business, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('TST Solutions'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SERVICIOS PRO BY TST SOLUTIONS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Aplicación profesional para gestión de cotizaciones y órdenes de trabajo.',
              ),
              SizedBox(height: 16),
              Text(
                '© 2024 TST Solutions - Todos los derechos reservados.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.contact_mail, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Información de Contacto - TST Solutions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              const _ContactItem(icon: Icons.location_on, text: 'Quito - Ecuador', isClickable: false),
              const SizedBox(height: 12),
              _ContactItem(
                icon: Icons.phone,
                text: '+593 99 796 2747',
                onTap: () => _launchUrl('tel:+593997962747'),
                isWhatsApp: true,
              ),
              const SizedBox(height: 8),
              _ContactItem(
                icon: Icons.send,
                text: '@TST_Ecuador',
                onTap: () => _launchUrl('https://t.me/TST_Ecuador'),
                isTelegram: true,
              ),
              const SizedBox(height: 8),
              _ContactItem(
                icon: Icons.email,
                text: 'negocios@tstsolutions.com.ec',
                onTap: () => _launchUrl('mailto:negocios@tstsolutions.com.ec'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _ContactItem(
                icon: Icons.language,
                text: 'https://tst-solutions.netlify.app/',
                onTap: () => _launchUrl(AppConstants.tstWeb),
              ),
              const SizedBox(height: 8),
              _ContactItem(
                icon: Icons.facebook,
                text: 'Facebook',
                onTap: () => _launchUrl(AppConstants.tstFacebook),
              ),
              const SizedBox(height: 8),
              _ContactItem(
                icon: Icons.alternate_email,
                text: 'Twitter/X',
                onTap: () => _launchUrl(AppConstants.tstTwitter),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  AppConstants.appName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  '© 2026 TST Solutions - Todos los derechos reservados',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creando respaldo...'),
            ],
          ),
        ),
      );

      final backupPath = await BackupService.exportDatabase();

      if (context.mounted) {
        Navigator.pop(context);
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Respaldo Creado'),
            content: Text('Respaldo guardado en:\n$backupPath'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Share.shareXFiles([XFile(backupPath)], text: 'Respaldo SERVICIOS PRO');
                },
                child: const Text('Compartir'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear respaldo: $e')),
        );
      }
    }
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Respaldo'),
        content: const Text(
          'Para restaurar un respaldo, debe tener el archivo de backup en su dispositivo. '
          '¿Desea continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad de restauración - Use un gestor de archivos para seleccionar el respaldo')),
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool isClickable;
  final bool isWhatsApp;
  final bool isTelegram;

  const _ContactItem({
    required this.icon,
    required this.text,
    this.onTap,
    this.isClickable = true,
    this.isWhatsApp = false,
    this.isTelegram = false,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = const Color(0xFF1E88E5);
    if (isWhatsApp) iconColor = const Color(0xFF25D366);
    if (isTelegram) iconColor = const Color(0xFF0088CC);

    return InkWell(
      onTap: isClickable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isClickable ? const Color(0xFF1E88E5) : null,
                  fontSize: 14,
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
