# SERVICIOS PRO BY TST SOLUTIONS

**Aplicación móvil profesional para gestión de cotizaciones y órdenes de trabajo.**

---

## Descripción del Producto

**SERVICIOS PRO BY TST SOLUTIONS** es una aplicación móvil de gestión empresarial desarrollada por **TST Solutions** ("Te Solucionamos Todo") que permite generar cotizaciones y órdenes de servicio profesionales en formato PDF. Totalmente offline, sin suscripciones y lista para producción.

> *"Tecnología que funciona. Soluciones que escalan."*

---

## Público Objetivo

- Pequeñas y medianas empresas
- Prestadores de servicios técnicos
- Empresas de mantenimiento
- Consultores independientes
- Cualquier profesional que necesite gestionar cotizaciones y órdenes de trabajo

---

## Características Principales

### Gestión de Perfil de Negocio
- Nombre de empresa, logo, teléfono, email
- Dirección, RUC
- Firma digital
- Moneda configurable
- Impuesto configurable

### Gestión de Clientes
- CRUD completo de clientes
- Historial de documentos por cliente
- Búsqueda rápida por nombre, identificación o teléfono

### Cotizaciones
- Numeración automática (COT-00001)
- Ítems dinámicos con cálculo automático
- Estados: Borrador, Enviada, Aprobada, Rechazada
- Notas adicionales
- Fecha de validez
- Generación de PDF profesional

### Órdenes de Trabajo
- Conversión desde cotización
- Estados: Pendiente, En proceso, Finalizada
- Observaciones finales
- Firma del cliente
- Generación de PDF profesional

### Dashboard
- Total cotizaciones del mes
- Total órdenes completadas
- Ingresos estimados
- Accesos rápidos

### Reportes
- Filtro por fecha
- Total por cliente
- Total mensual
- Gráficas por estado

### Funcionalidades Adicionales
- Modo oscuro
- Backup y restauración de datos
- Compartir PDF directamente
- Navegación intuitiva

---

## Tecnologías Utilizadas

| Categoría | Tecnología |
|-----------|------------|
| Framework | Flutter 3.x |
| Lenguaje | Dart 3.x |
| Estado | Riverpod 2.6.1 |
| Navegación | GoRouter 14.8.1 |
| Base de Datos | SQLite (sqflite) |
| PDF | pdf 3.11.2 + printing 5.14.2 |
| Gráficos | fl_chart 0.70.2 |
| UI | Material Design 3 |
| Sharing | share_plus |
| URL Launcher | url_launcher |

---

## Arquitectura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── config/
│   └── routes/
│       └── app_router.dart           # Configuración de rutas con GoRouter
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # Constantes globales de la app
│   ├── theme/
│   │   └── app_theme.dart            # Temas Light y Dark Material 3
│   └── utils/
│       ├── pdf_service.dart          # Generador de PDFs profesional
│       └── backup_service.dart       # Servicio de backup/restore
├── data/
│   ├── datasources/
│   │   └── database_helper.dart      # Configuración de SQLite
│   └── repositories/                # Repositorios de datos
│       ├── business_profile_repository.dart
│       ├── client_repository.dart
│       ├── quote_repository.dart
│       ├── work_order_repository.dart
│       └── settings_repository.dart
├── domain/
│   └── entities/                     # Entidades del dominio
│       ├── business_profile.dart
│       ├── client.dart
│       ├── quote.dart
│       ├── quote_item.dart
│       └── work_order.dart
└── presentation/
    ├── providers/                    # Riverpod Providers
    │   ├── business_profile_provider.dart
    │   ├── client_provider.dart
    │   ├── quote_provider.dart
    │   ├── theme_provider.dart
    │   └── work_order_provider.dart
    ├── screens/                      # Pantallas de la app
    │   ├── dashboard/
    │   ├── clients/
    │   ├── quotes/
    │   ├── orders/
    │   ├── profile/
    │   ├── reports/
    │   └── settings/
    └── widgets/                      # Widgets reutilizables
        ├── splash_screen.dart
        └── main_scaffold.dart
```

---

## Instalación del Proyecto

### Requisitos Previos
- Flutter SDK 3.x instalado
- Dart SDK 3.x instalado
- Android SDK configurado (para Android)
- Xcode configurado (para iOS)

### Pasos de Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/ieharo1/SERVICIOS-PRO-BY-TST-SOLUTIONS.git
   ```

2. **Navegar al directorio del proyecto:**
   ```bash
   cd SERVICIOS-PRO-BY-TST-SOLUTIONS
   ```

3. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

4. **Ejecutar en modo desarrollo:**
   ```bash
   flutter run
   ```

---

## Compilación del Proyecto

### Modo Debug
```bash
flutter build apk --debug
```
El APK debug se generará en: `build/app/outputs/flutter-apk/app-debug.apk`

### Modo Release
```bash
flutter build apk --release
```
El APK release se generará en: `build/app/outputs/flutter-apk/app-release.apk`

### Para Producción (Google Play)
```bash
flutter build appbundle --release
```

---

## Configuración para Publicación

### Android
1. Modificar `android/app/build.gradle.kts` con el nombre del paquete correcto
2. Generar keystore para firma
3. Configurar signing en `android/app/build.gradle.kts`
4. Build con: `flutter build apk --release`

### iOS
1. Configurar Bundle Identifier en Xcode
2. Generar certificados de distribución
3. Build con: `flutter build ios --release`

---

## Información del Desarrollador

**TST Solutions - Te Solucionamos Todo**

### Contacto
- 📍 Quito - Ecuador
- 📱 WhatsApp: +593 99 796 2747
- 💬 Telegram: @TST_Ecuador
- 📧 Email: negocios@tstsolutions.com.ec
- 🌐 Web: https://tst-solutions.netlify.app/

### Redes Sociales
- 📘 Facebook: https://www.facebook.com/tstsolutionsecuador/
- 🐦 Twitter/X: https://x.com/SolutionsT95698

---

## Licencia

© 2026 SERVICIOS PRO BY TST SOLUTIONS - Todos los derechos reservados.

---

<div align="center">
  <p><strong>TST Solutions</strong> - Te Solucionamos Todo</p>
  <p>Tecnología que funciona. Soluciones que escalan.</p>
</div>
