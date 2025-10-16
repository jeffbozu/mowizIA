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

    const { action, data } = await req.json()

    switch (action) {
      case 'get_company_stats':
        return await getCompanyStats(supabaseClient, data)
      
      case 'get_dashboard_data':
        return await getDashboardData(supabaseClient, data)
      
      case 'create_company':
        return await createCompany(supabaseClient, data)
      
      case 'update_company_config':
        return await updateCompanyConfig(supabaseClient, data)
      
      case 'sync_company_data':
        return await syncCompanyData(supabaseClient, data)
      
      case 'get_realtime_stats':
        return await getRealtimeStats(supabaseClient, data)
      
      case 'export_company_data':
        return await exportCompanyData(supabaseClient, data)
      
      case 'import_company_data':
        return await importCompanyData(supabaseClient, data)
      
      default:
        return new Response(
          JSON.stringify({ error: 'Acción no reconocida' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
    }

  } catch (error) {
    console.error('Error en control-center:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Obtener estadísticas de empresa
async function getCompanyStats(supabase: any, data: any) {
  const { company_id } = data

  // Obtener estadísticas básicas
  const { data: stats, error } = await supabase
    .from('v_company_stats')
    .select('*')
    .eq('company_id', company_id)
    .single()

  if (error) throw error

  // Obtener estadísticas de ingresos por día
  const { data: dailyIncome, error: dailyError } = await supabase
    .from('v_daily_income_summary')
    .select('*')
    .eq('company_id', company_id)
    .order('date', { ascending: false })
    .limit(30)

  if (dailyError) throw dailyError

  // Obtener top zonas por ingresos
  const { data: topZones, error: zonesError } = await supabase
    .from('v_top_zones_by_income')
    .select('*')
    .eq('company_id', company_id)
    .order('total_income', { ascending: false })
    .limit(10)

  if (zonesError) throw zonesError

  return new Response(
    JSON.stringify({
      success: true,
      data: {
        company_stats: stats,
        daily_income: dailyIncome,
        top_zones: topZones
      }
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// Obtener datos del dashboard
async function getDashboardData(supabase: any, data: any) {
  const { company_id } = data

  // Obtener datos completos de la empresa
  const { data: company, error: companyError } = await supabase
    .from('v_company_complete')
    .select('*')
    .eq('id', company_id)
    .single()

  if (companyError) throw companyError

  // Obtener kioscos activos
  const { data: kiosks, error: kiosksError } = await supabase
    .from('v_kiosks_status')
    .select('*')
    .eq('company_id', company_id)

  if (kiosksError) throw kiosksError

  // Obtener sesiones activas
  const { data: activeSessions, error: sessionsError } = await supabase
    .from('v_active_sessions_details')
    .select('*')
    .eq('company_id', company_id)

  if (sessionsError) throw sessionsError

  // Obtener operadores
  const { data: operators, error: operatorsError } = await supabase
    .from('v_operators_with_stats')
    .select('*')
    .eq('company_id', company_id)

  if (operatorsError) throw operatorsError

  return new Response(
    JSON.stringify({
      success: true,
      data: {
        company,
        kiosks,
        active_sessions: activeSessions,
        operators
      }
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// Crear nueva empresa
async function createCompany(supabase: any, data: any) {
  const { company_data, zones_data, operators_data, config_data } = data

  // Crear empresa
  const { data: company, error: companyError } = await supabase
    .from('companies')
    .insert(company_data)
    .select()
    .single()

  if (companyError) throw companyError

  // Crear zonas
  if (zones_data && zones_data.length > 0) {
    const zonesWithCompanyId = zones_data.map((zone: any) => ({
      ...zone,
      company_id: company.id
    }))

    const { error: zonesError } = await supabase
      .from('zones')
      .insert(zonesWithCompanyId)

    if (zonesError) throw zonesError
  }

  // Crear operadores
  if (operators_data && operators_data.length > 0) {
    const operatorsWithCompanyId = operators_data.map((operator: any) => ({
      ...operator,
      company_id: company.id
    }))

    const { error: operatorsError } = await supabase
      .from('operators')
      .insert(operatorsWithCompanyId)

    if (operatorsError) throw operatorsError
  }

  // Crear configuraciones
  if (config_data) {
    const { payment_config, accessibility_config, invoice_config } = config_data

    if (payment_config) {
      const { error: paymentError } = await supabase
        .from('payment_config')
        .insert({ ...payment_config, company_id: company.id })

      if (paymentError) throw paymentError
    }

    if (accessibility_config) {
      const { error: accessibilityError } = await supabase
        .from('accessibility_config')
        .insert({ ...accessibility_config, company_id: company.id })

      if (accessibilityError) throw accessibilityError
    }

    if (invoice_config) {
      const { error: invoiceError } = await supabase
        .from('invoice_config')
        .insert({ ...invoice_config, company_id: company.id })

      if (invoiceError) throw invoiceError
    }
  }

  return new Response(
    JSON.stringify({
      success: true,
      data: { company_id: company.id, message: 'Empresa creada exitosamente' }
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// Actualizar configuración de empresa
async function updateCompanyConfig(supabase: any, data: any) {
  const { company_id, config_type, config_data } = data

  let tableName = ''
  switch (config_type) {
    case 'company':
      tableName = 'companies'
      break
    case 'payment':
      tableName = 'payment_config'
      break
    case 'accessibility':
      tableName = 'accessibility_config'
      break
    case 'invoice':
      tableName = 'invoice_config'
      break
    default:
      throw new Error('Tipo de configuración no válido')
  }

  const { error } = await supabase
    .from(tableName)
    .update(config_data)
    .eq('company_id', company_id)

  if (error) throw error

  return new Response(
    JSON.stringify({
      success: true,
      message: 'Configuración actualizada exitosamente'
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// Sincronizar datos de empresa
async function syncCompanyData(supabase: any, data: any) {
  const { company_id } = data

  // Regenerar caché de traducciones
  const { data: translations, error: translationsError } = await supabase
    .from('ui_texts')
    .select('*')
    .eq('company_id', company_id)

  if (translationsError) throw translationsError

  // Agrupar por idioma y regenerar caché
  const translationsByLanguage: { [key: string]: any } = {}
  
  translations.forEach((translation: any) => {
    const language = translation.language
    if (!translationsByLanguage[language]) {
      translationsByLanguage[language] = {}
    }
    translationsByLanguage[language][`${translation.screen}.${translation.element}`] = translation.text_value
  })

  // Actualizar caché
  for (const [language, translationsJson] of Object.entries(translationsByLanguage)) {
    const { error: cacheError } = await supabase
      .from('ui_translations_cache')
      .upsert({
        company_id,
        language,
        translations_json: translationsJson,
        last_updated: new Date().toISOString()
      })

    if (cacheError) throw cacheError
  }

  return new Response(
    JSON.stringify({
      success: true,
      message: 'Datos sincronizados exitosamente'
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// Obtener estadísticas en tiempo real
async function getRealtimeStats(supabase: any, data: any) {
  const { company_id } = data

  // Obtener estadísticas actuales
  const { data: stats, error: statsError } = await supabase
    .from('v_company_stats')
    .select('*')
    .eq('company_id', company_id)
    .single()

  if (statsError) throw statsError

  // Obtener sesiones activas actuales
  const { data: activeSessions, error: sessionsError } = await supabase
    .from('active_sessions')
    .select('*')
    .eq('company_id', company_id)

  if (sessionsError) throw sessionsError

  // Obtener estado de kioscos
  const { data: kiosks, error: kiosksError } = await supabase
    .from('kiosks')
    .select('id, status, last_connection')
    .eq('company_id', company_id)

  if (kiosksError) throw kiosksError

  return new Response(
    JSON.stringify({
      success: true,
      data: {
        stats,
        active_sessions_count: activeSessions.length,
        online_kiosks: kiosks.filter(k => k.status === 'active').length,
        total_kiosks: kiosks.length,
        timestamp: new Date().toISOString()
      }
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// Exportar datos de empresa
async function exportCompanyData(supabase: any, data: any) {
  const { company_id } = data

  // Obtener todos los datos de la empresa
  const { data: company, error: companyError } = await supabase
    .from('v_company_complete')
    .select('*')
    .eq('id', company_id)
    .single()

  if (companyError) throw companyError

  // Obtener zonas
  const { data: zones, error: zonesError } = await supabase
    .from('zones')
    .select('*')
    .eq('company_id', company_id)

  if (zonesError) throw zonesError

  // Obtener operadores
  const { data: operators, error: operatorsError } = await supabase
    .from('operators')
    .select('*')
    .eq('company_id', company_id)

  if (operatorsError) throw operatorsError

  // Obtener textos de UI
  const { data: uiTexts, error: uiTextsError } = await supabase
    .from('ui_texts')
    .select('*')
    .eq('company_id', company_id)

  if (uiTextsError) throw uiTextsError

  // Obtener configuración de elementos UI
  const { data: uiElements, error: uiElementsError } = await supabase
    .from('ui_elements_config')
    .select('*')
    .eq('company_id', company_id)

  if (uiElementsError) throw uiElementsError

  const exportData = {
    company,
    zones,
    operators,
    ui_texts: uiTexts,
    ui_elements_config: uiElements,
    export_date: new Date().toISOString(),
    version: '1.0'
  }

  return new Response(
    JSON.stringify({
      success: true,
      data: exportData
    }),
    { 
      headers: { 
        ...corsHeaders, 
        'Content-Type': 'application/json',
        'Content-Disposition': `attachment; filename="company_${company_id}_export.json"`
      } 
    }
  )
}

// Importar datos de empresa
async function importCompanyData(supabase: any, data: any) {
  const { import_data, target_company_id } = data

  try {
    // Actualizar empresa
    if (import_data.company) {
      const { error: companyError } = await supabase
        .from('companies')
        .update(import_data.company)
        .eq('id', target_company_id)

      if (companyError) throw companyError
    }

    // Importar zonas
    if (import_data.zones && import_data.zones.length > 0) {
      const zonesWithCompanyId = import_data.zones.map((zone: any) => ({
        ...zone,
        company_id: target_company_id
      }))

      const { error: zonesError } = await supabase
        .from('zones')
        .upsert(zonesWithCompanyId)

      if (zonesError) throw zonesError
    }

    // Importar operadores
    if (import_data.operators && import_data.operators.length > 0) {
      const operatorsWithCompanyId = import_data.operators.map((operator: any) => ({
        ...operator,
        company_id: target_company_id
      }))

      const { error: operatorsError } = await supabase
        .from('operators')
        .upsert(operatorsWithCompanyId)

      if (operatorsError) throw operatorsError
    }

    // Importar textos de UI
    if (import_data.ui_texts && import_data.ui_texts.length > 0) {
      const uiTextsWithCompanyId = import_data.ui_texts.map((text: any) => ({
        ...text,
        company_id: target_company_id
      }))

      const { error: uiTextsError } = await supabase
        .from('ui_texts')
        .upsert(uiTextsWithCompanyId)

      if (uiTextsError) throw uiTextsError
    }

    // Importar configuración de elementos UI
    if (import_data.ui_elements_config && import_data.ui_elements_config.length > 0) {
      const uiElementsWithCompanyId = import_data.ui_elements_config.map((element: any) => ({
        ...element,
        company_id: target_company_id
      }))

      const { error: uiElementsError } = await supabase
        .from('ui_elements_config')
        .upsert(uiElementsWithCompanyId)

      if (uiElementsError) throw uiElementsError
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Datos importados exitosamente'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    throw new Error(`Error importando datos: ${error.message}`)
  }
}
