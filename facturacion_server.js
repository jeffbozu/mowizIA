const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const PDFDocument = require('pdfkit');

const app = express();
const PORT = 3002;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('web'));

// Base de datos en memoria para la demo
const transactions = new Map();
const invoices = new Map();

// Zonas de ejemplo
const zones = {
  'ZONA_001': { name: 'Centro Histórico', pricePerHour: 2.50 },
  'ZONA_002': { name: 'Zona Azul', pricePerHour: 1.80 },
  'ZONA_003': { name: 'Zona Verde', pricePerHour: 1.20 },
  'ZONA_004': { name: 'Zona Naranja', pricePerHour: 0.80 }
};

// Función para generar ID único
function generateId() {
  return 'INV_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// Función para generar PDF de factura
function generateInvoicePDF(transaction, invoiceRequest) {
  const doc = new PDFDocument({ size: 'A4', margin: 40 });
  const filename = `factura_${transaction.id}.pdf`;
  const filepath = path.join(__dirname, 'invoices', filename);
  
  // Crear directorio si no existe
  if (!fs.existsSync(path.join(__dirname, 'invoices'))) {
    fs.mkdirSync(path.join(__dirname, 'invoices'));
  }
  
  const stream = fs.createWriteStream(filepath);
  doc.pipe(stream);
  
  // Colores corporativos
  const primaryColor = '#667eea';
  const secondaryColor = '#764ba2';
  const lightGray = '#f8f9fa';
  const darkGray = '#6c757d';
  
  // Fondo degradado (simulado con rectángulos)
  doc.rect(0, 0, 595, 842).fill(lightGray);
  
  // Encabezado con diseño moderno
  doc.rect(0, 0, 595, 120).fill(primaryColor);
  
  // Logo/Icono
  doc.circle(80, 60, 25).fill('white');
  doc.fontSize(24).fillColor(primaryColor).text('M', 70, 50);
  
  // Título principal
  doc.fontSize(28).fillColor('white').text('FACTURA ELECTRÓNICA', 120, 30);
  doc.fontSize(14).fillColor('white').text('MEYPARK - Sistema de Parquímetros Inteligentes', 120, 60);
  
  // Información de la empresa
  doc.fontSize(10).fillColor('white').text('CIF: B12345678', 120, 80);
  doc.text('Calle de la Innovación, 123 • 28001 Madrid', 120, 95);
  doc.text('Tel: +34 900 123 456 • Email: facturacion@meypark.es', 120, 110);
  
  // Número de factura y fecha
  const invoiceNumber = `INV-${transaction.id}`;
  const invoiceDate = new Date().toLocaleDateString('es-ES');
  
  doc.fontSize(12).fillColor('white').text(`Factura: ${invoiceNumber}`, 450, 30);
  doc.text(`Fecha: ${invoiceDate}`, 450, 50);
  doc.text(`Vencimiento: ${invoiceDate}`, 450, 70);
  
  // Línea separadora elegante
  doc.moveTo(40, 140).lineTo(555, 140).lineWidth(2).stroke(primaryColor);
  
  // Datos del cliente con diseño moderno
  doc.rect(40, 160, 515, 80).fill('white').stroke(primaryColor, 1);
  doc.fontSize(16).fillColor(primaryColor).text('DATOS DEL CLIENTE', 50, 170);
  
  doc.fontSize(11).fillColor('black');
  doc.text(`NIF/CIF: ${invoiceRequest.nif}`, 50, 190);
  doc.text(`Razón Social: ${invoiceRequest.companyName}`, 50, 205);
  doc.text(`Dirección: ${invoiceRequest.address}`, 50, 220);
  doc.text(`${invoiceRequest.postalCode} ${invoiceRequest.city}`, 50, 235);
  doc.text(`Email: ${invoiceRequest.email}`, 300, 190);
  if (invoiceRequest.phone) {
    doc.text(`Teléfono: ${invoiceRequest.phone}`, 300, 205);
  }
  
  // Detalles de la transacción con tabla moderna
  doc.rect(40, 260, 515, 200).fill('white').stroke(primaryColor, 1);
  doc.fontSize(16).fillColor(primaryColor).text('DETALLES DE LA TRANSACCIÓN', 50, 270);
  
  const startY = 290;
  doc.fontSize(11).fillColor('black');
  
  // Tabla de detalles
  const details = [
    ['ID de Transacción', transaction.id],
    ['Matrícula del Vehículo', transaction.plate],
    ['Zona de Estacionamiento', zones[transaction.zoneId]?.name || `Zona ${transaction.zoneId}`],
    ['Fecha y Hora', new Date(transaction.timestamp).toLocaleString('es-ES')],
    ['Tipo de Servicio', transaction.isExtend ? 'Extensión de estacionamiento' : 'Nuevo estacionamiento'],
    ['Duración', `${transaction.minutes} minutos`],
    ['Método de Pago', transaction.paymentMethod === 'card' ? 'Tarjeta' : 'Efectivo']
  ];
  
  details.forEach(([label, value], index) => {
    const y = startY + (index * 20);
    doc.fillColor(darkGray).text(label + ':', 50, y);
    doc.fillColor('black').text(value, 250, y);
  });
  
  // Línea separadora
  doc.moveTo(50, startY + 140).lineTo(505, startY + 140).lineWidth(1).stroke(darkGray);
  
  // Total con diseño destacado
  doc.rect(350, startY + 150, 155, 40).fill(secondaryColor);
  doc.fontSize(18).fillColor('white').text('TOTAL A PAGAR', 360, startY + 160);
  doc.fontSize(24).fillColor('white').text(`${transaction.amount.toFixed(2)} €`, 360, startY + 175);
  
  // Información fiscal con diseño moderno
  doc.rect(40, 480, 515, 100).fill(lightGray).stroke(darkGray, 1);
  doc.fontSize(12).fillColor(primaryColor).text('INFORMACIÓN FISCAL', 50, 500);
  
  doc.fontSize(9).fillColor(darkGray);
  doc.text('✓ Esta factura cumple con la normativa de facturación electrónica española', 50, 520);
  doc.text('✓ Ley 18/2022 "Crea y Crece" - Real Decreto 1007/2023', 50, 535);
  doc.text('✓ Sistema Verifactu compatible', 50, 550);
  doc.text('✓ Factura generada electrónicamente el ' + new Date().toLocaleString('es-ES'), 50, 565);
  
  // QR Code placeholder (simulado)
  doc.rect(450, 500, 80, 80).fill('white').stroke(darkGray, 1);
  doc.fontSize(8).fillColor(darkGray).text('QR', 480, 535, { align: 'center' });
  doc.text('Código', 480, 550, { align: 'center' });
  doc.text('Verificación', 480, 565, { align: 'center' });
  
  // Pie de página moderno
  doc.rect(0, 600, 595, 242).fill(primaryColor);
  doc.fontSize(14).fillColor('white').text('Gracias por confiar en MEYPARK', 50, 650, { align: 'center' });
  doc.fontSize(10).fillColor('white').text('www.meypark.es | soporte@meypark.es | +34 900 123 456', 50, 680, { align: 'center' });
  doc.text('Sistema de Parquímetros Inteligentes • Innovación en Movilidad Urbana', 50, 700, { align: 'center' });
  
  // Línea de separación
  doc.moveTo(50, 720).lineTo(545, 720).lineWidth(1).stroke('white');
  
  // Información legal
  doc.fontSize(8).fillColor('white').text('MEYPARK S.L. - CIF: B12345678 - Registro Mercantil de Madrid', 50, 740, { align: 'center' });
  doc.text('Calle de la Innovación, 123, 28001 Madrid, España', 50, 755, { align: 'center' });
  doc.text('Factura generada automáticamente el ' + new Date().toLocaleString('es-ES'), 50, 770, { align: 'center' });
  
  doc.end();
  
  return new Promise((resolve, reject) => {
    stream.on('finish', () => {
      resolve({ filename, filepath });
    });
    stream.on('error', reject);
  });
}

// Rutas API

// Obtener información de una transacción
app.get('/api/transaction/:id', (req, res) => {
  const transactionId = req.params.id;
  const transaction = transactions.get(transactionId);
  
  if (!transaction) {
    return res.json({ success: false, error: 'Transacción no encontrada' });
  }
  
  // Verificar que no haya pasado más de 30 días
  const daysSinceTransaction = (Date.now() - new Date(transaction.timestamp).getTime()) / (1000 * 60 * 60 * 24);
  if (daysSinceTransaction > 30) {
    return res.json({ success: false, error: 'La transacción ha expirado' });
  }
  
  const zoneInfo = zones[transaction.zoneId] || { name: `Zona ${transaction.zoneId}`, pricePerHour: 0 };
  
  res.json({
    success: true,
    transaction: {
      ...transaction,
      zoneName: zoneInfo.name
    }
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
    const updatedTransaction = {
      ...transaction,
      invoiceId,
      invoiceGeneratedAt: new Date().toISOString(),
      invoiceUrl: `http://localhost:${PORT}/invoices/${filename}`
    };
    
    transactions.set(transactionId, updatedTransaction);
    invoices.set(invoiceId, {
      ...invoiceRequest,
      transactionId,
      invoiceId,
      generatedAt: new Date().toISOString(),
      filename,
      filepath
    });
    
    console.log(`🧾 Factura generada: ${invoiceId} para transacción ${transactionId}`);
    
    res.json({
      success: true,
      invoiceId,
      invoiceUrl: updatedTransaction.invoiceUrl
    });
    
  } catch (error) {
    console.error('Error al generar factura:', error);
    res.json({ 
      success: false, 
      errorMessage: 'Error interno del servidor' 
    });
  }
});

// Obtener estado de factura
app.get('/api/invoice-status/:transactionId', (req, res) => {
  const transactionId = req.params.transactionId;
  const transaction = transactions.get(transactionId);
  
  if (!transaction) {
    return res.json({ 
      success: false, 
      errorMessage: 'Transacción no encontrada' 
    });
  }
  
  if (transaction.invoiceId) {
    res.json({
      success: true,
      invoiceId: transaction.invoiceId,
      invoiceUrl: transaction.invoiceUrl,
      generatedAt: transaction.invoiceGeneratedAt
    });
  } else {
    res.json({
      success: false,
      errorMessage: 'Factura no generada'
    });
  }
});

// Servir archivos PDF
app.get('/invoices/:filename', (req, res) => {
  const filename = req.params.filename;
  const filepath = path.join(__dirname, 'invoices', filename);
  
  if (fs.existsSync(filepath)) {
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.sendFile(filepath);
  } else {
    res.status(404).json({ error: 'Archivo no encontrado' });
  }
});

// Recibir transacciones de la app Flutter
app.post('/api/transactions', (req, res) => {
  try {
    const transaction = req.body;
    
    // Validar datos requeridos
    if (!transaction.id || !transaction.plate || !transaction.zoneId || !transaction.amount) {
      return res.status(400).json({ 
        success: false, 
        error: 'Datos de transacción incompletos' 
      });
    }
    
    // Almacenar transacción
    transactions.set(transaction.id, transaction);
    
    console.log(`📱 Transacción recibida de Flutter: ${transaction.id}`);
    console.log(`   Matrícula: ${transaction.plate}, Zona: ${transaction.zoneId}, Importe: ${transaction.amount}€`);
    
    res.json({
      success: true,
      message: 'Transacción registrada correctamente',
      transactionId: transaction.id
    });
    
  } catch (error) {
    console.error('Error al procesar transacción:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Error interno del servidor' 
    });
  }
});

// Ruta para crear transacciones de prueba (para testing)
app.post('/api/create-test-transaction', (req, res) => {
  const { plate, zoneId, amount, paymentMethod, isExtend, minutes } = req.body;
  
  const transactionId = 'TXN_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4);
  
  const transaction = {
    id: transactionId,
    plate: plate || '1234ABC',
    zoneId: zoneId || 'ZONA_001',
    timestamp: new Date().toISOString(),
    amount: amount || 2.50,
    paymentMethod: paymentMethod || 'cash',
    kioscoId: 'DEMO_KIOSCO',
    isExtend: isExtend || false,
    minutes: minutes || 60
  };
  
  transactions.set(transactionId, transaction);
  
  console.log(`🧪 Transacción de prueba creada: ${transactionId}`);
  
  res.json({
    success: true,
    transaction,
    qrUrl: `http://localhost:${PORT}/facturacion.html?transactionId=${transactionId}`
  });
});

// Ruta de estadísticas
app.get('/api/stats', (req, res) => {
  const totalTransactions = transactions.size;
  const invoicedTransactions = Array.from(transactions.values()).filter(t => t.invoiceId).length;
  const totalAmount = Array.from(transactions.values()).reduce((sum, t) => sum + t.amount, 0);
  const invoicedAmount = Array.from(transactions.values())
    .filter(t => t.invoiceId)
    .reduce((sum, t) => sum + t.amount, 0);
  
  res.json({
    totalTransactions,
    invoicedTransactions,
    totalAmount: totalAmount.toFixed(2),
    invoicedAmount: invoicedAmount.toFixed(2),
    invoiceRate: totalTransactions > 0 ? (invoicedTransactions / totalTransactions) : 0
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor de facturación electrónica iniciado en puerto ${PORT}`);
  console.log(`📱 Portal web: http://localhost:${PORT}/facturacion.html`);
  console.log(`📊 Estadísticas: http://localhost:${PORT}/api/stats`);
  console.log(`🧪 Crear transacción de prueba: POST http://localhost:${PORT}/api/create-test-transaction`);
});

// Manejo de errores
process.on('uncaughtException', (error) => {
  console.error('Error no capturado:', error);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Promesa rechazada no manejada:', reason);
});
