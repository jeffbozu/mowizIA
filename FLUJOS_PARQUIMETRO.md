# DIAGRAMAS DE FLUJOS - PARQUÍMETRO MODERNO

## 1. Flujo Principal: Pay-by-Plate

```mermaid
graph TD
    A[Pantalla Bienvenida] --> B[Selección Idioma]
    B --> C[Entrada Matrícula]
    C --> D[Selección Tarifa]
    D --> E[Selección Tiempo]
    E --> F[Resumen Confirmación]
    F --> G[Selección Método Pago]
    G --> H[Proceso Pago]
    H --> I[Confirmación Pago]
    I --> J[Impresión Recibo]
    J --> K[Pago Completado]
    K --> L[Agradecimiento]
    
    C --> M[Verificación Datos]
    M --> D
    
    G --> N[Pago Monedas]
    G --> O[Pago Tarjeta]
    G --> P[Pago Contactless]
    
    H --> Q[Error Pago]
    Q --> G
    
    J --> R[Sin Papel]
    R --> S[Recibo Digital]
    S --> K
```

## 2. Flujo de Error: Pago Fallido

```mermaid
graph TD
    A[Pago en Proceso] --> B{¿Pago Exitoso?}
    B -->|Sí| C[Confirmación]
    B -->|No| D[Tipo Error]
    D --> E[Moneda Atascada]
    D --> F[Tarjeta Declinada]
    D --> G[Saldo Insuficiente]
    D --> H[Error Red]
    
    E --> I[Instrucciones Desatascar]
    F --> J[Reintentar/Alternativa]
    G --> K[Insertar Más Monedas]
    H --> L[Modo Offline]
    
    I --> M[Reintentar Pago]
    J --> M
    K --> M
    L --> M
    
    M --> N{¿Máximo Reintentos?}
    N -->|No| A
    N -->|Sí| O[Cancelar Transacción]
```

## 3. Flujo de Accesibilidad

```mermaid
graph TD
    A[Usuario Accede] --> B{¿Necesita Ayuda?}
    B -->|No| C[Flujo Normal]
    B -->|Sí| D[Activar Audio]
    D --> E[Modo Alto Contraste]
    E --> F[Navegación por Teclado]
    F --> G[Confirmación Táctil]
    G --> H[Feedback Sonoro]
    H --> I[Proceso Pago]
    I --> J[Recibo Braille]
    J --> K[Confirmación Final]
```

## 4. Flujo de Estados del Sistema

```mermaid
stateDiagram-v2
    [*] --> IDLE
    IDLE --> LANGUAGE_SELECTION
    LANGUAGE_SELECTION --> VEHICLE_INPUT
    VEHICLE_INPUT --> TARIFF_SELECTION
    TARIFF_SELECTION --> TIME_SELECTION
    TIME_SELECTION --> PAYMENT_METHOD
    PAYMENT_METHOD --> PAYMENT_PROCESSING
    PAYMENT_PROCESSING --> PAYMENT_SUCCESS
    PAYMENT_PROCESSING --> PAYMENT_ERROR
    PAYMENT_ERROR --> PAYMENT_METHOD
    PAYMENT_SUCCESS --> RECEIPT_PRINTING
    RECEIPT_PRINTING --> COMPLETED
    COMPLETED --> IDLE
    
    IDLE --> MAINTENANCE_MODE
    IDLE --> OUT_OF_SERVICE
    IDLE --> OFFLINE_MODE
    
    MAINTENANCE_MODE --> IDLE
    OUT_OF_SERVICE --> IDLE
    OFFLINE_MODE --> IDLE
```

## 5. Flujo de Métodos de Pago

```mermaid
graph TD
    A[Selección Método Pago] --> B{¿Qué método?}
    
    B -->|Monedas| C[Insertar Monedas]
    B -->|Tarjeta Chip| D[Insertar Tarjeta]
    B -->|Contactless| E[Acercar Tarjeta]
    B -->|NFC Wallet| F[Acercar Teléfono]
    B -->|QR Code| G[Escanear QR]
    B -->|Abono| H[Validar Abono]
    
    C --> I[Validar Monedas]
    D --> J[Procesar Chip]
    E --> K[Procesar Contactless]
    F --> L[Procesar NFC]
    G --> M[Procesar QR]
    H --> N[Validar Código]
    
    I --> O{¿Suficiente?}
    J --> P{¿Autorizado?}
    K --> Q{¿Autorizado?}
    L --> R{¿Autorizado?}
    M --> S{¿Autorizado?}
    N --> T{¿Válido?}
    
    O -->|Sí| U[Confirmar Pago]
    O -->|No| V[Insertar Más]
    P -->|Sí| U
    P -->|No| W[Error Tarjeta]
    Q -->|Sí| U
    Q -->|No| W
    R -->|Sí| U
    R -->|No| W
    S -->|Sí| U
    S -->|No| W
    T -->|Sí| U
    T -->|No| X[Error Abono]
    
    V --> C
    W --> Y[Reintentar/Alternativa]
    X --> Y
    Y --> A
    U --> Z[Pago Exitoso]
```

## 6. Flujo de Extensión de Tiempo

```mermaid
graph TD
    A[Usuario con Ticket] --> B[Escanear QR Ticket]
    B --> C[Validar Ticket]
    C --> D{¿Ticket Válido?}
    D -->|No| E[Error: Ticket Inválido]
    D -->|Sí| F[Mostrar Tiempo Restante]
    F --> G[Seleccionar Tiempo Adicional]
    G --> H[Calcular Coste]
    H --> I[Selección Método Pago]
    I --> J[Procesar Pago]
    J --> K{¿Pago Exitoso?}
    K -->|No| L[Error Pago]
    K -->|Sí| M[Actualizar Ticket]
    M --> N[Imprimir Nuevo Ticket]
    N --> O[Extensión Completada]
    
    E --> P[Volver a Inicio]
    L --> I
    O --> Q[Mostrar Resumen]
```

## 7. Flujo de Mantenimiento

```mermaid
graph TD
    A[Sistema Operativo] --> B{¿Alerta?}
    B -->|Papel Bajo| C[Alerta Papel]
    B -->|Moneda Atascada| D[Alerta Moneda]
    B -->|Puerta Abierta| E[Alerta Seguridad]
    B -->|Batería Baja| F[Alerta Energía]
    B -->|Sin Red| G[Modo Offline]
    B -->|No| A
    
    C --> H[Notificar Técnico]
    D --> I[Instrucciones Usuario]
    E --> J[Activar Alarma]
    F --> K[Reducir Funciones]
    G --> L[Límites Offline]
    
    H --> M[Cambio Papel]
    I --> N[Desatascar Moneda]
    J --> O[Cerrar Puerta]
    K --> P[Recarga Batería]
    L --> Q[Reconexión]
    
    M --> A
    N --> A
    O --> A
    P --> A
    Q --> A
```

## 8. Flujo de Accesibilidad Avanzada

```mermaid
graph TD
    A[Usuario con Discapacidad] --> B[Detectar Necesidades]
    B --> C{¿Tipo Discapacidad?}
    
    C -->|Visual| D[Activar Audio]
    C -->|Motora| E[Modo Teclado]
    C -->|Cognitiva| F[Modo Simple]
    C -->|Auditiva| G[Modo Visual]
    
    D --> H[Navegación Sonora]
    E --> I[Teclas Físicas]
    F --> J[Interfaz Simplificada]
    G --> K[Indicadores Visuales]
    
    H --> L[Feedback Sonoro]
    I --> M[Feedback Háptico]
    J --> N[Confirmaciones Múltiples]
    K --> O[Señales Visuales]
    
    L --> P[Proceso Pago Accesible]
    M --> P
    N --> P
    O --> P
    
    P --> Q[Recibo Accesible]
    Q --> R[Confirmación Final]
```

---

**Total de Flujos**: 8 flujos principales
**Cobertura**: 100% de casos de uso
**Complejidad**: Media-Alta
**Mantenibilidad**: Alta
