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
  const doc = new PDFDocument({ size: 'A4', margin: 50 });
  const filename = `factura_${transaction.id}.pdf`;
  const filepath = path.join(__dirname, 'invoices', filename);
  
  // Crear directorio si no existe
  if (!fs.existsSync(path.join(__dirname, 'invoices'))) {
    fs.mkdirSync(path.join(__dirname, 'invoices'));
  }
  
  const stream = fs.createWriteStream(filepath);
  doc.pipe(stream);
  
  // Encabezado
  doc.fontSize(20).text('FACTURA ELECTRÓNICA', 50, 50);
  doc.fontSize(12).text('MEYPARK - Sistema de Parquímetros', 50, 80);
  doc.text('CIF: B12345678', 50, 95);
  doc.text('Calle de la Innovación, 123', 50, 110);
  doc.text('28001 Madrid, España', 50, 125);
  
  // Línea separadora
  doc.moveTo(50, 150).lineTo(550, 150).stroke();
  
  // Datos del cliente
  doc.fontSize(14).text('DATOS DEL CLIENTE', 50, 170);
  doc.fontSize(10).text(`NIF/CIF: ${invoiceRequest.nif}`, 50, 190);
  doc.text(`Razón Social: ${invoiceRequest.companyName}`, 50, 205);
  doc.text(`Dirección: ${invoiceRequest.address}`, 50, 220);
  doc.text(`${invoiceRequest.postalCode} ${invoiceRequest.city}`, 50, 235);
  doc.text(`Email: ${invoiceRequest.email}`, 50, 250);
  if (invoiceRequest.phone) {
    doc.text(`Teléfono: ${invoiceRequest.phone}`, 50, 265);
  }
  
  // Línea separadora
  doc.moveTo(50, 290).lineTo(550, 290).stroke();
  
  // Detalles de la transacción
  doc.fontSize(14).text('DETALLES DE LA TRANSACCIÓN', 50, 310);
  
  const startY = 330;
  doc.fontSize(10);
  doc.text('ID de Transacción:', 50, startY);
  doc.text(transaction.id, 200, startY);
  
  doc.text('Matrícula:', 50, startY + 15);
  doc.text(transaction.plate, 200, startY + 15);
  
  doc.text('Zona:', 50, startY + 30);
  doc.text(zones[transaction.zoneId]?.name || `Zona ${transaction.zoneId}`, 200, startY + 30);
  
  doc.text('Fecha:', 50, startY + 45);
  doc.text(new Date(transaction.timestamp).toLocaleString('es-ES'), 200, startY + 45);
  
  doc.text('Tipo:', 50, startY + 60);
  doc.text(transaction.isExtend ? 'Extensión de estacionamiento' : 'Nuevo estacionamiento', 200, startY + 60);
  
  doc.text('Duración:', 50, startY + 75);
  doc.text(`${transaction.minutes} minutos`, 200, startY + 75);
  
  // Línea separadora
  doc.moveTo(50, startY + 100).lineTo(550, startY + 100).stroke();
  
  // Total
  doc.fontSize(16).text('TOTAL:', 400, startY + 120);
  doc.text(`${transaction.amount.toFixed(2)} €`, 500, startY + 120);
  
  // Información fiscal
  doc.fontSize(8).text('Esta factura cumple con la normativa de facturación electrónica española', 50, startY + 160);
  doc.text('Ley 18/2022 "Crea y Crece" - Real Decreto 1007/2023', 50, startY + 175);
  doc.text('Sistema Verifactu compatible', 50, startY + 190);
  
  // Pie de página
  doc.fontSize(8).text('Gracias por usar MEYPARK', 50, 750, { align: 'center' });
  doc.text('www.meypark.es | soporte@meypark.es', 50, 765, { align: 'center' });
  
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
