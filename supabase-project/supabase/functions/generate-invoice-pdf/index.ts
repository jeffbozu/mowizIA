import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
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
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { invoiceId } = await req.json()

    if (!invoiceId) {
      return new Response(
        JSON.stringify({ error: 'invoiceId is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 1. Get invoice data from database
    const { data: invoice, error: invoiceError } = await supabase
      .from('invoices')
      .select(`
        *,
        companies!inner(name, primary_color, contact_email, contact_phone, address),
        zones!inner(name, price_per_hour)
      `)
      .eq('id', invoiceId)
      .single()

    if (invoiceError || !invoice) {
      return new Response(
        JSON.stringify({ error: 'Invoice not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 2. Generate PDF content (simplified version)
    const pdfContent = generatePDFContent(invoice)

    // 3. Create PDF blob (simplified - in production use a proper PDF library)
    const pdfBlob = new Blob([pdfContent], { type: 'application/pdf' })

    // 4. Upload to Supabase Storage
    const fileName = `invoice_${invoice.ticket_id}_${Date.now()}.pdf`
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('invoices')
      .upload(fileName, pdfBlob, {
        contentType: 'application/pdf',
        upsert: false
      })

    if (uploadError) {
      console.error('Upload error:', uploadError)
      return new Response(
        JSON.stringify({ error: 'Failed to upload PDF' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 5. Get public URL
    const { data: urlData } = supabase.storage
      .from('invoices')
      .getPublicUrl(fileName)

    // 6. Update invoice with PDF URL
    const { error: updateError } = await supabase
      .from('invoices')
      .update({ 
        invoice_pdf_url: urlData.publicUrl,
        status: 'completed'
      })
      .eq('id', invoiceId)

    if (updateError) {
      console.error('Update error:', updateError)
      return new Response(
        JSON.stringify({ error: 'Failed to update invoice' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        pdfUrl: urlData.publicUrl,
        invoiceNumber: invoice.invoice_number
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

function generatePDFContent(invoice: any): string {
  // Simplified PDF content generation
  // In production, use a proper PDF library like jsPDF or PDFKit
  
  const company = invoice.companies
  const zone = invoice.zones
  
  const pdfContent = `
%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj

2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj

3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
/Resources <<
  /Font <<
    /F1 5 0 R
  >>
>>
>>
endobj

4 0 obj
<<
/Length 200
>>
stream
BT
/F1 12 Tf
50 750 Td
(FACTURA ELECTRONICA) Tj
0 -20 Td
(Numero: ${invoice.invoice_number || 'PENDIENTE'}) Tj
0 -20 Td
(Fecha: ${new Date(invoice.created_at).toLocaleDateString('es-ES')}) Tj
0 -40 Td
(EMPRESA: ${company.name}) Tj
0 -20 Td
(ZONA: ${zone.name}) Tj
0 -20 Td
(MATRICULA: ${invoice.plate}) Tj
0 -20 Td
(DURACION: ${invoice.duration_minutes} minutos) Tj
0 -20 Td
(IMPORTE: ${invoice.amount} EUR) Tj
0 -20 Td
(METODO PAGO: ${invoice.payment_method}) Tj
0 -40 Td
(DATOS FISCALES:) Tj
0 -20 Td
(Nombre: ${invoice.fiscal_name || 'PENDIENTE'}) Tj
0 -20 Td
(NIF: ${invoice.fiscal_nif || 'PENDIENTE'}) Tj
0 -20 Td
(Direccion: ${invoice.fiscal_address || 'PENDIENTE'}) Tj
0 -20 Td
(Ciudad: ${invoice.fiscal_city || 'PENDIENTE'}) Tj
0 -20 Td
(CP: ${invoice.fiscal_postal_code || 'PENDIENTE'}) Tj
0 -20 Td
(Email: ${invoice.fiscal_email || 'PENDIENTE'}) Tj
ET
endstream
endobj

5 0 obj
<<
/Type /Font
/Subtype /Type1
/BaseFont /Helvetica
>>
endobj

xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000274 00000 n 
0000000525 00000 n 
trailer
<<
/Size 6
/Root 1 0 R
>>
startxref
612
%%EOF
`

  return pdfContent
}
