import React, { useState, useEffect } from 'react'
import { AnalyticsService, RevenueReport, UsageReport, SystemStats } from '../services/analytics.service'
import { CompaniesService } from '../services/companies.service'
import { useRealtimeStats } from '../hooks/useRealtime'

interface AnalyticsProps {}

const Analytics: React.FC<AnalyticsProps> = () => {
  const [systemStats, setSystemStats] = useState<SystemStats | null>(null)
  const [revenueReport, setRevenueReport] = useState<RevenueReport | null>(null)
  const [usageReport, setUsageReport] = useState<UsageReport | null>(null)
  const [companies, setCompanies] = useState<any[]>([])
  const [selectedCompany, setSelectedCompany] = useState<string>('')
  const [dateRange, setDateRange] = useState({
    start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    end: new Date().toISOString().split('T')[0]
  })
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'overview' | 'revenue' | 'usage'>('overview')

  // Cargar datos iniciales
  const loadSystemStats = async () => {
    try {
      const stats = await AnalyticsService.getSystemStats()
      setSystemStats(stats)
    } catch (error) {
      console.error('Error loading system stats:', error)
    }
  }

  const loadCompanies = async () => {
    try {
      const companiesData = await CompaniesService.getAll()
      setCompanies(companiesData)
    } catch (error) {
      console.error('Error loading companies:', error)
    }
  }

  const loadRevenueReport = async () => {
    if (!dateRange.start || !dateRange.end) return
    
    setLoading(true)
    try {
      const report = await AnalyticsService.getRevenueReport(
        dateRange.start,
        dateRange.end,
        selectedCompany || undefined
      )
      setRevenueReport(report)
    } catch (error) {
      console.error('Error loading revenue report:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadUsageReport = async () => {
    if (!dateRange.start || !dateRange.end) return
    
    setLoading(true)
    try {
      const report = await AnalyticsService.getUsageReport(
        dateRange.start,
        dateRange.end,
        selectedCompany || undefined
      )
      setUsageReport(report)
    } catch (error) {
      console.error('Error loading usage report:', error)
    } finally {
      setLoading(false)
    }
  }

  // Cargar datos al montar el componente
  useEffect(() => {
    loadSystemStats()
    loadCompanies()
  }, [])

  // Cargar reportes cuando cambien los filtros
  useEffect(() => {
    if (activeTab === 'revenue') {
      loadRevenueReport()
    } else if (activeTab === 'usage') {
      loadUsageReport()
    }
  }, [dateRange, selectedCompany, activeTab])

  // Sincronización en tiempo real
  useRealtimeStats(['companies', 'zones', 'operators', 'invoices'], loadSystemStats)

  const handleExportRevenue = async () => {
    if (!revenueReport) return
    
    try {
      const data = revenueReport.dailyRevenue.map(day => ({
        date: day.date,
        revenue: day.revenue,
        transactions: day.transactions
      }))
      
      await AnalyticsService.exportToCSV(
        data,
        `revenue-report-${dateRange.start}-to-${dateRange.end}`,
        ['date', 'revenue', 'transactions']
      )
    } catch (error) {
      console.error('Error exporting revenue data:', error)
    }
  }

  const handleExportUsage = async () => {
    if (!usageReport) return
    
    try {
      const data = usageReport.usageByZone.map(zone => ({
        zone: zone.zoneName,
        sessions: zone.sessions,
        totalDuration: zone.totalDuration,
        averageDuration: zone.averageDuration
      }))
      
      await AnalyticsService.exportToCSV(
        data,
        `usage-report-${dateRange.start}-to-${dateRange.end}`,
        ['zone', 'sessions', 'totalDuration', 'averageDuration']
      )
    } catch (error) {
      console.error('Error exporting usage data:', error)
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-ES', {
      style: 'currency',
      currency: 'EUR'
    }).format(amount)
  }

  const formatNumber = (num: number) => {
    return new Intl.NumberFormat('es-ES').format(num)
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Analytics y Reportes</h1>
        <p className="text-gray-600">Análisis detallado del rendimiento del sistema</p>
      </div>

      {/* Filtros */}
      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Empresa
            </label>
            <select
              value={selectedCompany}
              onChange={(e) => setSelectedCompany(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todas las empresas</option>
              {companies.map(company => (
                <option key={company.id} value={company.id}>
                  {company.name}
                </option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Fecha inicio
            </label>
            <input
              type="date"
              value={dateRange.start}
              onChange={(e) => setDateRange(prev => ({ ...prev, start: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Fecha fin
            </label>
            <input
              type="date"
              value={dateRange.end}
              onChange={(e) => setDateRange(prev => ({ ...prev, end: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white rounded-lg shadow mb-6">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 px-6">
            {[
              { id: 'overview', name: 'Resumen General' },
              { id: 'revenue', name: 'Reportes de Ingresos' },
              { id: 'usage', name: 'Reportes de Uso' }
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.name}
              </button>
            ))}
          </nav>
        </div>

        <div className="p-6">
          {activeTab === 'overview' && systemStats && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-blue-50 rounded-lg p-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                      <span className="text-white text-sm font-medium">€</span>
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-blue-600">Ingresos Totales</p>
                    <p className="text-2xl font-bold text-blue-900">
                      {formatCurrency(systemStats.totalRevenue)}
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-green-50 rounded-lg p-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                      <span className="text-white text-sm font-medium">€</span>
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-green-600">Ingresos Hoy</p>
                    <p className="text-2xl font-bold text-green-900">
                      {formatCurrency(systemStats.todayRevenue)}
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-purple-50 rounded-lg p-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                      <span className="text-white text-sm font-medium">📊</span>
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-purple-600">Facturas Completadas</p>
                    <p className="text-2xl font-bold text-purple-900">
                      {formatNumber(systemStats.completedInvoices)}
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-orange-50 rounded-lg p-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-orange-500 rounded-md flex items-center justify-center">
                      <span className="text-white text-sm font-medium">🏢</span>
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-orange-600">Empresas Activas</p>
                    <p className="text-2xl font-bold text-orange-900">
                      {formatNumber(systemStats.activeCompanies)}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'revenue' && (
            <div>
              {loading ? (
                <div className="text-center py-8">
                  <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
                  <p className="mt-2 text-gray-600">Cargando reporte de ingresos...</p>
                </div>
              ) : revenueReport ? (
                <div className="space-y-6">
                  <div className="flex justify-between items-center">
                    <h3 className="text-lg font-semibold">Reporte de Ingresos</h3>
                    <button
                      onClick={handleExportRevenue}
                      className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
                    >
                      Exportar CSV
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-sm text-gray-600">Ingresos Totales</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {formatCurrency(revenueReport.totalRevenue)}
                      </p>
                    </div>
                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-sm text-gray-600">Total Transacciones</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {formatNumber(revenueReport.totalTransactions)}
                      </p>
                    </div>
                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-sm text-gray-600">Valor Promedio</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {formatCurrency(revenueReport.averageTransactionValue)}
                      </p>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div>
                      <h4 className="text-md font-semibold mb-4">Ingresos por Empresa</h4>
                      <div className="space-y-2">
                        {revenueReport.revenueByCompany.slice(0, 5).map(company => (
                          <div key={company.companyId} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                            <span className="font-medium">{company.companyName}</span>
                            <span className="text-green-600 font-semibold">
                              {formatCurrency(company.revenue)}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="text-md font-semibold mb-4">Ingresos por Zona</h4>
                      <div className="space-y-2">
                        {revenueReport.revenueByZone.slice(0, 5).map(zone => (
                          <div key={zone.zoneId} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                            <span className="font-medium">{zone.zoneName}</span>
                            <span className="text-green-600 font-semibold">
                              {formatCurrency(zone.revenue)}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-center py-8 text-gray-500">
                  No hay datos de ingresos para el período seleccionado
                </div>
              )}
            </div>
          )}

          {activeTab === 'usage' && (
            <div>
              {loading ? (
                <div className="text-center py-8">
                  <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
                  <p className="mt-2 text-gray-600">Cargando reporte de uso...</p>
                </div>
              ) : usageReport ? (
                <div className="space-y-6">
                  <div className="flex justify-between items-center">
                    <h3 className="text-lg font-semibold">Reporte de Uso</h3>
                    <button
                      onClick={handleExportUsage}
                      className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
                    >
                      Exportar CSV
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-sm text-gray-600">Total Sesiones</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {formatNumber(usageReport.totalSessions)}
                      </p>
                    </div>
                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-sm text-gray-600">Duración Promedio</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {Math.round(usageReport.averageSessionDuration)} min
                      </p>
                    </div>
                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-sm text-gray-600">Período</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {usageReport.period}
                      </p>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div>
                      <h4 className="text-md font-semibold mb-4">Uso por Zona</h4>
                      <div className="space-y-2">
                        {usageReport.usageByZone.slice(0, 5).map(zone => (
                          <div key={zone.zoneId} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                            <div>
                              <span className="font-medium">{zone.zoneName}</span>
                              <p className="text-sm text-gray-600">
                                {formatNumber(zone.sessions)} sesiones
                              </p>
                            </div>
                            <span className="text-blue-600 font-semibold">
                              {Math.round(zone.averageDuration)} min
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="text-md font-semibold mb-4">Horas Pico</h4>
                      <div className="space-y-2">
                        {usageReport.peakHours.slice(0, 5).map(hour => (
                          <div key={hour.hour} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                            <span className="font-medium">{hour.hour}:00</span>
                            <span className="text-blue-600 font-semibold">
                              {formatNumber(hour.sessions)} sesiones
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-center py-8 text-gray-500">
                  No hay datos de uso para el período seleccionado
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default Analytics
