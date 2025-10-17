import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { User } from '../services/auth.service'
import { ZonesService } from '../services/zones.service'
import { CompaniesService } from '../services/companies.service'
import { Database } from '../config/supabase'
import { useRealtimeList } from '../hooks/useRealtime'

type Zone = Database['public']['Tables']['zones']['Row']
type Company = Database['public']['Tables']['companies']['Row']

interface ZonesProps {
  user: User
  onLogout: () => void
}

export const Zones: React.FC<ZonesProps> = ({ user, onLogout }) => {
  const [zones, setZones] = useState<Zone[]>([])
  const [companies, setCompanies] = useState<Company[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editingZone, setEditingZone] = useState<Zone | null>(null)
  const [selectedCompany, setSelectedCompany] = useState<string>('')
  const [formData, setFormData] = useState({
    name: '',
    company_id: '',
    price_per_hour: 0,
    time_options: [15, 30, 60, 120, 180, 240],
    time_increment: 15,
    min_time: 15,
    max_duration: 480,
    color: '#3B82F6',
    is_active: true
  })

  const loadData = async () => {
    try {
      setIsLoading(true)
      const [zonesData, companiesData] = await Promise.all([
        ZonesService.getAll(),
        CompaniesService.getAll()
      ])
      setZones(zonesData)
      setCompanies(companiesData)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  // Sincronización en tiempo real
  useRealtimeList('zones', loadData)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (editingZone) {
        await ZonesService.update(editingZone.id, formData)
      } else {
        await ZonesService.create(formData)
      }
      setShowModal(false)
      setEditingZone(null)
      resetForm()
      loadData()
    } catch (error) {
      console.error('Error saving zone:', error)
    }
  }

  const handleEdit = (zone: Zone) => {
    setEditingZone(zone)
    setFormData({
      name: zone.name,
      company_id: zone.company_id,
      price_per_hour: zone.price_per_hour,
      time_options: zone.time_options || [15, 30, 60, 120, 180, 240],
      time_increment: zone.time_increment || 15,
      min_time: zone.min_time || 15,
      max_duration: zone.max_duration || 480,
      color: zone.color || '#3B82F6',
      is_active: zone.is_active
    })
    setShowModal(true)
  }

  const handleDelete = async (zone: Zone) => {
    if (window.confirm(`¿Estás seguro de que quieres eliminar la zona "${zone.name}"?`)) {
      try {
        await ZonesService.delete(zone.id)
        loadData()
      } catch (error) {
        console.error('Error deleting zone:', error)
      }
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      company_id: '',
      price_per_hour: 0,
      time_options: [15, 30, 60, 120, 180, 240],
      time_increment: 15,
      min_time: 15,
      max_duration: 480,
      color: '#3B82F6',
      is_active: true
    })
  }

  const openCreateModal = () => {
    setEditingZone(null)
    resetForm()
    setShowModal(true)
  }

  const addTimeOption = () => {
    const newOption = parseInt(prompt('Introduce minutos (ej: 90):') || '0')
    if (newOption > 0 && !formData.time_options.includes(newOption)) {
      setFormData({
        ...formData,
        time_options: [...formData.time_options, newOption].sort((a, b) => a - b)
      })
    }
  }

  const removeTimeOption = (option: number) => {
    setFormData({
      ...formData,
      time_options: formData.time_options.filter(o => o !== option)
    })
  }

  const calculatePrice = (minutes: number) => {
    const hours = minutes / 60
    return (hours * formData.price_per_hour).toFixed(2)
  }

  const filteredZones = selectedCompany 
    ? zones.filter(zone => zone.company_id === selectedCompany)
    : zones

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
                <h1 className="text-3xl font-bold text-gray-900">Gestión de Zonas</h1>
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
          {/* Filters */}
          <div className="mb-6 flex justify-between items-center">
            <div className="flex items-center space-x-4">
              <h2 className="text-lg font-medium text-gray-900">Lista de Zonas</h2>
              <select
                value={selectedCompany}
                onChange={(e) => setSelectedCompany(e.target.value)}
                className="border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="">Todas las empresas</option>
                {companies.map(company => (
                  <option key={company.id} value={company.id}>
                    {company.name}
                  </option>
                ))}
              </select>
            </div>
            <button
              onClick={openCreateModal}
              className="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md transition-colors"
            >
              Crear Zona
            </button>
          </div>

          {/* Zones Table */}
          <div className="bg-white shadow overflow-hidden sm:rounded-md">
            <ul className="divide-y divide-gray-200">
              {filteredZones.map((zone) => (
                <li key={zone.id}>
                  <div className="px-4 py-4 flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="flex-shrink-0">
                        <div 
                          className="h-10 w-10 rounded-full flex items-center justify-center text-white font-bold"
                          style={{ backgroundColor: zone.color }}
                        >
                          {zone.name.charAt(0)}
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="flex items-center">
                          <p className="text-sm font-medium text-gray-900">{zone.name}</p>
                          <span className={`ml-2 inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            zone.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                            {zone.is_active ? 'Activa' : 'Inactiva'}
                          </span>
                        </div>
                        <div className="flex items-center mt-1">
                          <p className="text-sm text-gray-500">
                            {companies.find(c => c.id === zone.company_id)?.name || 'Sin empresa'}
                          </p>
                          <span className="mx-2">•</span>
                          <p className="text-sm text-gray-500">
                            {zone.price_per_hour.toFixed(2)}€/hora
                          </p>
                          <span className="mx-2">•</span>
                          <p className="text-sm text-gray-500">
                            {zone.time_options?.length || 0} opciones de tiempo
                          </p>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => handleEdit(zone)}
                        className="text-primary-600 hover:text-primary-900 text-sm font-medium"
                      >
                        Editar
                      </button>
                      <button
                        onClick={() => handleDelete(zone)}
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
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                {editingZone ? 'Editar Zona' : 'Crear Zona'}
              </h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
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
                    <label className="block text-sm font-medium text-gray-700">Empresa</label>
                    <select
                      required
                      value={formData.company_id}
                      onChange={(e) => setFormData({ ...formData, company_id: e.target.value })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    >
                      <option value="">Seleccionar empresa</option>
                      {companies.map(company => (
                        <option key={company.id} value={company.id}>
                          {company.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Precio por Hora (€)</label>
                    <input
                      type="number"
                      step="0.01"
                      min="0"
                      required
                      value={formData.price_per_hour}
                      onChange={(e) => setFormData({ ...formData, price_per_hour: parseFloat(e.target.value) })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700">Color</label>
                    <div className="mt-1 flex items-center space-x-2">
                      <input
                        type="color"
                        value={formData.color}
                        onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                        className="h-10 w-20 border border-gray-300 rounded"
                      />
                      <input
                        type="text"
                        value={formData.color}
                        onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                        className="flex-1 border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Tiempo Mínimo (min)</label>
                    <input
                      type="number"
                      min="1"
                      required
                      value={formData.min_time}
                      onChange={(e) => setFormData({ ...formData, min_time: parseInt(e.target.value) })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700">Incremento (min)</label>
                    <input
                      type="number"
                      min="1"
                      required
                      value={formData.time_increment}
                      onChange={(e) => setFormData({ ...formData, time_increment: parseInt(e.target.value) })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700">Duración Máxima (min)</label>
                    <input
                      type="number"
                      min="1"
                      required
                      value={formData.max_duration}
                      onChange={(e) => setFormData({ ...formData, max_duration: parseInt(e.target.value) })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>
                </div>

                {/* Time Options */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Opciones de Tiempo (minutos)</label>
                  <div className="flex flex-wrap gap-2 mb-2">
                    {formData.time_options.map(option => (
                      <span
                        key={option}
                        className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-primary-100 text-primary-800"
                      >
                        {option} min
                        <button
                          type="button"
                          onClick={() => removeTimeOption(option)}
                          className="ml-2 text-primary-600 hover:text-primary-800"
                        >
                          ×
                        </button>
                      </span>
                    ))}
                  </div>
                  <button
                    type="button"
                    onClick={addTimeOption}
                    className="text-primary-600 hover:text-primary-800 text-sm font-medium"
                  >
                    + Añadir opción
                  </button>
                </div>

                {/* Price Preview */}
                <div className="border rounded-md p-4 bg-gray-50">
                  <p className="text-sm font-medium text-gray-700 mb-2">Vista Previa de Precios:</p>
                  <div className="grid grid-cols-3 gap-2 text-sm">
                    {formData.time_options.slice(0, 6).map(minutes => (
                      <div key={minutes} className="flex justify-between">
                        <span>{minutes} min:</span>
                        <span className="font-medium">{calculatePrice(minutes)}€</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="is_active"
                    checked={formData.is_active}
                    onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                  />
                  <label htmlFor="is_active" className="ml-2 block text-sm text-gray-900">
                    Zona activa
                  </label>
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
                    {editingZone ? 'Actualizar' : 'Crear'}
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
