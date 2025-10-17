import { supabase } from '../config/supabase'

export interface RevenueReport {
  period: string
  totalRevenue: number
  totalTransactions: number
  averageTransactionValue: number
  revenueByCompany: Array<{
    companyId: string
    companyName: string
    revenue: number
    transactions: number
  }>
  revenueByZone: Array<{
    zoneId: string
    zoneName: string
    revenue: number
    transactions: number
  }>
  dailyRevenue: Array<{
    date: string
    revenue: number
    transactions: number
  }>
}

export interface UsageReport {
  period: string
  totalSessions: number
  averageSessionDuration: number
  usageByZone: Array<{
    zoneId: string
    zoneName: string
    sessions: number
    totalDuration: number
    averageDuration: number
  }>
  usageByCompany: Array<{
    companyId: string
    companyName: string
    sessions: number
    totalDuration: number
  }>
  peakHours: Array<{
    hour: number
    sessions: number
  }>
}

export interface SystemStats {
  totalCompanies: number
  activeCompanies: number
  totalZones: number
  activeZones: number
  totalOperators: number
  activeOperators: number
  totalInvoices: number
  pendingInvoices: number
  completedInvoices: number
  failedInvoices: number
  totalRevenue: number
  todayRevenue: number
  monthlyRevenue: number
}

export class AnalyticsService {
  /**
   * Genera reporte de ingresos por período
   */
  static async getRevenueReport(
    startDate: string,
    endDate: string,
    companyId?: string
  ): Promise<RevenueReport> {
    try {
      // Construir query base
      let query = supabase
        .from('invoices')
        .select(`
          *,
          companies!inner(name),
          zones!inner(name)
        `)
        .gte('created_at', startDate)
        .lte('created_at', endDate)
        .eq('status', 'completed')

      if (companyId) {
        query = query.eq('company_id', companyId)
      }

      const { data: invoices, error } = await query

      if (error) {
        throw new Error(`Error fetching revenue data: ${error.message}`)
      }

      if (!invoices || invoices.length === 0) {
        return {
          period: `${startDate} - ${endDate}`,
          totalRevenue: 0,
          totalTransactions: 0,
          averageTransactionValue: 0,
          revenueByCompany: [],
          revenueByZone: [],
          dailyRevenue: []
        }
      }

      // Calcular métricas principales
      const totalRevenue = invoices.reduce((sum, invoice) => sum + (invoice.amount || 0), 0)
      const totalTransactions = invoices.length
      const averageTransactionValue = totalTransactions > 0 ? totalRevenue / totalTransactions : 0

      // Agrupar por empresa
      const companyMap = new Map()
      invoices.forEach(invoice => {
        const companyId = invoice.company_id
        const companyName = invoice.companies?.name || 'Unknown'
        
        if (!companyMap.has(companyId)) {
          companyMap.set(companyId, {
            companyId,
            companyName,
            revenue: 0,
            transactions: 0
          })
        }
        
        const company = companyMap.get(companyId)
        company.revenue += invoice.amount || 0
        company.transactions += 1
      })

      const revenueByCompany = Array.from(companyMap.values())
        .sort((a, b) => b.revenue - a.revenue)

      // Agrupar por zona
      const zoneMap = new Map()
      invoices.forEach(invoice => {
        const zoneId = invoice.zone_id
        const zoneName = invoice.zones?.name || 'Unknown'
        
        if (!zoneMap.has(zoneId)) {
          zoneMap.set(zoneId, {
            zoneId,
            zoneName,
            revenue: 0,
            transactions: 0
          })
        }
        
        const zone = zoneMap.get(zoneId)
        zone.revenue += invoice.amount || 0
        zone.transactions += 1
      })

      const revenueByZone = Array.from(zoneMap.values())
        .sort((a, b) => b.revenue - a.revenue)

      // Agrupar por día
      const dailyMap = new Map()
      invoices.forEach(invoice => {
        const date = invoice.created_at.split('T')[0]
        
        if (!dailyMap.has(date)) {
          dailyMap.set(date, {
            date,
            revenue: 0,
            transactions: 0
          })
        }
        
        const day = dailyMap.get(date)
        day.revenue += invoice.amount || 0
        day.transactions += 1
      })

      const dailyRevenue = Array.from(dailyMap.values())
        .sort((a, b) => a.date.localeCompare(b.date))

      return {
        period: `${startDate} - ${endDate}`,
        totalRevenue,
        totalTransactions,
        averageTransactionValue,
        revenueByCompany,
        revenueByZone,
        dailyRevenue
      }
    } catch (error) {
      console.error('Error generating revenue report:', error)
      throw error
    }
  }

  /**
   * Genera reporte de uso por período
   */
  static async getUsageReport(
    startDate: string,
    endDate: string,
    companyId?: string
  ): Promise<UsageReport> {
    try {
      // Construir query base
      let query = supabase
        .from('invoices')
        .select(`
          *,
          companies!inner(name),
          zones!inner(name)
        `)
        .gte('created_at', startDate)
        .lte('created_at', endDate)

      if (companyId) {
        query = query.eq('company_id', companyId)
      }

      const { data: invoices, error } = await query

      if (error) {
        throw new Error(`Error fetching usage data: ${error.message}`)
      }

      if (!invoices || invoices.length === 0) {
        return {
          period: `${startDate} - ${endDate}`,
          totalSessions: 0,
          averageSessionDuration: 0,
          usageByZone: [],
          usageByCompany: [],
          peakHours: []
        }
      }

      // Calcular métricas principales
      const totalSessions = invoices.length
      const totalDuration = invoices.reduce((sum, invoice) => sum + (invoice.duration_minutes || 0), 0)
      const averageSessionDuration = totalSessions > 0 ? totalDuration / totalSessions : 0

      // Agrupar por zona
      const zoneMap = new Map()
      invoices.forEach(invoice => {
        const zoneId = invoice.zone_id
        const zoneName = invoice.zones?.name || 'Unknown'
        
        if (!zoneMap.has(zoneId)) {
          zoneMap.set(zoneId, {
            zoneId,
            zoneName,
            sessions: 0,
            totalDuration: 0,
            averageDuration: 0
          })
        }
        
        const zone = zoneMap.get(zoneId)
        zone.sessions += 1
        zone.totalDuration += invoice.duration_minutes || 0
      })

      // Calcular duración promedio por zona
      const usageByZone = Array.from(zoneMap.values()).map(zone => ({
        ...zone,
        averageDuration: zone.sessions > 0 ? zone.totalDuration / zone.sessions : 0
      })).sort((a, b) => b.sessions - a.sessions)

      // Agrupar por empresa
      const companyMap = new Map()
      invoices.forEach(invoice => {
        const companyId = invoice.company_id
        const companyName = invoice.companies?.name || 'Unknown'
        
        if (!companyMap.has(companyId)) {
          companyMap.set(companyId, {
            companyId,
            companyName,
            sessions: 0,
            totalDuration: 0
          })
        }
        
        const company = companyMap.get(companyId)
        company.sessions += 1
        company.totalDuration += invoice.duration_minutes || 0
      })

      const usageByCompany = Array.from(companyMap.values())
        .sort((a, b) => b.sessions - a.sessions)

      // Agrupar por hora del día
      const hourMap = new Map()
      invoices.forEach(invoice => {
        const hour = new Date(invoice.created_at).getHours()
        
        if (!hourMap.has(hour)) {
          hourMap.set(hour, {
            hour,
            sessions: 0
          })
        }
        
        const hourData = hourMap.get(hour)
        hourData.sessions += 1
      })

      const peakHours = Array.from(hourMap.values())
        .sort((a, b) => b.sessions - a.sessions)
        .slice(0, 10) // Top 10 horas

      return {
        period: `${startDate} - ${endDate}`,
        totalSessions,
        averageSessionDuration,
        usageByZone,
        usageByCompany,
        peakHours
      }
    } catch (error) {
      console.error('Error generating usage report:', error)
      throw error
    }
  }

  /**
   * Obtiene estadísticas generales del sistema
   */
  static async getSystemStats(): Promise<SystemStats> {
    try {
      // Obtener estadísticas de empresas
      const { data: companies, error: companiesError } = await supabase
        .from('companies')
        .select('id, is_active')

      if (companiesError) {
        throw new Error(`Error fetching companies: ${companiesError.message}`)
      }

      const totalCompanies = companies?.length || 0
      const activeCompanies = companies?.filter(c => c.is_active).length || 0

      // Obtener estadísticas de zonas
      const { data: zones, error: zonesError } = await supabase
        .from('zones')
        .select('id, is_active')

      if (zonesError) {
        throw new Error(`Error fetching zones: ${zonesError.message}`)
      }

      const totalZones = zones?.length || 0
      const activeZones = zones?.filter(z => z.is_active).length || 0

      // Obtener estadísticas de operadores
      const { data: operators, error: operatorsError } = await supabase
        .from('operators')
        .select('id, is_active')

      if (operatorsError) {
        throw new Error(`Error fetching operators: ${operatorsError.message}`)
      }

      const totalOperators = operators?.length || 0
      const activeOperators = operators?.filter(o => o.is_active).length || 0

      // Obtener estadísticas de facturas
      const { data: invoices, error: invoicesError } = await supabase
        .from('invoices')
        .select('id, status, amount, created_at')

      if (invoicesError) {
        throw new Error(`Error fetching invoices: ${invoicesError.message}`)
      }

      const totalInvoices = invoices?.length || 0
      const pendingInvoices = invoices?.filter(i => i.status === 'pending').length || 0
      const completedInvoices = invoices?.filter(i => i.status === 'completed').length || 0
      const failedInvoices = invoices?.filter(i => i.status === 'failed').length || 0

      // Calcular ingresos
      const totalRevenue = invoices?.reduce((sum, invoice) => sum + (invoice.amount || 0), 0) || 0

      // Ingresos de hoy
      const today = new Date().toISOString().split('T')[0]
      const todayInvoices = invoices?.filter(i => i.created_at.startsWith(today)) || []
      const todayRevenue = todayInvoices.reduce((sum, invoice) => sum + (invoice.amount || 0), 0)

      // Ingresos del mes actual
      const currentMonth = new Date().toISOString().substring(0, 7)
      const monthlyInvoices = invoices?.filter(i => i.created_at.startsWith(currentMonth)) || []
      const monthlyRevenue = monthlyInvoices.reduce((sum, invoice) => sum + (invoice.amount || 0), 0)

      return {
        totalCompanies,
        activeCompanies,
        totalZones,
        activeZones,
        totalOperators,
        activeOperators,
        totalInvoices,
        pendingInvoices,
        completedInvoices,
        failedInvoices,
        totalRevenue,
        todayRevenue,
        monthlyRevenue
      }
    } catch (error) {
      console.error('Error fetching system stats:', error)
      throw error
    }
  }

  /**
   * Exporta datos a Excel/CSV
   */
  static async exportToCSV(
    data: any[],
    filename: string,
    headers: string[]
  ): Promise<void> {
    try {
      // Crear CSV content
      const csvContent = [
        headers.join(','),
        ...data.map(row => 
          headers.map(header => {
            const value = row[header] || ''
            // Escapar comillas y comas
            return typeof value === 'string' && (value.includes(',') || value.includes('"'))
              ? `"${value.replace(/"/g, '""')}"`
              : value
          }).join(',')
        )
      ].join('\n')

      // Crear y descargar archivo
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
      const link = document.createElement('a')
      const url = URL.createObjectURL(blob)
      
      link.setAttribute('href', url)
      link.setAttribute('download', `${filename}.csv`)
      link.style.visibility = 'hidden'
      
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Error exporting to CSV:', error)
      throw error
    }
  }
}
