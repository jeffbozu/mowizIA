import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { User } from '../services/auth.service'
import { InvoicesService } from '../services/invoices.service'
import { CompaniesService } from '../services/companies.service'
import { Database } from '../config/supabase'

type Invoice = Database['public']['Tables']['invoices']['Row']
type Company = Database['public']['Tables']['companies']['Row']

interface InvoicesProps {
  user: User
  onLogout: () => void
}

const STATUS_COLORS = {
  pending: 'bg-yellow-100 text-yellow-800',
  completed: 'bg-green-100 text-green-800',
  failed: 'bg-red-100 text-red-800'
}

const STATUS_LABELS = {
  pending: 'Pendiente',
  completed: 'Completada',
  failed: 'Fallida'
}

export const Invoices: React.FC<InvoicesProps> = ({ user, onLogout }) => {
  const [invoices, setInvoices] = useState<Invoice[]>([])
  const [companies, setCompanies] = useState<Company[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [selectedInvoice, setSelectedInvoice] = useState<Invoice | null>(null)
  const [filters, setFilters] = useState({
    status: '',
    company: '',
    dateFrom: '',
    dateTo: '',
    search: ''
  })
  const [stats, setStats] = useState({
    total: 0,
    pending: 0,
    completed: 0,
    failed: 0,
    totalAmount: 0,
    completedAmount: 0
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setIsLoading(true)
      const [invoicesData, companiesData, statsData] = await Promise.all([
        InvoicesService.getAll(),
        CompaniesService.getAll(),
        InvoicesService.getStats()
      ])
      setInvoices(invoicesData)
      setCompanies(companiesData)
      setStats({
        total: statsData.totalInvoices || 0,
        pending: statsData.pendingInvoices || 0,
        completed: statsData.completedInvoices || 0,
        failed: statsData.failedInvoices || 0,
        totalAmount: statsData.totalAmount || 0,
        completedAmount: statsData.completedAmount || 0
      })
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleViewDetails = (invoice: Invoice) => {
    setSelectedInvoice(invoice)
    setShowModal(true)
  }

  const handleDownloadPDF = async (invoice: Invoice) => {
    if (invoice.invoice_pdf_url) {
      try {
        // Crear enlace de descarga
        const link = document.createElement('a')
        link.href = invoice.invoice_pdf_url
        link.download = `factura_${invoice.ticket_id}.pdf`
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
      } catch (error) {
        console.error('Error downloading PDF:', error)
        alert('Error al descargar el PDF')
      }
    } else {
      alert('No hay PDF disponible para esta factura')
    }
  }

  const handleRegenerateInvoice = async (invoice: Invoice) => {
    if (window.confirm('¿Estás seguro de que quieres regenerar esta factura?')) {
      try {
        // Aquí se llamaría a la Edge Function para regenerar el PDF
        // Por ahora solo actualizamos el estado
        await InvoicesService.update(invoice.id, { status: 'pending' })
        loadData()
        alert('Factura marcada para regeneración')
      } catch (error) {
        console.error('Error regenerating invoice:', error)
        alert('Error al regenerar la factura')
      }
    }
  }

  const filteredInvoices = invoices.filter(invoice => {
    const statusMatch = !filters.status || invoice.status === filters.status
    const companyMatch = !filters.company || invoice.company_id === filters.company
    const searchMatch = !filters.search || 
      invoice.ticket_id.toLowerCase().includes(filters.search.toLowerCase()) ||
      invoice.plate.toLowerCase().includes(filters.search.toLowerCase()) ||
      (invoice.fiscal_name && invoice.fiscal_name.toLowerCase().includes(filters.search.toLowerCase()))
    
    let dateMatch = true
    if (filters.dateFrom || filters.dateTo) {
      const invoiceDate = new Date(invoice.created_at)
      if (filters.dateFrom) {
        const fromDate = new Date(filters.dateFrom)
        dateMatch = dateMatch && invoiceDate >= fromDate
      }
      if (filters.dateTo) {
        const toDate = new Date(filters.dateTo)
        toDate.setHours(23, 59, 59, 999) // Incluir todo el día
        dateMatch = dateMatch && invoiceDate <= toDate
      }
    }
    
    return statusMatch && companyMatch && searchMatch && dateMatch
  })

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-ES', {
      style: 'currency',
      currency: 'EUR'
    }).format(amount)
  }

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
            <div className="flex items-center space-x-4">
              <Link to="/" className="text-primary-600 hover:text-primary-700">
                <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
              </Link>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Gestión de Facturas</h1>
                <p className="text-gray-600">Bienvenido, {user.username}</p>
              </div>
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
          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                      <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">Total Facturas</dt>
                      <dd className="text-lg font-medium text-gray-900">{stats.total}</dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                      <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">Completadas</dt>
                      <dd className="text-lg font-medium text-gray-900">{stats.completed}</dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                      <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">Pendientes</dt>
                      <dd className="text-lg font-medium text-gray-900">{stats.pending}</dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                      <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                      </svg>
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">Ingresos</dt>
                      <dd className="text-lg font-medium text-gray-900">{formatCurrency(stats.completedAmount)}</dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Filters */}
          <div className="mb-6 bg-white p-4 rounded-lg shadow">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Buscar</label>
                <input
                  type="text"
                  placeholder="Ticket, matrícula, nombre..."
                  value={filters.search}
                  onChange={(e) => setFilters({ ...filters, search: e.target.value })}
                  className="w-full border border-gray-300 rounded-md px-3 py-2"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Estado</label>
                <select
                  value={filters.status}
                  onChange={(e) => setFilters({ ...filters, status: e.target.value })}
                  className="w-full border border-gray-300 rounded-md px-3 py-2"
                >
                  <option value="">Todos los estados</option>
                  <option value="pending">Pendiente</option>
                  <option value="completed">Completada</option>
                  <option value="failed">Fallida</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Empresa</label>
                <select
                  value={filters.company}
                  onChange={(e) => setFilters({ ...filters, company: e.target.value })}
                  className="w-full border border-gray-300 rounded-md px-3 py-2"
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
                <label className="block text-sm font-medium text-gray-700 mb-1">Desde</label>
                <input
                  type="date"
                  value={filters.dateFrom}
                  onChange={(e) => setFilters({ ...filters, dateFrom: e.target.value })}
                  className="w-full border border-gray-300 rounded-md px-3 py-2"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Hasta</label>
                <input
                  type="date"
                  value={filters.dateTo}
                  onChange={(e) => setFilters({ ...filters, dateTo: e.target.value })}
                  className="w-full border border-gray-300 rounded-md px-3 py-2"
                />
              </div>
            </div>
          </div>

          {/* Invoices Table */}
          <div className="bg-white shadow overflow-hidden sm:rounded-md">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Ticket ID
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Matrícula
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Cliente
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Importe
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Estado
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Fecha
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Acciones
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredInvoices.map((invoice) => (
                    <tr key={invoice.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <code className="text-sm bg-gray-100 px-2 py-1 rounded text-gray-800">
                          {invoice.ticket_id}
                        </code>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="text-sm font-medium text-gray-900">{invoice.plate}</span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {invoice.fiscal_name || 'Sin datos fiscales'}
                        </div>
                        {invoice.fiscal_nif && (
                          <div className="text-sm text-gray-500">{invoice.fiscal_nif}</div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="text-sm font-medium text-gray-900">
                          {formatCurrency(invoice.amount)}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          STATUS_COLORS[invoice.status as keyof typeof STATUS_COLORS] || 'bg-gray-100 text-gray-800'
                        }`}>
                          {STATUS_LABELS[invoice.status as keyof typeof STATUS_LABELS] || invoice.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="text-sm text-gray-900">
                          {formatDate(invoice.created_at)}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handleViewDetails(invoice)}
                            className="text-primary-600 hover:text-primary-900"
                          >
                            Ver
                          </button>
                          {invoice.invoice_pdf_url && (
                            <button
                              onClick={() => handleDownloadPDF(invoice)}
                              className="text-green-600 hover:text-green-900"
                            >
                              PDF
                            </button>
                          )}
                          {invoice.status === 'failed' && (
                            <button
                              onClick={() => handleRegenerateInvoice(invoice)}
                              className="text-yellow-600 hover:text-yellow-900"
                            >
                              Regenerar
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      {/* Modal */}
      {showModal && selectedInvoice && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Detalles de la Factura
              </h3>
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Ticket ID</label>
                    <p className="text-sm text-gray-900">{selectedInvoice.ticket_id}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Matrícula</label>
                    <p className="text-sm text-gray-900">{selectedInvoice.plate}</p>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Importe</label>
                    <p className="text-sm text-gray-900">{formatCurrency(selectedInvoice.amount)}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Estado</label>
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      STATUS_COLORS[selectedInvoice.status as keyof typeof STATUS_COLORS] || 'bg-gray-100 text-gray-800'
                    }`}>
                      {STATUS_LABELS[selectedInvoice.status as keyof typeof STATUS_LABELS] || selectedInvoice.status}
                    </span>
                  </div>
                </div>

                {selectedInvoice.fiscal_name && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Datos Fiscales</label>
                    <div className="mt-1 text-sm text-gray-900">
                      <p><strong>Nombre:</strong> {selectedInvoice.fiscal_name}</p>
                      {selectedInvoice.fiscal_nif && <p><strong>NIF:</strong> {selectedInvoice.fiscal_nif}</p>}
                      {selectedInvoice.fiscal_address && <p><strong>Dirección:</strong> {selectedInvoice.fiscal_address}</p>}
                      {selectedInvoice.fiscal_city && <p><strong>Ciudad:</strong> {selectedInvoice.fiscal_city}</p>}
                      {selectedInvoice.fiscal_email && <p><strong>Email:</strong> {selectedInvoice.fiscal_email}</p>}
                    </div>
                  </div>
                )}

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Fecha de Creación</label>
                    <p className="text-sm text-gray-900">{formatDate(selectedInvoice.created_at)}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Duración</label>
                    <p className="text-sm text-gray-900">{selectedInvoice.duration_minutes} minutos</p>
                  </div>
                </div>

                {selectedInvoice.invoice_pdf_url && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700">PDF</label>
                    <a
                      href={selectedInvoice.invoice_pdf_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary-600 hover:text-primary-900 text-sm"
                    >
                      Ver PDF
                    </a>
                  </div>
                )}
              </div>

              <div className="flex justify-end space-x-3 pt-4">
                <button
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
                >
                  Cerrar
                </button>
                {selectedInvoice.invoice_pdf_url && (
                  <button
                    onClick={() => handleDownloadPDF(selectedInvoice)}
                    className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
                  >
                    Descargar PDF
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
