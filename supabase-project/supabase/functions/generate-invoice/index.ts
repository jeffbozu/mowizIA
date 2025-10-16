import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const { transactionId, invoiceRequest } = await req.json()

    // Obtener datos de la transacción
    const { data: transaction, error: transactionError } = await supabaseClient
      .from('active_sessions')
      .select(`
        *,
        zones!inner(*),
        companies!inner(*)
      `)
      .eq('id', transactionId)
      .single()

    if (transactionError) throw transactionError

    // Obtener configuración de facturación
    const { data: invoiceConfig, error: configError } = await supabaseClient
      .from('invoice_config')
      .select('*')
      .eq('company_id', transaction.companies.id)
      .single()

    if (configError) throw configError

    // Generar PDF de factura
    const pdfBuffer = await generateInvoicePDF(transaction, invoiceConfig, invoiceRequest)

    // Guardar PDF en Supabase Storage
    const fileName = `factura_${transaction.id}_${Date.now()}.pdf`
    const { data: uploadData, error: uploadError } = await supabaseClient.storage
      .from('invoices')
      .upload(fileName, pdfBuffer, {
        contentType: 'application/pdf',
        upsert: false
      })

    if (uploadError) throw uploadError

    // Obtener URL pública del PDF
    const { data: urlData } = supabaseClient.storage
      .from('invoices')
      .getPublicUrl(fileName)

    // Guardar registro de factura en base de datos
    const { data: invoiceRecord, error: invoiceError } = await supabaseClient
      .from('invoices')
      .insert({
        transaction_id: transactionId,
        company_id: transaction.companies.id,
        invoice_number: generateInvoiceNumber(),
        pdf_url: urlData.publicUrl,
        pdf_filename: fileName,
        total_amount: transaction.total_price,
        iva_amount: calculateIVA(transaction.total_price, invoiceConfig.iva_rate),
        customer_email: invoiceRequest.email,
        customer_name: invoiceRequest.name,
        status: 'generated'
      })
      .select()
      .single()

    if (invoiceError) throw invoiceError

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          invoice: invoiceRecord,
          pdfUrl: urlData.publicUrl,
          downloadUrl: urlData.publicUrl
        }
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error generando factura:', error)
    return new Response(
      JSON.stringify({ error: 'Error generando factura' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Generar PDF de factura usando Deno's built-in capabilities
async function generateInvoicePDF(transaction: any, invoiceConfig: any, invoiceRequest: any) {
  // Crear contenido HTML para la factura
  const htmlContent = generateInvoiceHTML(transaction, invoiceConfig, invoiceRequest)
  
  // Convertir HTML a PDF usando una librería de Deno
  // Nota: En un entorno real, podrías usar una librería como puppeteer o similar
  // Por ahora, crearemos un PDF básico usando texto plano
  
  const pdfContent = generateSimplePDF(transaction, invoiceConfig, invoiceRequest)
  
  // Convertir a buffer
  return new TextEncoder().encode(pdfContent)
}

// Generar HTML para la factura
function generateInvoiceHTML(transaction: any, invoiceConfig: any, invoiceRequest: any) {
  const ivaAmount = calculateIVA(transaction.total_price, invoiceConfig.iva_rate)
  const subtotal = transaction.total_price - ivaAmount

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>Factura ${generateInvoiceNumber()}</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .company-info { margin-bottom: 30px; }
        .invoice-details { margin-bottom: 30px; }
        .items-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        .items-table th, .items-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .items-table th { background-color: #f2f2f2; }
        .totals { text-align: right; }
        .footer { margin-top: 50px; text-align: center; font-size: 12px; color: #666; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>FACTURA ELECTRÓNICA</h1>
        <h2>${invoiceConfig.company_name}</h2>
      </div>
      
      <div class="company-info">
        <p><strong>CIF:</strong> ${invoiceConfig.cif}</p>
        <p><strong>Dirección:</strong> ${invoiceConfig.address}</p>
        <p><strong>Ciudad:</strong> ${invoiceConfig.city} ${invoiceConfig.postal_code}</p>
        <p><strong>Email:</strong> ${invoiceConfig.email}</p>
        <p><strong>Teléfono:</strong> ${invoiceConfig.phone}</p>
      </div>
      
      <div class="invoice-details">
        <p><strong>Número de Factura:</strong> ${generateInvoiceNumber()}</p>
        <p><strong>Fecha:</strong> ${new Date().toLocaleDateString('es-ES')}</p>
        <p><strong>Cliente:</strong> ${invoiceRequest.name}</p>
        <p><strong>Email Cliente:</strong> ${invoiceRequest.email}</p>
      </div>
      
      <table class="items-table">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Zona</th>
            <th>Matrícula</th>
            <th>Duración</th>
            <th>Precio</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Estacionamiento</td>
            <td>${transaction.zones.name}</td>
            <td>${transaction.plate}</td>
            <td>${calculateDuration(transaction.start_time, transaction.end_time)}</td>
            <td>${transaction.total_price.toFixed(2)} €</td>
          </tr>
        </tbody>
      </table>
      
      <div class="totals">
        <p><strong>Subtotal:</strong> ${subtotal.toFixed(2)} €</p>
        <p><strong>IVA (${invoiceConfig.iva_rate}%):</strong> ${ivaAmount.toFixed(2)} €</p>
        <p><strong>Total:</strong> ${transaction.total_price.toFixed(2)} €</p>
      </div>
      
      <div class="footer">
        <p>Esta es una factura electrónica generada automáticamente por el sistema MEYPARK</p>
        <p>Para cualquier consulta, contacte con ${invoiceConfig.email}</p>
      </div>
    </body>
    </html>
  `
}

// Generar PDF simple en formato texto
function generateSimplePDF(transaction: any, invoiceConfig: any, invoiceRequest: any) {
  const ivaAmount = calculateIVA(transaction.total_price, invoiceConfig.iva_rate)
  const subtotal = transaction.total_price - ivaAmount

  return `
FACTURA ELECTRÓNICA
==================

${invoiceConfig.company_name}
CIF: ${invoiceConfig.cif}
Dirección: ${invoiceConfig.address}
Ciudad: ${invoiceConfig.city} ${invoiceConfig.postal_code}
Email: ${invoiceConfig.email}
Teléfono: ${invoiceConfig.phone}

Número de Factura: ${generateInvoiceNumber()}
Fecha: ${new Date().toLocaleDateString('es-ES')}

Cliente: ${invoiceRequest.name}
Email Cliente: ${invoiceRequest.email}

DETALLES:
---------
Concepto: Estacionamiento
Zona: ${transaction.zones.name}
Matrícula: ${transaction.plate}
Duración: ${calculateDuration(transaction.start_time, transaction.end_time)}
Precio: ${transaction.total_price.toFixed(2)} €

TOTALES:
--------
Subtotal: ${subtotal.toFixed(2)} €
IVA (${invoiceConfig.iva_rate}%): ${ivaAmount.toFixed(2)} €
TOTAL: ${transaction.total_price.toFixed(2)} €

Esta es una factura electrónica generada automáticamente por el sistema MEYPARK
Para cualquier consulta, contacte con ${invoiceConfig.email}
  `
}

// Calcular IVA
function calculateIVA(amount: number, ivaRate: number): number {
  return amount * (ivaRate / 100)
}

// Generar número de factura
function generateInvoiceNumber(): string {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  const timestamp = now.getTime().toString().slice(-6)
  
  return `FAC-${year}${month}${day}-${timestamp}`
}

// Calcular duración entre dos fechas
function calculateDuration(startTime: string, endTime: string): string {
  const start = new Date(startTime)
  const end = new Date(endTime)
  const diffMs = end.getTime() - start.getTime()
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60))
  
  if (diffHours > 0) {
    return `${diffHours}h ${diffMinutes}m`
  } else {
    return `${diffMinutes}m`
  }
}
