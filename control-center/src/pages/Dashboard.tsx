import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { User } from '../services/auth.service'
import { CompaniesService } from '../services/companies.service'
import { ZonesService } from '../services/zones.service'
import { OperatorsService } from '../services/operators.service'
import { InvoicesService } from '../services/invoices.service'
import { useRealtimeStats } from '../hooks/useRealtime'

interface DashboardProps {
  user: User
  onLogout: () => void
}

interface DashboardStats {
  companies: {
    total: number
    active: number
    inactive: number
  }
  zones: {
    total: number
    active: number
    inactive: number
    averagePrice: number
  }
  operators: {
    total: number
    active: number
    inactive: number
    byRole: Record<string, number>
  }
  invoices: {
    total: number
    pending: number
    completed: number
    failed: number
    totalAmount: number
    completedAmount: number
  }
}

export const Dashboard: React.FC<DashboardProps> = ({ user, onLogout }) => {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [recentInvoices, setRecentInvoices] = useState<any[]>([])

  const loadDashboardData = async () => {
    try {
      setIsLoading(true)
      
      const [companiesStats, zonesStats, operatorsStats, invoicesStats, recentInvoicesData] = await Promise.all([
        CompaniesService.getStats(),
        ZonesService.getStats(),
        OperatorsService.getStats(),
        InvoicesService.getStats(),
        InvoicesService.getRecentInvoices(5)
      ])

      setStats({
        companies: {
          total: companiesStats.totalCompanies || 0,
          active: companiesStats.activeCompanies || 0,
          inactive: companiesStats.inactiveCompanies || 0
        },
        zones: {
          total: zonesStats.totalZones || 0,
          active: zonesStats.activeZones || 0,
          inactive: zonesStats.inactiveZones || 0,
          averagePrice: zonesStats.averagePrice || 0
        },
        operators: {
          total: operatorsStats.totalOperators || 0,
          active: operatorsStats.activeOperators || 0,
          inactive: operatorsStats.inactiveOperators || 0,
          byRole: operatorsStats.operatorsByRole || {}
        },
        invoices: {
          total: invoicesStats.totalInvoices || 0,
          pending: invoicesStats.pendingInvoices || 0,
          completed: invoicesStats.completedInvoices || 0,
          failed: invoicesStats.failedInvoices || 0,
          totalAmount: invoicesStats.totalAmount || 0,
          completedAmount: invoicesStats.completedAmount || 0
        }
      })
      
      setRecentInvoices(recentInvoicesData)
    } catch (error) {
      console.error('Error loading dashboard data:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const StatCard: React.FC<{ title: string; value: string | number; subtitle?: string; color: string }> = ({ title, value, subtitle, color }) => (
    <div className="bg-white overflow-hidden shadow rounded-lg">
      <div className="p-5">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <div className={`w-8 h-8 rounded-md flex items-center justify-center ${color}`}>
              <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
            </div>
          </div>
          <div className="ml-5 w-0 flex-1">
            <dl>
              <dt className="text-sm font-medium text-gray-500 truncate">{title}</dt>
              <dd className="text-lg font-medium text-gray-900">{value}</dd>
              {subtitle && <dd className="text-sm text-gray-500">{subtitle}</dd>}
            </dl>
          </div>
        </div>
      </div>
    </div>
  )

  const QuickActionCard: React.FC<{ title: string; description: string; href: string; icon: string; color: string }> = ({ title, description, href, icon, color }) => (
    <Link to={href} className="block bg-white overflow-hidden shadow rounded-lg hover:shadow-md transition-shadow">
      <div className="p-5">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <div className={`w-10 h-10 rounded-md flex items-center justify-center ${color}`}>
              <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={icon} />
              </svg>
            </div>
          </div>
          <div className="ml-4">
            <h3 className="text-lg font-medium text-gray-900">{title}</h3>
            <p className="text-sm text-gray-500">{description}</p>
          </div>
        </div>
      </div>
    </Link>
  )

  useEffect(() => {
    loadDashboardData()
  }, [])

  // Sincronización en tiempo real para estadísticas
  useRealtimeStats(
    ['companies', 'zones', 'operators', 'invoices'],
    loadDashboardData
  )

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Centro de Control MEYPARK</h1>
              <p className="text-gray-600">Bienvenido, {user.username} ({user.role})</p>
            </div>
            <button
              onClick={onLogout}
              className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md transition-colors"
            >
              Cerrar Sesión
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          {/* Stats Grid */}
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
            <StatCard
              title="Empresas"
              value={stats?.companies.total || 0}
              subtitle={`${stats?.companies.active || 0} activas`}
              color="bg-blue-500"
            />
            <StatCard
              title="Zonas"
              value={stats?.zones.total || 0}
              subtitle={`${stats?.zones.averagePrice.toFixed(2)}€ precio promedio`}
              color="bg-green-500"
            />
            <StatCard
              title="Operadores"
              value={stats?.operators.total || 0}
              subtitle={`${stats?.operators.active || 0} activos`}
              color="bg-purple-500"
            />
            <StatCard
              title="Facturas"
              value={stats?.invoices.total || 0}
              subtitle={`${stats?.invoices.completedAmount.toFixed(2)}€ facturado`}
              color="bg-orange-500"
            />
          </div>

          {/* Quick Actions */}
          <div className="mb-8">
            <h2 className="text-lg font-medium text-gray-900 mb-4">Acciones Rápidas</h2>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
              <QuickActionCard
                title="Gestión de Empresas"
                description="Administrar empresas y configuraciones"
                href="/companies"
                icon="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
                color="bg-blue-500"
              />
              <QuickActionCard
                title="Gestión de Zonas"
                description="Configurar zonas y tarifas"
                href="/zones"
                icon="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                color="bg-green-500"
              />
              <QuickActionCard
                title="Gestión de Operadores"
                description="Administrar usuarios y permisos"
                href="/operators"
                icon="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"
                color="bg-purple-500"
              />
              <QuickActionCard
                title="Textos UI"
                description="Gestionar textos multiidioma"
                href="/ui-texts"
                icon="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"
                color="bg-yellow-500"
              />
              <QuickActionCard
                title="Gestión de Facturas"
                description="Ver y administrar facturas"
                href="/invoices"
                icon="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                color="bg-orange-500"
              />
              <QuickActionCard
                title="Analytics y Reportes"
                description="Análisis detallado del rendimiento"
                href="/analytics"
                icon="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                color="bg-indigo-500"
              />
              <QuickActionCard
                title="Configuración"
                description="Ajustes del sistema"
                href="/settings"
                icon="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                color="bg-gray-500"
              />
            </div>
          </div>

          {/* Recent Invoices */}
          <div className="bg-white shadow rounded-lg">
            <div className="px-4 py-5 sm:p-6">
              <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">Facturas Recientes</h3>
              {recentInvoices.length > 0 ? (
                <div className="overflow-hidden">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ticket ID</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Matrícula</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Importe</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {recentInvoices.map((invoice) => (
                        <tr key={invoice.id}>
                          <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            {invoice.ticket_id}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {invoice.plate}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {invoice.amount.toFixed(2)}€
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${InvoicesService.getStatusColor(invoice.status)}`}>
                              {InvoicesService.getStatusDisplayName(invoice.status)}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {new Date(invoice.created_at).toLocaleDateString('es-ES')}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <p className="text-gray-500 text-center py-4">No hay facturas recientes</p>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
