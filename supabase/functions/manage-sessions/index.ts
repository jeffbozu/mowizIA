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

    const { method, data } = await req.json()

    switch (method) {
      case 'get_data':
        return await handleGetData(supabaseClient, data)
      
      case 'add_session':
        return await handleAddSession(supabaseClient, data)
      
      case 'update_session':
        return await handleUpdateSession(supabaseClient, data)
      
      case 'remove_session':
        return await handleRemoveSession(supabaseClient, data)
      
      case 'search_session':
        return await handleSearchSession(supabaseClient, data)
      
      case 'extend_session':
        return await handleExtendSession(supabaseClient, data)
      
      case 'get_company_data':
        return await handleGetCompanyData(supabaseClient, data)
      
      case 'update_operators':
        return await handleUpdateOperators(supabaseClient, data)
      
      case 'update_zones':
        return await handleUpdateZones(supabaseClient, data)
      
      case 'update_companies':
        return await handleUpdateCompanies(supabaseClient, data)
      
      default:
        return new Response(
          JSON.stringify({ error: 'Método no soportado' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
    }
  } catch (error) {
    console.error('Error en manage-sessions:', error)
    return new Response(
      JSON.stringify({ error: 'Error interno del servidor' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Obtener todos los datos de una empresa
async function handleGetData(supabaseClient: any, data: any) {
  const { companyId } = data

  try {
    // Obtener empresa
    const { data: company, error: companyError } = await supabaseClient
      .from('companies')
      .select('*')
      .eq('id', companyId)
      .single()

    if (companyError) throw companyError

    // Obtener operadores
    const { data: operators, error: operatorsError } = await supabaseClient
      .from('operators')
      .select('*')
      .eq('company_id', companyId)
      .eq('is_active', true)

    if (operatorsError) throw operatorsError

    // Obtener zonas
    const { data: zones, error: zonesError } = await supabaseClient
      .from('zones')
      .select('*')
      .eq('company_id', companyId)
      .eq('is_active', true)

    if (zonesError) throw zonesError

    // Obtener sesiones activas
    const { data: sessions, error: sessionsError } = await supabaseClient
      .from('active_sessions')
      .select('*')
      .eq('kiosk_id', data.kioskId || 'default')

    if (sessionsError) throw sessionsError

    // Obtener configuración de pagos
    const { data: paymentConfig, error: paymentError } = await supabaseClient
      .from('payment_config')
      .select('*')
      .eq('company_id', companyId)
      .single()

    if (paymentError) throw paymentError

    // Obtener configuración de accesibilidad
    const { data: accessibilityConfig, error: accessibilityError } = await supabaseClient
      .from('accessibility_config')
      .select('*')
      .eq('company_id', companyId)
      .single()

    if (accessibilityError) throw accessibilityError

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          company,
          operators,
          zones,
          sessions: sessions || [],
          paymentConfig,
          accessibilityConfig
        }
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error obteniendo datos:', error)
    return new Response(
      JSON.stringify({ error: 'Error obteniendo datos' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Agregar nueva sesión
async function handleAddSession(supabaseClient: any, data: any) {
  const { sessionData } = data

  try {
    const { data: session, error } = await supabaseClient
      .from('active_sessions')
      .insert({
        kiosk_id: sessionData.kioskId || 'default',
        zone_id: sessionData.zoneId,
        plate: sessionData.plate,
        start_time: sessionData.start,
        end_time: sessionData.end,
        total_price: sessionData.totalPrice,
        payment_method: sessionData.paymentMethod,
        is_extend: false
      })
      .select()
      .single()

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        data: session
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error agregando sesión:', error)
    return new Response(
      JSON.stringify({ error: 'Error agregando sesión' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Actualizar sesión existente
async function handleUpdateSession(supabaseClient: any, data: any) {
  const { sessionId, sessionData } = data

  try {
    const { data: session, error } = await supabaseClient
      .from('active_sessions')
      .update({
        zone_id: sessionData.zoneId,
        plate: sessionData.plate,
        start_time: sessionData.start,
        end_time: sessionData.end,
        total_price: sessionData.totalPrice,
        payment_method: sessionData.paymentMethod,
        is_extend: sessionData.isExtend || false
      })
      .eq('id', sessionId)
      .select()
      .single()

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        data: session
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error actualizando sesión:', error)
    return new Response(
      JSON.stringify({ error: 'Error actualizando sesión' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Eliminar sesión
async function handleRemoveSession(supabaseClient: any, data: any) {
  const { plate } = data

  try {
    const { error } = await supabaseClient
      .from('active_sessions')
      .delete()
      .eq('plate', plate)

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Sesión eliminada correctamente'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error eliminando sesión:', error)
    return new Response(
      JSON.stringify({ error: 'Error eliminando sesión' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Buscar sesión por matrícula
async function handleSearchSession(supabaseClient: any, data: any) {
  const { plate } = data

  try {
    const { data: session, error } = await supabaseClient
      .from('active_sessions')
      .select('*')
      .eq('plate', plate)
      .single()

    if (error && error.code !== 'PGRST116') throw error

    return new Response(
      JSON.stringify({
        success: true,
        data: session || null
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error buscando sesión:', error)
    return new Response(
      JSON.stringify({ error: 'Error buscando sesión' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Extender sesión existente
async function handleExtendSession(supabaseClient: any, data: any) {
  const { plate, extraMinutes, price } = data

  try {
    // Obtener sesión actual
    const { data: currentSession, error: getError } = await supabaseClient
      .from('active_sessions')
      .select('*')
      .eq('plate', plate)
      .single()

    if (getError) throw getError

    // Calcular nueva fecha de fin
    const newEndTime = new Date(currentSession.end_time)
    newEndTime.setMinutes(newEndTime.getMinutes() + extraMinutes)

    // Actualizar sesión
    const { data: updatedSession, error: updateError } = await supabaseClient
      .from('active_sessions')
      .update({
        end_time: newEndTime.toISOString(),
        total_price: currentSession.total_price + price,
        is_extend: true
      })
      .eq('id', currentSession.id)
      .select()
      .single()

    if (updateError) throw updateError

    return new Response(
      JSON.stringify({
        success: true,
        data: updatedSession
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error extendiendo sesión:', error)
    return new Response(
      JSON.stringify({ error: 'Error extendiendo sesión' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Obtener datos de empresa
async function handleGetCompanyData(supabaseClient: any, data: any) {
  const { companyId } = data

  try {
    const { data: company, error } = await supabaseClient
      .from('companies')
      .select('*')
      .eq('id', companyId)
      .single()

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        data: company
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error obteniendo datos de empresa:', error)
    return new Response(
      JSON.stringify({ error: 'Error obteniendo datos de empresa' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Actualizar operadores
async function handleUpdateOperators(supabaseClient: any, data: any) {
  const { operators } = data

  try {
    // Eliminar operadores existentes
    await supabaseClient
      .from('operators')
      .delete()
      .eq('company_id', operators[0]?.companyId)

    // Insertar nuevos operadores
    const { data: newOperators, error } = await supabaseClient
      .from('operators')
      .insert(operators.map((op: any) => ({
        id: op.id,
        company_id: op.companyId,
        name: op.name,
        username: op.username,
        password_hash: op.passwordHash,
        role: op.role || 'operator',
        permissions: op.permissions || {},
        is_active: true
      })))
      .select()

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        data: newOperators
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error actualizando operadores:', error)
    return new Response(
      JSON.stringify({ error: 'Error actualizando operadores' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Actualizar zonas
async function handleUpdateZones(supabaseClient: any, data: any) {
  const { zones } = data

  try {
    // Eliminar zonas existentes
    await supabaseClient
      .from('zones')
      .delete()
      .eq('company_id', zones[0]?.companyId)

    // Insertar nuevas zonas
    const { data: newZones, error } = await supabaseClient
      .from('zones')
      .insert(zones.map((zone: any) => ({
        id: zone.id,
        company_id: zone.companyId,
        name: zone.name,
        color: zone.color,
        price_per_hour: zone.pricePerHour,
        max_duration: zone.maxDuration,
        description: zone.description,
        time_options: zone.timeOptions || {},
        time_increment: zone.timeIncrement || 15,
        min_time: zone.minTime || 15,
        is_active: true
      })))
      .select()

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        data: newZones
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error actualizando zonas:', error)
    return new Response(
      JSON.stringify({ error: 'Error actualizando zonas' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}

// Actualizar empresas
async function handleUpdateCompanies(supabaseClient: any, data: any) {
  const { companies } = data

  try {
    // Eliminar empresas existentes
    await supabaseClient
      .from('companies')
      .delete()
      .in('id', companies.map((c: any) => c.id))

    // Insertar nuevas empresas
    const { data: newCompanies, error } = await supabaseClient
      .from('companies')
      .insert(companies.map((company: any) => ({
        id: company.id,
        name: company.name,
        primary_color: company.primaryColor,
        background_color: company.backgroundColor,
        logo_url: company.logoUrl || '',
        contact_email: company.contactEmail || '',
        phone: company.phone || '',
        address: company.address || '',
        is_active: true
      })))
      .select()

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        data: newCompanies
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error actualizando empresas:', error)
    return new Response(
      JSON.stringify({ error: 'Error actualizando empresas' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}
