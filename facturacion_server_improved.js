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
  // Fondo degradado simulado
  doc.rect(0, 0, 595, 120).fill(primaryColor);
  
  // Logo/Icono simulado
  doc.circle(80, 40, 25).fill(accentColor);
  doc.fillColor('white')
    .fontSize(16).font('Helvetica-Bold')
    .text('M', 72, 32);
  
  // Título principal
  doc.fillColor('white')
    .fontSize(28).font('Helvetica-Bold')
    .text('FACTURA ELECTRÓNICA', 120, 25);
  
  // Subtítulo
  doc.fontSize(12).font('Helvetica')
    .text('Sistema de Parquímetros Inteligente', 120, 50)
    .text('MEYPARK - Gestión de Estacionamiento', 120, 65);
  
  // Badge de estado
  doc.rect(450, 20, 120, 30).fill(successColor);
  doc.fillColor('white')
    .fontSize(10).font('Helvetica-Bold')
    .text('PAGADA', 480, 35);
  
  // Información de la factura en el lado derecho
  doc.fillColor('white')
    .fontSize(11).font('Helvetica-Bold')
    .text('Nº Factura', 450, 60)
    .fontSize(10).font('Helvetica')
    .text(transaction.id, 450, 75)
    .fontSize(11).font('Helvetica-Bold')
    .text('Fecha Emisión', 450, 90)
    .fontSize(10).font('Helvetica')
    .text(new Date(transaction.timestamp).toLocaleDateString('es-ES'), 450, 105);
  
  // === DATOS DEL EMISOR Y RECEPTOR ===
  const sectionTop = 140;
  
  // Emisor
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('EMISOR', 50, sectionTop);
  
  // Caja del emisor
  doc.rect(50, sectionTop + 15, 250, 80).fill(bgWhite).stroke(borderColor);
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text('MEYPARK S.L.', 60, sectionTop + 25);
  
  doc.fillColor(textMedium)
    .fontSize(10).font('Helvetica')
    .text('CIF: B12345678', 60, sectionTop + 40)
    .text('Calle de la Innovación, 123', 60, sectionTop + 55)
    .text('28001 Madrid, España', 60, sectionTop + 70)
    .text('Tel: +34 900 123 456', 60, sectionTop + 85);
  
  // Receptor
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('RECEPTOR', 320, sectionTop);
  
  // Caja del receptor
  doc.rect(320, sectionTop + 15, 225, 80).fill(bgWhite).stroke(borderColor);
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text(invoiceRequest.companyName, 330, sectionTop + 25);
  
  doc.fillColor(textMedium)
    .fontSize(10).font('Helvetica')
    .text(`NIF/CIF: ${invoiceRequest.nif}`, 330, sectionTop + 40)
    .text(invoiceRequest.address, 330, sectionTop + 55)
    .text(`${invoiceRequest.postalCode} ${invoiceRequest.city}`, 330, sectionTop + 70)
    .text(`Email: ${invoiceRequest.email}`, 330, sectionTop + 85);
  
  // === DETALLES DE LA TRANSACCIÓN ===
  const detailsTop = sectionTop + 110;
  
  // Título de la sección
  doc.fillColor(textDark)
    .fontSize(16).font('Helvetica-Bold')
    .text('DETALLES DE LA TRANSACCIÓN', 50, detailsTop);
  
  // Tabla de detalles con diseño moderno
  const tableTop = detailsTop + 25;
  const rowHeight = 25;
  
  // Encabezados de tabla con fondo degradado
  doc.rect(50, tableTop, 495, rowHeight).fill(primaryColor);
  doc.fillColor('white')
    .fontSize(11).font('Helvetica-Bold')
    .text('CONCEPTO', 60, tableTop + 8)
    .text('CANT.', 200, tableTop + 8)
    .text('PRECIO UNIT.', 250, tableTop + 8)
    .text('SUBTOTAL', 350, tableTop + 8)
    .text('IVA 21%', 420, tableTop + 8)
    .text('TOTAL', 480, tableTop + 8);
  
  // Fila de datos
  doc.rect(50, tableTop + rowHeight, 495, rowHeight).fill(bgWhite).stroke(borderColor);
  doc.fillColor(textDark)
    .fontSize(10).font('Helvetica')
    .text(`Estacionamiento - Matrícula ${transaction.plate}`, 60, tableTop + rowHeight + 8)
    .text('1', 200, tableTop + rowHeight + 8)
    .text(`${subtotal.toFixed(2)} €`, 250, tableTop + rowHeight + 8)
    .text(`${subtotal.toFixed(2)} €`, 350, tableTop + rowHeight + 8)
    .text(`${iva.toFixed(2)} €`, 420, tableTop + rowHeight + 8)
    .text(`${transaction.amount.toFixed(2)} €`, 480, tableTop + rowHeight + 8);
  
  // === DESGLOSE FISCAL DETALLADO ===
  const breakdownTop = tableTop + (rowHeight * 2) + 30;
  
  // Título del desglose
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('DESGLOSE FISCAL', 50, breakdownTop);
  
  // Caja del desglose
  const breakdownBoxHeight = 100;
  doc.rect(50, breakdownTop + 15, 300, breakdownBoxHeight).fill(bgLight).stroke(borderColor);
  
  // Líneas del desglose
  let currentY = breakdownTop + 25;
  const lineHeight = 15;
  
  // Precio base
  doc.fillColor(textDark)
    .fontSize(10).font('Helvetica')
    .text('Precio base (sin IVA):', 60, currentY)
    .text(`${subtotal.toFixed(2)} €`, 200, currentY);
  currentY += lineHeight;
  
  // IVA detallado
  doc.text(`IVA (${ivaRate}%):`, 60, currentY)
    .text(`${iva.toFixed(2)} €`, 200, currentY);
  currentY += lineHeight;
  
  // Línea separadora
  doc.moveTo(60, currentY + 5).lineTo(240, currentY + 5).stroke(borderColor);
  currentY += 10;
  
  // Total
  doc.fontSize(12).font('Helvetica-Bold')
    .text('TOTAL A PAGAR:', 60, currentY)
    .text(`${transaction.amount.toFixed(2)} €`, 200, currentY);
  
  // === INFORMACIÓN ADICIONAL ===
  const infoTop = breakdownTop + 15;
  doc.rect(370, infoTop, 175, breakdownBoxHeight).fill(bgWhite).stroke(borderColor);
  
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text('INFORMACIÓN', 380, infoTop + 10);
  
  doc.fillColor(textMedium)
    .fontSize(9).font('Helvetica')
    .text(`Zona: ${zones[transaction.zoneId]?.name || transaction.zoneId}`, 380, infoTop + 25)
    .text(`Duración: ${transaction.minutes} min`, 380, infoTop + 40)
    .text(`Precio/hora: ${pricePerHour.toFixed(2)} €`, 380, infoTop + 55)
    .text(`Método: ${getPaymentMethodName(transaction.paymentMethod)}`, 380, infoTop + 70)
    .text(`Kiosco: ${transaction.kioscoId}`, 380, infoTop + 85);
  
  // === FIRMA ELECTRÓNICA SIMULADA ===
  const signatureTop = breakdownTop + breakdownBoxHeight + 30;
  
  // Título de la firma
  doc.fillColor(textDark)
    .fontSize(14).font('Helvetica-Bold')
    .text('FIRMA ELECTRÓNICA', 50, signatureTop);
  
  // Caja de la firma
  doc.rect(50, signatureTop + 15, 250, 80).fill(bgWhite).stroke(borderColor);
  
  // Simulación de firma manuscrita
  doc.fillColor(textDark)
    .fontSize(12).font('Helvetica-Bold')
    .text('Firma Digital', 60, signatureTop + 25);
  
  // Línea de firma simulada
  doc.moveTo(60, signatureTop + 40).lineTo(280, signatureTop + 40).stroke(textDark, 2);
  
  // Información del certificado
  doc.fillColor(textMedium)
    .fontSize(8).font('Helvetica')
    .text('Certificado: CN=MEYPARK S.L.', 60, signatureTop + 50)
    .text('Válido hasta: 31/12/2025', 60, signatureTop + 65)
    .text('Algoritmo: SHA-256', 60, signatureTop + 80);
  
  // === CÓDIGO QR DE VERIFICACIÓN ===
  doc.rect(320, signatureTop + 15, 100, 80).fill(bgLight).stroke(borderColor);
  
  // Simulación de QR
  doc.fillColor(textDark)
    .fontSize(10).font('Helvetica-Bold')
    .text('CÓDIGO QR', 340, signatureTop + 25);
  
  // Patrón simulado de QR
  const qrSize = 50;
  const qrStartX = 345;
  const qrStartY = signatureTop + 35;
  
  // Crear patrón de cuadros para simular QR
  for (let i = 0; i < 8; i++) {
    for (let j = 0; j < 8; j++) {
      if ((i + j) % 2 === 0) {
        doc.rect(qrStartX + j * 6, qrStartY + i * 6, 5, 5).fill(textDark);
      }
    }
  }
  
  doc.fillColor(textMedium)
    .fontSize(8).font('Helvetica')
    .text('Verificación', 340, signatureTop + 90);
  
  // === PIE DE PÁGINA LEGAL ===
  const footerTop = 750;
  
  // Línea separadora
  doc.moveTo(50, footerTop).lineTo(545, footerTop).stroke(borderColor);
  
  doc.fillColor(textLight)
    .fontSize(8).font('Helvetica')
    .text('Esta factura electrónica ha sido generada automáticamente y es válida sin firma manuscrita.', 50, footerTop + 10)
    .text('De acuerdo con el Real Decreto 1619/2012, de 30 de noviembre, sobre facturación electrónica.', 50, footerTop + 25)
    .text('Sistema Verifactu compatible | Para consultas: facturacion@meypark.com | Tel: +34 900 123 456', 50, footerTop + 40)
    .text('MEYPARK S.L. - CIF: B12345678 - Registro Mercantil de Madrid, Tomo 12345, Folio 67, Hoja M-123456', 50, footerTop + 55);
  
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
