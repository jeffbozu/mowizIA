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

    const url = new URL(req.url)
    const path = url.pathname
    const method = req.method

    // Rutas del dashboard
    switch (path) {
      case '/api/companies':
        return await handleCompanies(supabaseClient, method, req)
      
      case '/api/operators':
        return await handleOperators(supabaseClient, method, req)
      
      case '/api/zones':
        return await handleZones(supabaseClient, method, req)
      
      case '/api/sessions':
        return await handleSessions(supabaseClient, method, req)
      
      case '/api/kiosks':
        return await handleKiosks(supabaseClient, method, req)
      
      case '/api/stats':
        return await handleStats(supabaseClient, method, req)
      
      case '/api/invoices':
        return await handleInvoices(supabaseClient, method, req)
      
      default:
        return new Response(
          JSON.stringify({ error: 'Endpoint no encontrado' }),
          { 
            status: 404, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
    }
  } catch (error) {
    console.error('Error en dashboard-api:', error)
    return new Response(
      JSON.stringify({ error: 'Error interno del servidor' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Manejar endpoints de empresas
async function handleCompanies(supabaseClient: any, method: string, req: Request) {
  switch (method) {
    case 'GET':
      const { data: companies, error } = await supabaseClient
        .from('companies')
        .select('*')
        .eq('is_active', true)
        .order('name')

      if (error) throw error

      return new Response(
        JSON.stringify({ success: true, data: companies }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'POST':
      const newCompany = await req.json()
      const { data: createdCompany, error: createError } = await supabaseClient
        .from('companies')
        .insert(newCompany)
        .select()
        .single()

      if (createError) throw createError

      return new Response(
        JSON.stringify({ success: true, data: createdCompany }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'PUT':
      const { id, ...updateData } = await req.json()
      const { data: updatedCompany, error: updateError } = await supabaseClient
        .from('companies')
        .update(updateData)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      return new Response(
        JSON.stringify({ success: true, data: updatedCompany }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'DELETE':
      const { id: deleteId } = await req.json()
      const { error: deleteError } = await supabaseClient
        .from('companies')
        .update({ is_active: false })
        .eq('id', deleteId)

      if (deleteError) throw deleteError

      return new Response(
        JSON.stringify({ success: true, message: 'Empresa desactivada' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    default:
      return new Response(
        JSON.stringify({ error: 'Método no soportado' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
  }
}

// Manejar endpoints de operadores
async function handleOperators(supabaseClient: any, method: string, req: Request) {
  switch (method) {
    case 'GET':
      const url = new URL(req.url)
      const companyId = url.searchParams.get('company_id')
      
      let query = supabaseClient
        .from('operators')
        .select('*')
        .eq('is_active', true)
      
      if (companyId) {
        query = query.eq('company_id', companyId)
      }
      
      const { data: operators, error } = await query.order('name')

      if (error) throw error

      return new Response(
        JSON.stringify({ success: true, data: operators }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'POST':
      const newOperator = await req.json()
      const { data: createdOperator, error: createError } = await supabaseClient
        .from('operators')
        .insert(newOperator)
        .select()
        .single()

      if (createError) throw createError

      return new Response(
        JSON.stringify({ success: true, data: createdOperator }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'PUT':
      const { id, ...updateData } = await req.json()
      const { data: updatedOperator, error: updateError } = await supabaseClient
        .from('operators')
        .update(updateData)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      return new Response(
        JSON.stringify({ success: true, data: updatedOperator }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'DELETE':
      const { id: deleteId } = await req.json()
      const { error: deleteError } = await supabaseClient
        .from('operators')
        .update({ is_active: false })
        .eq('id', deleteId)

      if (deleteError) throw deleteError

      return new Response(
        JSON.stringify({ success: true, message: 'Operador desactivado' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    default:
      return new Response(
        JSON.stringify({ error: 'Método no soportado' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
  }
}

// Manejar endpoints de zonas
async function handleZones(supabaseClient: any, method: string, req: Request) {
  switch (method) {
    case 'GET':
      const url = new URL(req.url)
      const companyId = url.searchParams.get('company_id')
      
      let query = supabaseClient
        .from('zones')
        .select('*')
        .eq('is_active', true)
      
      if (companyId) {
        query = query.eq('company_id', companyId)
      }
      
      const { data: zones, error } = await query.order('name')

      if (error) throw error

      return new Response(
        JSON.stringify({ success: true, data: zones }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'POST':
      const newZone = await req.json()
      const { data: createdZone, error: createError } = await supabaseClient
        .from('zones')
        .insert(newZone)
        .select()
        .single()

      if (createError) throw createError

      return new Response(
        JSON.stringify({ success: true, data: createdZone }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'PUT':
      const { id, ...updateData } = await req.json()
      const { data: updatedZone, error: updateError } = await supabaseClient
        .from('zones')
        .update(updateData)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      return new Response(
        JSON.stringify({ success: true, data: updatedZone }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'DELETE':
      const { id: deleteId } = await req.json()
      const { error: deleteError } = await supabaseClient
        .from('zones')
        .update({ is_active: false })
        .eq('id', deleteId)

      if (deleteError) throw deleteError

      return new Response(
        JSON.stringify({ success: true, message: 'Zona desactivada' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    default:
      return new Response(
        JSON.stringify({ error: 'Método no soportado' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
  }
}

// Manejar endpoints de sesiones
async function handleSessions(supabaseClient: any, method: string, req: Request) {
  switch (method) {
    case 'GET':
      const url = new URL(req.url)
      const companyId = url.searchParams.get('company_id')
      const kioskId = url.searchParams.get('kiosk_id')
      const status = url.searchParams.get('status') || 'active'
      
      let query = supabaseClient
        .from('active_sessions')
        .select(`
          *,
          zones!inner(*),
          companies!inner(*)
        `)
      
      if (companyId) {
        query = query.eq('companies.id', companyId)
      }
      
      if (kioskId) {
        query = query.eq('kiosk_id', kioskId)
      }
      
      if (status === 'active') {
        query = query.gte('end_time', new Date().toISOString())
      } else if (status === 'expired') {
        query = query.lt('end_time', new Date().toISOString())
      }
      
      const { data: sessions, error } = await query.order('start_time', { ascending: false })

      if (error) throw error

      return new Response(
        JSON.stringify({ success: true, data: sessions }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'DELETE':
      const { plate } = await req.json()
      const { error: deleteError } = await supabaseClient
        .from('active_sessions')
        .delete()
        .eq('plate', plate)

      if (deleteError) throw deleteError

      return new Response(
        JSON.stringify({ success: true, message: 'Sesión eliminada' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    default:
      return new Response(
        JSON.stringify({ error: 'Método no soportado' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
  }
}

// Manejar endpoints de kioscos
async function handleKiosks(supabaseClient: any, method: string, req: Request) {
  switch (method) {
    case 'GET':
      const url = new URL(req.url)
      const companyId = url.searchParams.get('company_id')
      
      let query = supabaseClient
        .from('kiosks')
        .select('*')
        .eq('is_active', true)
      
      if (companyId) {
        query = query.eq('company_id', companyId)
      }
      
      const { data: kiosks, error } = await query.order('name')

      if (error) throw error

      return new Response(
        JSON.stringify({ success: true, data: kiosks }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    case 'PUT':
      const { id, ...updateData } = await req.json()
      const { data: updatedKiosk, error: updateError } = await supabaseClient
        .from('kiosks')
        .update(updateData)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      return new Response(
        JSON.stringify({ success: true, data: updatedKiosk }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    default:
      return new Response(
        JSON.stringify({ error: 'Método no soportado' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
  }
}

// Manejar endpoints de estadísticas
async function handleStats(supabaseClient: any, method: string, req: Request) {
  if (method !== 'GET') {
    return new Response(
      JSON.stringify({ error: 'Método no soportado' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const url = new URL(req.url)
  const companyId = url.searchParams.get('company_id')
  const period = url.searchParams.get('period') || 'today'

  try {
    // Calcular fechas según el período
    const now = new Date()
    let startDate: Date
    
    switch (period) {
      case 'today':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        break
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
        break
      case 'month':
        startDate = new Date(now.getFullYear(), now.getMonth(), 1)
        break
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    }

    // Obtener estadísticas de sesiones
    let sessionsQuery = supabaseClient
      .from('active_sessions')
      .select('*')
      .gte('start_time', startDate.toISOString())
    
    if (companyId) {
      sessionsQuery = sessionsQuery.eq('company_id', companyId)
    }

    const { data: sessions, error: sessionsError } = await sessionsQuery

    if (sessionsError) throw sessionsError

    // Calcular estadísticas
    const totalSessions = sessions.length
    const totalRevenue = sessions.reduce((sum: number, session: any) => sum + session.total_price, 0)
    const averageSessionValue = totalSessions > 0 ? totalRevenue / totalSessions : 0

    // Obtener estadísticas por zona
    const zoneStats = sessions.reduce((acc: any, session: any) => {
      const zoneId = session.zone_id
      if (!acc[zoneId]) {
        acc[zoneId] = { count: 0, revenue: 0 }
      }
      acc[zoneId].count++
      acc[zoneId].revenue += session.total_price
      return acc
    }, {})

    // Obtener estadísticas por método de pago
    const paymentStats = sessions.reduce((acc: any, session: any) => {
      const method = session.payment_method || 'cash'
      if (!acc[method]) {
        acc[method] = { count: 0, revenue: 0 }
      }
      acc[method].count++
      acc[method].revenue += session.total_price
      return acc
    }, {})

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          period,
          totalSessions,
          totalRevenue,
          averageSessionValue,
          zoneStats,
          paymentStats
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error obteniendo estadísticas:', error)
    return new Response(
      JSON.stringify({ error: 'Error obteniendo estadísticas' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}

// Manejar endpoints de facturas
async function handleInvoices(supabaseClient: any, method: string, req: Request) {
  switch (method) {
    case 'GET':
      const url = new URL(req.url)
      const companyId = url.searchParams.get('company_id')
      
      let query = supabaseClient
        .from('invoices')
        .select('*')
        .order('created_at', { ascending: false })
      
      if (companyId) {
        query = query.eq('company_id', companyId)
      }
      
      const { data: invoices, error } = await query

      if (error) throw error

      return new Response(
        JSON.stringify({ success: true, data: invoices }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    default:
      return new Response(
        JSON.stringify({ error: 'Método no soportado' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
  }
}
