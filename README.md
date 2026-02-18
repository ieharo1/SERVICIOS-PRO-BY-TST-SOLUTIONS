# 🟢 SERVICIOS PRO BY TST SOLUTIONS

**SERVICIOS PRO BY TST SOLUTIONS** es una aplicación móvil profesional desarrollada por **TST Solutions** ("Te Solucionamos Todo") para la gestión de cotizaciones y órdenes de trabajo.

---

## 📱 ¿Qué es SERVICIOS PRO?

**SERVICIOS PRO** es una aplicación móvil de gestión empresarial que permite generar cotizaciones y órdenes de servicio profesionales en PDF. Totalmente offline, sin suscripciones y lista para producción.

> *"Tecnología que funciona. Soluciones que escalan."*

---

## ✨ Características Principales

### 📋 Gestión de Cotizaciones
- Numeración automática
- Ítems dinámicos con cálculo automático
- Estados: Borrador, Enviada, Aprobada, Rechazada
- Notas adicionales y fecha de validez
- Generación de PDF profesional

### 🔧 Órdenes de Trabajo
- Conversión desde cotización
- Estados: Pendiente, En proceso, Finalizada
- Observaciones finales
- Firma del cliente

### 👥 Gestión de Clientes
- CRUD completo de clientes
- Historial de documentos
- Búsqueda rápida

### 📊 Dashboard y Reportes
- Total cotizaciones del mes
- Total órdenes completadas
- Ingresos estimados
- Gráficos por estado
- Filtros por fecha

### ⚙️ Perfil del Negocio
- Nombre empresa, logo, teléfono, email
- Dirección, RUC
- Moneda configurable
- Impuesto configurable

---

## 🏗️ Estructura Técnica del Proyecto

```
lib/
├── main.dart                         # Punto de entrada
├── config/
│   └── routes/
│       └── app_router.dart          # Navegación GoRouter
├── core/
│   ├── constants/
│   │   └── app_constants.dart       # Constantes de la app
│   ├── theme/
│   │   └── app_theme.dart           # Temas Material 3
│   └── utils/
│       └── pdf_service.dart         # Generador PDF
├── data/
│   ├── datasources/
│   │   └── database_helper.dart     # Base de datos SQLite
│   └── repositories/                # Repositorios de datos
├── domain/
│   └── entities/                    # Entidades del dominio
└── presentation/
    ├── providers/                   # Riverpod providers
    ├── screens/                     # Pantallas
    │   ├── clients/
    │   ├── dashboard/
    │   ├── orders/
    │   ├── profile/
    │   ├── quotes/
    │   ├── reports/
    │   └── settings/
    └── widgets/                     # Widgets reutilizables
```

---

## 🛠️ Tecnologías Utilizadas

- **Framework:** Flutter 3.x (Dart 3.x)
- **Estado:** Riverpod
- **Navegación:** GoRouter
- **Base de Datos:** SQLite (sqflite)
- **PDF:** pdf + printing
- **Gráficos:** fl_chart
- **UI:** Material Design 3

---

## 🎨 Identidad Visual

### Paleta de Colores
- **Primary:** #1E88E5 (Azul)
- **Secondary:** #43A047 (Verde)
- **Accent:** #FFA726 (Naranja)

---

## 🌎 Información de Contacto - TST Solutions

📍 **Quito - Ecuador**

📱 **WhatsApp:** +593 99 796 2747  
💬 **Telegram:** @TST_Ecuador  
📧 **Email:** negocios@tstsolutions.com.ec

🌐 **Web:** https://tst-solutions.netlify.app/  
📘 **Facebook:** https://www.facebook.com/tstsolutionsecuador/  
🐦 **Twitter/X:** https://x.com/SolutionsT95698

---

## 📋 Requisitos del Sistema

- **Android:** 5.0 (API 21) o superior
- **iOS:** 12.0 o superior
- **Espacio:** ~80 MB

---

## 📄 Licencia

© 2026 SERVICIOS PRO BY TST SOLUTIONS - Todos los derechos reservados.

---

## 👨‍💻 Desarrollado por TST SOLUTIONS

*Technology that works. Solutions that scale.*

---

<div align="center">
  <p><strong>TST Solutions</strong> - Te Solucionamos Todo</p>
</div>
