import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { User } from '../services/auth.service'
import { CompaniesService } from '../services/companies.service'
import { Database } from '../config/supabase'
import { useRealtimeList } from '../hooks/useRealtime'

type Company = Database['public']['Tables']['companies']['Row']

interface CompaniesProps {
  user: User
  onLogout: () => void
}

export const Companies: React.FC<CompaniesProps> = ({ user, onLogout }) => {
  const [companies, setCompanies] = useState<Company[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editingCompany, setEditingCompany] = useState<Company | null>(null)
  const [formData, setFormData] = useState({
    name: '',
    primary_color: '#3B82F6',
    background_color: '#F3F4F6',
    contact_email: '',
    contact_phone: '',
    address: ''
  })

  const loadCompanies = async () => {
    try {
      setIsLoading(true)
      const data = await CompaniesService.getAll()
      setCompanies(data)
    } catch (error) {
      console.error('Error loading companies:', error)
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    loadCompanies()
  }, [])

  // Sincronización en tiempo real
  const { isConnected } = useRealtimeList('companies', loadCompanies)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (editingCompany) {
        await CompaniesService.update(editingCompany.id, formData)
      } else {
        await CompaniesService.create(formData)
      }
      setShowModal(false)
      setEditingCompany(null)
      resetForm()
      loadCompanies()
    } catch (error) {
      console.error('Error saving company:', error)
    }
  }

  const handleEdit = (company: Company) => {
    setEditingCompany(company)
    setFormData({
      name: company.name,
      primary_color: company.primary_color,
      background_color: company.background_color,
      contact_email: company.contact_email || '',
      contact_phone: company.contact_phone || '',
      address: company.address || ''
    })
    setShowModal(true)
  }

  const handleDelete = async (company: Company) => {
    if (window.confirm(`¿Estás seguro de que quieres eliminar la empresa "${company.name}"?`)) {
      try {
        await CompaniesService.delete(company.id)
        loadCompanies()
      } catch (error) {
        console.error('Error deleting company:', error)
      }
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      primary_color: '#3B82F6',
      background_color: '#F3F4F6',
      contact_email: '',
      contact_phone: '',
      address: ''
    })
  }

  const openCreateModal = () => {
    setEditingCompany(null)
    resetForm()
    setShowModal(true)
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
                <h1 className="text-3xl font-bold text-gray-900">Gestión de Empresas</h1>
                <div className="flex items-center space-x-2">
                  <p className="text-gray-600">Bienvenido, {user.username}</p>
                  <div className="flex items-center space-x-1">
                    <div className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`}></div>
                    <span className="text-xs text-gray-500">
                      {isConnected ? 'Tiempo real activo' : 'Sin conexión'}
                    </span>
                  </div>
                </div>
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
          {/* Actions */}
          <div className="mb-6 flex justify-between items-center">
            <h2 className="text-lg font-medium text-gray-900">Lista de Empresas</h2>
            <button
              onClick={openCreateModal}
              className="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md transition-colors"
            >
              Crear Empresa
            </button>
          </div>

          {/* Companies Table */}
          <div className="bg-white shadow overflow-hidden sm:rounded-md">
            <ul className="divide-y divide-gray-200">
              {companies.map((company) => (
                <li key={company.id}>
                  <div className="px-4 py-4 flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="flex-shrink-0">
                        {company.logo_url ? (
                          <img className="h-10 w-10 rounded-full" src={company.logo_url} alt={company.name} />
                        ) : (
                          <div 
                            className="h-10 w-10 rounded-full flex items-center justify-center text-white font-bold"
                            style={{ backgroundColor: company.primary_color }}
                          >
                            {company.name.charAt(0)}
                          </div>
                        )}
                      </div>
                      <div className="ml-4">
                        <div className="flex items-center">
                          <p className="text-sm font-medium text-gray-900">{company.name}</p>
                          <span className={`ml-2 inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            company.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                            {company.is_active ? 'Activa' : 'Inactiva'}
                          </span>
                        </div>
                        <div className="flex items-center mt-1">
                          <div 
                            className="w-4 h-4 rounded-full mr-2"
                            style={{ backgroundColor: company.primary_color }}
                          ></div>
                          <div 
                            className="w-4 h-4 rounded-full mr-2"
                            style={{ backgroundColor: company.background_color }}
                          ></div>
                          <p className="text-sm text-gray-500">{company.contact_email}</p>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => handleEdit(company)}
                        className="text-primary-600 hover:text-primary-900 text-sm font-medium"
                      >
                        Editar
                      </button>
                      <button
                        onClick={() => handleDelete(company)}
                        className="text-red-600 hover:text-red-900 text-sm font-medium"
                      >
                        Eliminar
                      </button>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                {editingCompany ? 'Editar Empresa' : 'Crear Empresa'}
              </h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Nombre</label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Color Principal</label>
                  <div className="mt-1 flex items-center space-x-2">
                    <input
                      type="color"
                      value={formData.primary_color}
                      onChange={(e) => setFormData({ ...formData, primary_color: e.target.value })}
                      className="h-10 w-20 border border-gray-300 rounded"
                    />
                    <input
                      type="text"
                      value={formData.primary_color}
                      onChange={(e) => setFormData({ ...formData, primary_color: e.target.value })}
                      className="flex-1 border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">Color de Fondo</label>
                  <div className="mt-1 flex items-center space-x-2">
                    <input
                      type="color"
                      value={formData.background_color}
                      onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
                      className="h-10 w-20 border border-gray-300 rounded"
                    />
                    <input
                      type="text"
                      value={formData.background_color}
                      onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
                      className="flex-1 border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">Email de Contacto</label>
                  <input
                    type="email"
                    value={formData.contact_email}
                    onChange={(e) => setFormData({ ...formData, contact_email: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">Teléfono</label>
                  <input
                    type="tel"
                    value={formData.contact_phone}
                    onChange={(e) => setFormData({ ...formData, contact_phone: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">Dirección</label>
                  <textarea
                    value={formData.address}
                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    rows={3}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                {/* Preview */}
                <div className="border rounded-md p-4 bg-gray-50">
                  <p className="text-sm font-medium text-gray-700 mb-2">Vista Previa:</p>
                  <div 
                    className="p-4 rounded-md text-white"
                    style={{ backgroundColor: formData.primary_color }}
                  >
                    <h4 className="font-bold">{formData.name || 'Nombre de la empresa'}</h4>
                    <p className="text-sm opacity-90">{formData.contact_email || 'email@empresa.com'}</p>
                  </div>
                </div>

                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
                  >
                    {editingCompany ? 'Actualizar' : 'Crear'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
