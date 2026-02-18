import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
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
        title: const Row(
          children: [
            Icon(Icons.contact_mail, color: Color(0xFF1E88E5)),
            SizedBox(width: 8),
            Text('Contacto - TST Solutions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _ContactItem(icon: Icons.location_on, text: 'Quito - Ecuador'),
              const SizedBox(height: 8),
              _ContactItem(
                icon: Icons.phone,
                text: '+593 99 796 2747',
                onTap: () => _launchUrl('tel:+593997962747'),
              ),
              const SizedBox(height: 8),
              _ContactItem(
                icon: Icons.message,
                text: '@TST_Ecuador',
                onTap: () => _launchUrl('https://t.me/TST_Ecuador'),
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
                text: 'Web',
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

  const _ContactItem({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E88E5)),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: onTap != null ? const Color(0xFF1E88E5) : null,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
