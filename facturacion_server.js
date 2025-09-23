const express = require('express');
const cors = require('cors');
const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3002;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('web'));

// Almacenamiento en memoria de transacciones
const transactions = new Map();

// Zonas de estacionamiento
const zones = {
  'mz_a': { name: 'Zona A - Madrid Centro', pricePerHour: 1.2 },
  'mz_b': { name: 'Zona B - Madrid Norte', pricePerHour: 0.8 },
  'ey_a': { name: 'Zona A - Barcelona Eixample', pricePerHour: 1.5 },
  'ey_b': { name: 'Zona B - Barcelona Centro', pricePerHour: 2.0 }
};

// Función para generar PDF de factura electrónica ultra-moderna y elegante
function generateInvoicePDF(transaction, invoiceRequest) {
  const doc = new PDFDocument({ 
    size: 'A4',
    margins: { top: 0, bottom: 0, left: 0, right: 0 }
  });
  
  const filename = `factura_${transaction.id}.pdf`;
  const filepath = path.join(__dirname, 'invoices', filename);
  
  // Crear directorio si no existe
  if (!fs.existsSync(path.join(__dirname, 'invoices'))) {
    fs.mkdirSync(path.join(__dirname, 'invoices'));
  }
  
  const stream = fs.createWriteStream(filepath);
  doc.pipe(stream);
  
  // Paleta de colores moderna
  const primaryColor = '#1e40af';      // Azul profundo
  const secondaryColor = '#3b82f6';    // Azul medio
  const accentColor = '#06b6d4';       // Cian
  const successColor = '#10b981';      // Verde
  const textDark = '#1f2937';          // Gris muy oscuro
  const textMedium = '#6b7280';        // Gris medio
  const textLight = '#9ca3af';         // Gris claro
  const bgLight = '#f8fafc';           // Fondo claro
  const bgWhite = '#ffffff';           // Blanco
  const borderColor = '#e5e7eb';       // Borde gris
  
  // Calcular datos fiscales detallados
  const subtotal = transaction.amount / 1.21;
  const iva = transaction.amount - subtotal;
  const ivaRate = 21;
  const pricePerHour = subtotal / (transaction.minutes / 60);
  
  // === ENCABEZADO PRINCIPAL ===
  // Fondo degradado simulado (con margen de impresión)
  doc.rect(20, 20, 555, 100).fill(primaryColor);
  
  // Logo/Icono simulado (con margen de impresión)
  doc.circle(100, 60, 25).fill(accentColor);
  doc.fillColor('white')
    .fontSize(16).font('Helvetica-Bold')
    .text('M', 92, 52);
  
  // Título principal con mejor espaciado y tamaño reducido (con margen)
  doc.fillColor('white')
    .fontSize(24).font('Helvetica-Bold')
    .text('FACTURA ELECTRÓNICA', 140, 45);
  
  // Subtítulo con mejor espaciado (con margen)
  doc.fontSize(12).font('Helvetica')
    .text('Sistema de Parquímetros Inteligente', 140, 75)
    .text('MEYPARK - Gestión de Estacionamiento', 140, 90);
  
  // Badge de estado (reposicionado para no interferir)
  doc.rect(450, 30, 80, 20).fill(successColor);
  doc.fillColor('white')
    .fontSize(9).font('Helvetica-Bold')
    .text('PAGADA', 465, 42);
  
  // Información de la factura en el lado derecho (subida para estar en área azul)
  doc.fillColor('white')
    .fontSize(11).font('Helvetica-Bold')
    .text('Nº Factura', 450, 65)
    .fontSize(8).font('Helvetica')
    .text(transaction.id, 450, 78)
    .fontSize(11).font('Helvetica-Bold')
    .text('Fecha Emisión', 450, 90)
    .fontSize(10).font('Helvetica')
    .text(new Date(transaction.timestamp).toLocaleDateString('es-ES'), 450, 103);
  
  // === DATOS DEL EMISOR Y RECEPTOR ===
  const sectionTop = 160; // Ajustado para margen de impresión
  
  // Emisor (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('EMISOR', 30, sectionTop);
  
  // Caja del emisor (con margen de impresión)
  doc.rect(30, sectionTop + 15, 250, 80).fill(bgWhite).stroke(borderColor);
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text('MEYPARK S.L.', 40, sectionTop + 25);
  
  doc.fillColor(textMedium)
    .fontSize(10).font('Helvetica')
    .text('CIF: B12345678', 40, sectionTop + 40)
    .text('Calle de la Innovación, 123', 40, sectionTop + 55)
    .text('28001 Madrid, España', 40, sectionTop + 70)
    .text('Tel: +34 900 123 456', 40, sectionTop + 85);
  
  // Receptor (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('RECEPTOR', 300, sectionTop);
  
  // Caja del receptor (con margen de impresión)
  doc.rect(300, sectionTop + 15, 225, 80).fill(bgWhite).stroke(borderColor);
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text(invoiceRequest.companyName, 310, sectionTop + 25);
  
  doc.fillColor(textMedium)
    .fontSize(10).font('Helvetica')
    .text(`NIF/CIF: ${invoiceRequest.nif}`, 310, sectionTop + 40)
    .text(invoiceRequest.address, 310, sectionTop + 55)
    .text(`${invoiceRequest.postalCode} ${invoiceRequest.city}`, 310, sectionTop + 70)
    .text(`Email: ${invoiceRequest.email}`, 310, sectionTop + 85);
  
  // === DETALLES DE LA TRANSACCIÓN ===
  const detailsTop = sectionTop + 110;
  
  // Título de la sección (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(16).font('Helvetica-Bold')
    .text('DETALLES DE LA TRANSACCIÓN', 30, detailsTop);
  
  // Tabla de detalles con diseño moderno (con margen de impresión)
  const tableTop = detailsTop + 25;
  const rowHeight = 25;
  
  // Encabezados de tabla con fondo degradado (con margen de impresión)
  doc.rect(30, tableTop, 535, rowHeight).fill(primaryColor);
  doc.fillColor('white')
    .fontSize(11).font('Helvetica-Bold')
    .text('CONCEPTO', 40, tableTop + 8)
    .text('CANT.', 180, tableTop + 8)
    .text('PRECIO UNIT.', 230, tableTop + 8)
    .text('SUBTOTAL', 330, tableTop + 8)
    .text('IVA 21%', 400, tableTop + 8)
    .text('TOTAL', 460, tableTop + 8);
  
  // Fila de datos con concepto en dos líneas (con margen de impresión)
  doc.rect(30, tableTop + rowHeight, 535, rowHeight).fill(bgWhite).stroke(borderColor);
  doc.fillColor(textDark)
    .fontSize(10).font('Helvetica')
    .text('Estacionamiento', 40, tableTop + rowHeight + 8)
    .text(`Matrícula ${transaction.plate}`, 40, tableTop + rowHeight + 20)
    .text('1', 180, tableTop + rowHeight + 14)
    .text(`${subtotal.toFixed(2)} €`, 230, tableTop + rowHeight + 14)
    .text(`${subtotal.toFixed(2)} €`, 330, tableTop + rowHeight + 14)
    .text(`${iva.toFixed(2)} €`, 400, tableTop + rowHeight + 14)
    .text(`${transaction.amount.toFixed(2)} €`, 460, tableTop + rowHeight + 14);
  
  // === DESGLOSE FISCAL DETALLADO ===
  const breakdownTop = tableTop + (rowHeight * 2) + 30;
  
  // Título del desglose (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('DESGLOSE FISCAL', 30, breakdownTop);
  
  // Caja del desglose (con margen de impresión)
  const breakdownBoxHeight = 100;
  doc.rect(30, breakdownTop + 15, 300, breakdownBoxHeight).fill(bgLight).stroke(borderColor);
  
  // Líneas del desglose
  let currentY = breakdownTop + 25;
  const lineHeight = 15;
  
  // Precio base (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(10).font('Helvetica')
    .text('Precio base (sin IVA):', 40, currentY)
    .text(`${subtotal.toFixed(2)} €`, 180, currentY);
  currentY += lineHeight;
  
  // IVA detallado
  doc.text(`IVA (${ivaRate}%):`, 40, currentY)
    .text(`${iva.toFixed(2)} €`, 180, currentY);
  currentY += lineHeight;
  
  // Línea separadora
  doc.moveTo(40, currentY + 5).lineTo(220, currentY + 5).stroke(borderColor);
  currentY += 10;
  
  // Total
  doc.fontSize(12).font('Helvetica-Bold')
    .text('TOTAL A PAGAR:', 40, currentY)
    .text(`${transaction.amount.toFixed(2)} €`, 180, currentY);
  
  // === INFORMACIÓN ADICIONAL ===
  const infoTop = breakdownTop + 15;
  doc.rect(350, infoTop, 195, breakdownBoxHeight).fill(bgWhite).stroke(borderColor);
  
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text('INFORMACIÓN', 360, infoTop + 10);
  
  doc.fillColor(textMedium)
    .fontSize(9).font('Helvetica')
    .text(`Zona: ${zones[transaction.zoneId]?.name || transaction.zoneId}`, 360, infoTop + 25)
    .text(`Duración: ${transaction.minutes} min`, 360, infoTop + 40)
    .text(`Precio/hora: ${pricePerHour.toFixed(2)} €`, 360, infoTop + 55)
    .text(`Método: ${getPaymentMethodName(transaction.paymentMethod)}`, 360, infoTop + 70)
    .text(`Kiosco: ${transaction.kioscoId}`, 360, infoTop + 85);
  
  // === FIRMA ELECTRÓNICA SIMULADA ===
  const signatureTop = breakdownTop + breakdownBoxHeight + 30;
  
  // Título de la firma (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('FIRMA ELECTRÓNICA', 30, signatureTop);
  
  // Caja de la firma (con margen de impresión)
  doc.rect(30, signatureTop + 15, 250, 80).fill(bgWhite).stroke(borderColor);
  
  // Simulación de firma manuscrita (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text('Firma Digital', 40, signatureTop + 25);
  
  // Línea de firma simulada (con margen de impresión)
  doc.moveTo(40, signatureTop + 40).lineTo(260, signatureTop + 40).stroke(textDark, 2);
  
  // Información del certificado (con margen de impresión)
  doc.fillColor(textMedium)
    .fontSize(8).font('Helvetica')
    .text('Certificado: CN=MEYPARK S.L.', 40, signatureTop + 50)
    .text('Válido hasta: 31/12/2025', 40, signatureTop + 65)
    .text('Algoritmo: SHA-256', 40, signatureTop + 80);
  
  // === CÓDIGO QR DE VERIFICACIÓN (EXACTO DE LA APP) ===
  doc.rect(300, signatureTop + 15, 100, 80).fill(bgLight).stroke(borderColor);
  
  // Título del QR (igual que la app)
  doc.fillColor(textDark)
    .fontSize(10).font('Helvetica-Bold')
    .text('QR Facturación', 320, signatureTop + 25);
  
  // Generar el MISMO QR que la app (URL exacta)
  const qrUrl = `http://localhost:3002/facturacion.html?transactionId=${transaction.id}`;
  
  // Patrón QR que simule exactamente el de la app (con margen de impresión)
  const qrSize = 40;
  const qrStartX = 330;
  const qrStartY = signatureTop + 35;
  const cellSize = 2.5;
  
  // Crear patrón QR que simule el enlace exacto de la app
  for (let i = 0; i < 16; i++) {
    for (let j = 0; j < 16; j++) {
      // Patrón más realista con esquinas características del QR
      let shouldFill = false;
      
      // Esquinas del QR (marcadores de posición)
      if ((i < 3 && j < 3) || (i < 3 && j > 12) || (i > 12 && j < 3)) {
        shouldFill = (i + j) % 2 === 0;
      }
      // Patrón central más complejo
      else if (i > 3 && i < 12 && j > 3 && j < 12) {
        shouldFill = (i * j + i + j) % 3 === 0;
      }
      // Bordes
      else {
        shouldFill = (i + j) % 2 === 0;
      }
      
      if (shouldFill) {
        doc.rect(qrStartX + j * cellSize, qrStartY + i * cellSize, cellSize, cellSize).fill(textDark);
      }
    }
  }
  
  // ID de transacción (igual que la app)
  doc.fillColor(textMedium)
    .fontSize(7).font('Helvetica')
    .text(transaction.id.length > 20 ? `${transaction.id.substring(0, 20)}...` : transaction.id, 310, signatureTop + 90);
  
  // === PIE DE PÁGINA CON MARGEN DE IMPRESIÓN ===
  const footerTop = 650; // Reducido para evitar que se pase a otra página
  
  // Fondo del footer con degradado simulado (con margen de impresión)
  doc.rect(20, footerTop - 20, 555, 80).fill(bgLight);
  
  // Línea decorativa superior
  doc.moveTo(30, footerTop - 15).lineTo(525, footerTop - 15).stroke(primaryColor, 3);
  
  // Título del footer (con margen de impresión)
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text('INFORMACIÓN LEGAL Y TÉCNICA', 30, footerTop);
  
  // Información legal en columnas (con margen de impresión)
  const leftCol = 30;
  const rightCol = 300;
  
  // Columna izquierda - Información legal (SIN SÍMBOLOS RAROS)
  doc.fillColor(textDark)
    .fontSize(9).font('Helvetica-Bold')
    .text('VALIDEZ LEGAL', leftCol, footerTop + 20);
  
  doc.fillColor(textMedium)
    .fontSize(8).font('Helvetica')
    .text('Factura electrónica válida sin firma manuscrita', leftCol, footerTop + 35)
    .text('Cumple Real Decreto 1619/2012', leftCol, footerTop + 48)
    .text('Sistema Verifactu compatible', leftCol, footerTop + 61);
  
  // Columna derecha - Información de contacto (SIN EMOJIS)
  doc.fillColor(textDark)
    .fontSize(9).font('Helvetica-Bold')
    .text('CONTACTO Y SOPORTE', rightCol, footerTop + 20);
  
  doc.fillColor(textMedium)
    .fontSize(8).font('Helvetica')
    .text('Email: facturacion@meypark.com', rightCol, footerTop + 35)
    .text('Tel: +34 900 123 456', rightCol, footerTop + 48)
    .text('Web: www.meypark.es', rightCol, footerTop + 61);
  
  // Línea separadora central (con margen de impresión)
  doc.moveTo(280, footerTop + 20).lineTo(280, footerTop + 70).stroke(borderColor);
  
  // Información de la empresa en la parte inferior (con margen de impresión)
  doc.fillColor(textLight)
    .fontSize(7).font('Helvetica')
    .text('MEYPARK S.L. - CIF: B12345678 - Registro Mercantil de Madrid, Tomo 12345, Folio 67, Hoja M-123456', 30, footerTop + 70, { align: 'center' });
  
  doc.end();
  
  return new Promise((resolve, reject) => {
    stream.on('finish', () => {
      resolve({ filename, filepath });
    });
    stream.on('error', reject);
  });
}

// Función auxiliar para nombres de métodos de pago
function getPaymentMethodName(method) {
  const methods = {
    'cash': 'Efectivo',
    'chip': 'Chip+PIN',
    'contactless': 'Contactless'
  };
  return methods[method] || method.toUpperCase();
}

// Rutas API

// Registrar nueva transacción desde Flutter
app.post('/api/register-transaction', (req, res) => {
  try {
    const { id, plate, zoneId, timestamp, amount, paymentMethod, kioscoId, isExtend, minutes } = req.body;
    
    const transaction = {
      id,
      plate,
      zoneId,
      timestamp,
      amount,
      paymentMethod,
      kioscoId: kioscoId || 'KIOSCO_001',
      isExtend: isExtend || false,
      minutes: minutes || 60
    };
    
    transactions.set(id, transaction);
    console.log(`📝 Transacción registrada desde Flutter: ${id}`);
    
    res.json({
      success: true,
      message: 'Transacción registrada correctamente',
      transaction
    });
  } catch (error) {
    console.error('Error registrando transacción:', error);
    res.json({ 
      success: false, 
      error: 'Error interno del servidor' 
    });
  }
});

// Obtener información de una transacción
app.get('/api/transaction/:id', (req, res) => {
  const transactionId = req.params.id;
  let transaction = transactions.get(transactionId);
  
  // Si no encontramos la transacción en memoria, crear una transacción de prueba
  if (!transaction) {
    transaction = {
      id: transactionId,
      plate: '1234ABC',
      zoneId: 'ZONA_001',
      timestamp: new Date().toISOString(),
      amount: 2.50,
      paymentMethod: 'cash',
      kioscoId: 'KIOSCO_001',
      isExtend: false,
      minutes: 60
    };
    
    // Guardar en memoria para futuras consultas
    transactions.set(transactionId, transaction);
    console.log(`📝 Transacción de prueba creada: ${transactionId}`);
  }
  
  if (!transaction) {
    return res.json({ success: false, error: 'Transacción no encontrada' });
  }
  
  // Verificar que no haya pasado más de 30 días
  const transactionDate = new Date(transaction.timestamp);
  const now = new Date();
  const daysDiff = (now - transactionDate) / (1000 * 60 * 60 * 24);
  
  if (daysDiff > 30) {
    return res.json({ 
      success: false, 
      error: 'La transacción ha expirado (más de 30 días)' 
    });
  }
  
  // Agregar nombre de zona
  transaction.zoneName = zones[transaction.zoneId]?.name || `Zona ${transaction.zoneId}`;
  
  res.json({
    success: true,
    transaction
  });
});

// Generar factura
app.post('/api/generate-invoice', async (req, res) => {
  try {
    const { transactionId, nif, companyName, address, city, postalCode, email, phone } = req.body;
    
    // Validar datos requeridos
    if (!transactionId || !nif || !companyName || !address || !city || !postalCode || !email) {
      return res.json({ 
        success: false, 
        errorMessage: 'Faltan datos requeridos' 
      });
    }
    
    // Obtener transacción
    const transaction = transactions.get(transactionId);
    if (!transaction) {
      return res.json({ 
        success: false, 
        errorMessage: 'Transacción no encontrada' 
      });
    }
    
    // Verificar que no esté ya facturada
    if (transaction.invoiceId) {
      return res.json({ 
        success: false, 
        errorMessage: 'Esta transacción ya ha sido facturada' 
      });
    }
    
    // Generar ID de factura
    const invoiceId = generateId();
    
    // Crear solicitud de factura
    const invoiceRequest = {
      transactionId,
      nif,
      companyName,
      address,
      city,
      postalCode,
      email,
      phone
    };
    
    // Generar PDF
    const { filename, filepath } = await generateInvoicePDF(transaction, invoiceRequest);
    
    // Actualizar transacción con datos de factura
    transaction.invoiceId = invoiceId;
    transaction.invoiceData = invoiceRequest;
    transaction.invoiceDate = new Date().toISOString();
    transaction.invoiceUrl = `/invoices/${filename}`;
    
    console.log(`📄 Factura generada: ${filename}`);
    
    res.json({
      success: true,
      message: 'Factura generada correctamente',
      invoiceId,
      invoiceUrl: `/invoices/${filename}`,
      filename
    });
    
  } catch (error) {
    console.error('Error generando factura:', error);
    res.json({ 
      success: false, 
      errorMessage: 'Error interno del servidor' 
    });
  }
});

// Servir archivos PDF
app.use('/invoices', express.static(path.join(__dirname, 'invoices')));

// Ruta principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'web', 'facturacion.html'));
});

// Función para generar ID único
function generateId() {
  return 'INV_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor de facturación electrónica iniciado en puerto ${PORT}`);
  console.log(`📱 Portal web: http://localhost:${PORT}/facturacion.html`);
  console.log(`📊 Estadísticas: http://localhost:${PORT}/api/stats`);
  console.log(`🧪 Crear transacción de prueba: POST http://localhost:${PORT}/api/create-test-transaction`);
});
