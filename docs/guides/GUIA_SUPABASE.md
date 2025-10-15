# Guía de Uso de Supabase para MEYPARK

## 📋 Índice

1. [Introducción](#introducción)
2. [Acceso al Dashboard](#acceso-al-dashboard)
3. [Gestión de Empresas](#gestión-de-empresas)
4. [Gestión de Zonas y Tarifas](#gestión-de-zonas-y-tarifas)
5. [Gestión de Operadores](#gestión-de-operadores)
6. [Personalización de Textos](#personalización-de-textos)
7. [Configuración de Elementos UI](#configuración-de-elementos-ui)
8. [Configuración de Pagos](#configuración-de-pagos)
9. [Configuración de Accesibilidad](#configuración-de-accesibilidad)
10. [Monitoreo en Tiempo Real](#monitoreo-en-tiempo-real)
11. [Troubleshooting](#troubleshooting)

---

## 🎯 Introducción

Esta guía te enseñará cómo usar Supabase para gestionar **TODA** la configuración de MEYPARK sin tocar código. Con Supabase puedes:

- ✅ Cambiar tarifas y ver el cambio en la app en tiempo real
- ✅ Personalizar textos por empresa
- ✅ Habilitar/deshabilitar botones
- ✅ Añadir nuevas empresas
- ✅ Configurar colores y branding
- ✅ Monitorear kioscos en tiempo real

---

## 🔗 Acceso al Dashboard

### 1. Acceder a Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Inicia sesión con tu cuenta
3. Selecciona el proyecto **MEYPARK**
4. URL del proyecto: `https://thfmuoqcrkhxduxuygro.supabase.co`

### 2. Navegación Principal

- **Table Editor**: Ver y editar datos
- **SQL Editor**: Ejecutar consultas SQL
- **Authentication**: Gestionar usuarios
- **Storage**: Archivos y logos
- **Realtime**: Monitoreo en tiempo real

---

## 🏢 Gestión de Empresas

### Ver Empresas Existentes

1. Ve a **Table Editor** → **companies**
2. Verás las empresas: MOWIZ y EYPSA

### Crear Nueva Empresa

1. En la tabla **companies**, haz clic en **Insert** → **Insert row**
2. Completa los campos:

```sql
name: "Nueva Empresa"
primary_color: "#FF5722"
background_color: "#FFFFFF"
contact_email: "info@nuevaempresa.com"
contact_phone: "+34 900 000 000"
address: "Ciudad, País"
is_active: true
```

3. Haz clic en **Save**
4. **¡El cambio se verá en la app inmediatamente!**

### Editar Empresa Existente

1. Haz clic en la fila de la empresa
2. Modifica los campos que necesites
3. Haz clic en **Save**
4. **Los cambios se aplican en tiempo real**

---

## 🅿️ Gestión de Zonas y Tarifas

### Ver Zonas Existentes

1. Ve a **Table Editor** → **zones**
2. Verás todas las zonas con sus tarifas

### Cambiar una Tarifa

1. Encuentra la zona que quieres modificar
2. Cambia el campo `price_per_hour` (ej: de 1.2 a 1.5)
3. Haz clic en **Save**
4. **¡La nueva tarifa se aplica en la app en segundos!**

### Crear Nueva Zona

1. En la tabla **zones**, haz clic en **Insert** → **Insert row**
2. Completa los campos:

```sql
company_id: "mowiz-company" (o la empresa que corresponda)
name: "Zona C - Madrid Sur"
color: "#4CAF50"
price_per_hour: 0.6
max_duration: 120
description: "Zona de estacionamiento en el sur de Madrid"
time_options: [15, 30, 60, 120]
time_increment: 15
min_time: 15
is_active: true
```

3. Haz clic en **Save**
4. **La nueva zona aparece en la app automáticamente**

### Configurar Opciones de Tiempo

El campo `time_options` es un array JSON que define las opciones de tiempo disponibles:

```json
[15, 30, 60, 120, 180, 240]
```

- 15 = 15 minutos
- 30 = 30 minutos
- 60 = 1 hora
- 120 = 2 horas
- 180 = 3 horas
- 240 = 4 horas

---

## 👥 Gestión de Operadores

### Ver Operadores

1. Ve a **Table Editor** → **operators**
2. Verás todos los operadores con sus roles

### Crear Nuevo Operador

1. En la tabla **operators**, haz clic en **Insert** → **Insert row**
2. Completa los campos:

```sql
company_id: "mowiz-company"
name: "Juan Pérez"
username: "juan_perez"
password_hash: "$2b$10$..." (generar con bcrypt)
role: "operator"
permissions: ["zones", "sessions"]
is_active: true
```

### Cambiar Contraseña

1. Encuentra el operador
2. Cambia el campo `password_hash`
3. **Importante**: Usar bcrypt para hashear la contraseña

### Roles Disponibles

- `superadmin`: Acceso total
- `admin`: Administrador de empresa
- `operator`: Operador básico
- `viewer`: Solo lectura

---

## 📝 Personalización de Textos

### Ver Textos Existentes

1. Ve a **Table Editor** → **ui_texts**
2. Verás todos los textos organizados por empresa y pantalla

### Cambiar Texto de un Botón

1. Filtra por empresa: `company_id = "mowiz-company"`
2. Filtra por pantalla: `screen = "login"`
3. Encuentra el elemento: `element = "button_login"`
4. Cambia `text_value` (ej: de "Entrar" a "Acceder")
5. Haz clic en **Save**
6. **¡El texto del botón cambia en la app inmediatamente!**

### Añadir Nuevo Texto

1. En la tabla **ui_texts**, haz clic en **Insert** → **Insert row**
2. Completa los campos:

```sql
company_id: "mowiz-company"
screen: "payment"
element: "button_new_payment"
language: "es-ES"
text_value: "Nuevo Pago"
is_enabled: true
```

### Textos por Empresa

Cada empresa puede tener sus propios textos:

- **MOWIZ**: "Entrar", "Coche", "Moto"
- **EYPSA**: "Acceder", "Automóvil", "Motocicleta"

### Soporte Multiidioma

Para añadir inglés:

```sql
company_id: "mowiz-company"
screen: "login"
element: "button_login"
language: "en-US"
text_value: "Login"
is_enabled: true
```

---

## 🎛️ Configuración de Elementos UI

### Habilitar/Deshabilitar Botones

1. Ve a **Table Editor** → **ui_elements_config**
2. Encuentra el elemento que quieres modificar
3. Cambia `is_enabled`:
   - `true` = Botón visible y funcional
   - `false` = Botón oculto

### Ejemplo: Deshabilitar Pago con Tarjeta

1. Filtra por empresa y pantalla
2. Encuentra `element_key = "button_card"`
3. Cambia `is_enabled` a `false`
4. **¡El botón de tarjeta desaparece de la app!**

### Reordenar Elementos

Usa el campo `display_order` para cambiar el orden:

```sql
display_order: 1  -- Primero
display_order: 2  -- Segundo
display_order: 3  -- Tercero
```

---

## 💳 Configuración de Pagos

### Ver Configuración Actual

1. Ve a **Table Editor** → **payment_config**
2. Verás la configuración por empresa

### Cambiar Monedas Aceptadas

1. Encuentra la empresa
2. Modifica `accepted_coins`:

```json
[0.05, 0.10, 0.20, 0.50, 1.00, 2.00, 5.00]
```

3. **¡Las nuevas monedas se aceptan inmediatamente!**

### Cambiar Tarjetas Aceptadas

Modifica `accepted_cards`:

```json
["Visa", "Mastercard", "American Express", "Diners Club"]
```

### Cambiar Límites

- `max_change_amount`: Cambio máximo (ej: 20.0)
- `min_payment_amount`: Pago mínimo (ej: 0.25)

---

## ♿ Configuración de Accesibilidad

### Ver Configuración Actual

1. Ve a **Table Editor** → **accessibility_config**
2. Verás la configuración por empresa

### Activar Modo Oscuro

1. Cambia `dark_mode` a `true`
2. **¡La app cambia a modo oscuro inmediatamente!**

### Configurar Guía por Voz

```sql
voice_guide: true
voice_speed: 0.6
voice_pitch: 1.1
voice_volume: 0.9
```

### Configurar Tamaño de Fuente

```sql
font_size: "large"  -- small, normal, large
```

### Activar IA Adaptativa

```sql
adaptive_ai: true
simplified_mode: true
```

---

## 📊 Monitoreo en Tiempo Real

### Ver Kioscos Activos

1. Ve a **Table Editor** → **kiosks**
2. Verás el estado de todos los kioscos:
   - `status`: online, offline, error, maintenance
   - `current_screen`: pantalla actual
   - `today_income`: ingresos del día

### Ver Sesiones Activas

1. Ve a **Table Editor** → **active_sessions`
2. Verás todas las sesiones de estacionamiento activas

### Monitoreo con Realtime

1. Ve a **Realtime** en el dashboard
2. Selecciona las tablas que quieres monitorear
3. **Verás los cambios en tiempo real**

---

## 🔧 Troubleshooting

### La App No Se Actualiza

1. **Verificar conexión**: Comprueba que la app esté conectada a Supabase
2. **Limpiar caché**: Reinicia la app
3. **Verificar RLS**: Asegúrate de que las políticas RLS permitan el acceso

### Error de Permisos

1. Ve a **Authentication** → **Policies**
2. Verifica que las políticas RLS estén configuradas correctamente
3. Para desarrollo, puedes usar políticas temporales:

```sql
CREATE POLICY "Enable all operations for all users" ON companies FOR ALL USING (true);
```

### Datos No Aparecen

1. **Verificar filtros**: Asegúrate de que `is_active = true`
2. **Verificar relaciones**: Comprueba que los `company_id` coincidan
3. **Verificar caché**: Los cambios pueden tardar unos segundos

### Textos No Se Actualizan

1. **Verificar idioma**: Asegúrate de que el idioma coincida
2. **Verificar empresa**: Comprueba que el `company_id` sea correcto
3. **Limpiar caché de traducciones**: Reinicia la app

---

## 📚 Ejemplos Prácticos

### Ejemplo 1: Cambiar Tarifa de Zona A

1. Ve a **Table Editor** → **zones**
2. Filtra por `name = "Zona A - Madrid Centro"`
3. Cambia `price_per_hour` de `1.2` a `1.5`
4. Haz clic en **Save**
5. **Resultado**: La tarifa cambia en la app en 2-3 segundos

### Ejemplo 2: Personalizar Textos de EYPSA

1. Ve a **Table Editor** → **ui_texts**
2. Filtra por `company_id = "eypsa-company"`
3. Cambia `text_value` de "Entrar" a "Acceder"
4. **Resultado**: EYPSA ve "Acceder" en lugar de "Entrar"

### Ejemplo 3: Deshabilitar Pago con Tarjeta

1. Ve a **Table Editor** → **ui_elements_config`
2. Filtra por `element_key = "button_card"`
3. Cambia `is_enabled` a `false`
4. **Resultado**: El botón de tarjeta desaparece de la app

### Ejemplo 4: Añadir Nueva Empresa

1. **Crear empresa**:
   ```sql
   INSERT INTO companies (name, primary_color, contact_email) 
   VALUES ('Nueva Empresa', '#FF5722', 'info@nueva.com');
   ```

2. **Crear operador**:
   ```sql
   INSERT INTO operators (company_id, name, username, password_hash, role)
   VALUES ('nueva-empresa-id', 'Admin', 'admin', '$2b$10$...', 'admin');
   ```

3. **Crear zona**:
   ```sql
   INSERT INTO zones (company_id, name, price_per_hour)
   VALUES ('nueva-empresa-id', 'Zona Principal', 1.0);
   ```

4. **Resultado**: La nueva empresa aparece en la app con su configuración

---

## 🚀 Próximos Pasos

1. **Explora el Dashboard**: Familiarízate con la interfaz
2. **Haz Cambios de Prueba**: Modifica tarifas y textos
3. **Monitorea en Tiempo Real**: Observa cómo se sincronizan los cambios
4. **Personaliza por Empresa**: Crea configuraciones únicas
5. **Configura Accesibilidad**: Prueba diferentes opciones

---

## 📞 Soporte

Si tienes problemas:

1. **Revisa esta guía** primero
2. **Verifica la consola** de la app para errores
3. **Comprueba el dashboard** de Supabase
4. **Revisa los logs** en tiempo real

---

## 🎉 ¡Felicidades!

Ahora puedes gestionar **TODA** la configuración de MEYPARK desde Supabase sin tocar código. Los cambios se aplican en tiempo real y cada empresa puede tener su configuración personalizada.

**¡El Centro de Control está funcionando!** 🎯
