import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { User } from '../services/auth.service'
import { UITextsService } from '../services/ui-texts.service'
import { CompaniesService } from '../services/companies.service'
import { Database } from '../config/supabase'

type UIText = Database['public']['Tables']['ui_texts']['Row']
type Company = Database['public']['Tables']['companies']['Row']

interface UITextsProps {
  user: User
  onLogout: () => void
}

const LANGUAGES = [
  { code: 'es-ES', name: 'Español (España)', flag: '🇪🇸' },
  { code: 'en-US', name: 'English (US)', flag: '🇺🇸' },
  { code: 'ca-ES', name: 'Català', flag: '🇪🇸' },
  { code: 'fr-FR', name: 'Français', flag: '🇫🇷' },
  { code: 'de-DE', name: 'Deutsch', flag: '🇩🇪' }
]

const SCREENS = [
  'login', 'home', 'zone_selection', 'payment', 'ticket', 'extend', 
  'settings', 'profile', 'help', 'error', 'success', 'loading'
]

export const UITexts: React.FC<UITextsProps> = ({ user, onLogout }) => {
  const [texts, setTexts] = useState<UIText[]>([])
  const [companies, setCompanies] = useState<Company[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editingText, setEditingText] = useState<UIText | null>(null)
  const [filters, setFilters] = useState({
    screen: '',
    language: '',
    company: '',
    search: ''
  })
  const [formData, setFormData] = useState({
    screen_name: '',
    text_key: '',
    text_value: '',
    language: 'es-ES',
    company_id: '',
    is_active: true
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setIsLoading(true)
      const [textsData, companiesData] = await Promise.all([
        UITextsService.getAll(),
        CompaniesService.getAll()
      ])
      setTexts(textsData)
      setCompanies(companiesData)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (editingText) {
        await UITextsService.update(editingText.id, formData)
      } else {
        await UITextsService.create(formData)
      }
      setShowModal(false)
      setEditingText(null)
      resetForm()
      loadData()
    } catch (error) {
      console.error('Error saving text:', error)
    }
  }

  const handleEdit = (text: UIText) => {
    setEditingText(text)
    setFormData({
      screen_name: text.screen_name,
      text_key: text.text_key,
      text_value: text.text_value,
      language: text.language,
      company_id: text.company_id || '',
      is_active: true // Campo no existe en la tabla, usar valor por defecto
    })
    setShowModal(true)
  }

  const handleDelete = async (text: UIText) => {
    if (window.confirm(`¿Estás seguro de que quieres eliminar el texto "${text.text_key}"?`)) {
      try {
        await UITextsService.delete(text.id)
        loadData()
      } catch (error) {
        console.error('Error deleting text:', error)
      }
    }
  }

  const resetForm = () => {
    setFormData({
      screen_name: '',
      text_key: '',
      text_value: '',
      language: 'es-ES',
      company_id: '',
      is_active: true
    })
  }

  const openCreateModal = () => {
    setEditingText(null)
    resetForm()
    setShowModal(true)
  }

  const filteredTexts = texts.filter(text => {
    const screenMatch = !filters.screen || text.screen_name === filters.screen
    const languageMatch = !filters.language || text.language === filters.language
    const companyMatch = !filters.company || text.company_id === filters.company
    const searchMatch = !filters.search || 
      text.text_key.toLowerCase().includes(filters.search.toLowerCase()) ||
      text.text_value.toLowerCase().includes(filters.search.toLowerCase())
    
    return screenMatch && languageMatch && companyMatch && searchMatch
  })

  const getLanguageInfo = (code: string) => {
    return LANGUAGES.find(lang => lang.code === code) || { code, name: code, flag: '🌐' }
  }

  const getScreenDisplayName = (screen: string) => {
    const screenNames: Record<string, string> = {
      'login': 'Inicio de Sesión',
      'home': 'Pantalla Principal',
      'zone_selection': 'Selección de Zona',
      'payment': 'Pago',
      'ticket': 'Ticket',
      'extend': 'Extender Tiempo',
      'settings': 'Configuración',
      'profile': 'Perfil',
      'help': 'Ayuda',
      'error': 'Error',
      'success': 'Éxito',
      'loading': 'Cargando'
    }
    return screenNames[screen] || screen
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
                <h1 className="text-3xl font-bold text-gray-900">Gestión de Textos UI</h1>
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
              <h2 className="text-lg font-medium text-gray-900">Lista de Textos</h2>
              <input
                type="text"
                placeholder="Buscar texto..."
                value={filters.search}
                onChange={(e) => setFilters({ ...filters, search: e.target.value })}
                className="border border-gray-300 rounded-md px-3 py-2 w-64"
              />
              <select
                value={filters.screen}
                onChange={(e) => setFilters({ ...filters, screen: e.target.value })}
                className="border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="">Todas las pantallas</option>
                {SCREENS.map(screen => (
                  <option key={screen} value={screen}>
                    {getScreenDisplayName(screen)}
                  </option>
                ))}
              </select>
              <select
                value={filters.language}
                onChange={(e) => setFilters({ ...filters, language: e.target.value })}
                className="border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="">Todos los idiomas</option>
                {LANGUAGES.map(lang => (
                  <option key={lang.code} value={lang.code}>
                    {lang.flag} {lang.name}
                  </option>
                ))}
              </select>
              <select
                value={filters.company}
                onChange={(e) => setFilters({ ...filters, company: e.target.value })}
                className="border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="">Todas las empresas</option>
                <option value="global">Global</option>
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
              Crear Texto
            </button>
          </div>

          {/* Texts Table */}
          <div className="bg-white shadow overflow-hidden sm:rounded-md">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Pantalla
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Clave
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Texto
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Idioma
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Empresa
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Estado
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Acciones
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredTexts.map((text) => {
                    const langInfo = getLanguageInfo(text.language)
                    const companyName = text.company_id 
                      ? companies.find(c => c.id === text.company_id)?.name || 'Desconocida'
                      : 'Global'
                    
                    return (
                      <tr key={text.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="text-sm font-medium text-gray-900">
                            {getScreenDisplayName(text.screen_name)}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <code className="text-sm bg-gray-100 px-2 py-1 rounded text-gray-800">
                            {text.text_key}
                          </code>
                        </td>
                        <td className="px-6 py-4">
                          <div className="text-sm text-gray-900 max-w-xs truncate" title={text.text_value}>
                            {text.text_value}
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="text-sm text-gray-900">
                            {langInfo.flag} {langInfo.name}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="text-sm text-gray-900">{companyName}</span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                            Activo
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          <button
                            onClick={() => handleEdit(text)}
                            className="text-primary-600 hover:text-primary-900 mr-3"
                          >
                            Editar
                          </button>
                          <button
                            onClick={() => handleDelete(text)}
                            className="text-red-600 hover:text-red-900"
                          >
                            Eliminar
                          </button>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                {editingText ? 'Editar Texto UI' : 'Crear Texto UI'}
              </h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Pantalla</label>
                    <select
                      required
                      value={formData.screen_name}
                      onChange={(e) => setFormData({ ...formData, screen_name: e.target.value })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    >
                      <option value="">Seleccionar pantalla</option>
                      {SCREENS.map(screen => (
                        <option key={screen} value={screen}>
                          {getScreenDisplayName(screen)}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Clave del Texto</label>
                    <input
                      type="text"
                      required
                      placeholder="ej: button_pay, title_welcome"
                      value={formData.text_key}
                      onChange={(e) => setFormData({ ...formData, text_key: e.target.value })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">Texto</label>
                  <textarea
                    required
                    rows={3}
                    placeholder="Texto que se mostrará en la interfaz"
                    value={formData.text_value}
                    onChange={(e) => setFormData({ ...formData, text_value: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Idioma</label>
                    <select
                      required
                      value={formData.language}
                      onChange={(e) => setFormData({ ...formData, language: e.target.value })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    >
                      {LANGUAGES.map(lang => (
                        <option key={lang.code} value={lang.code}>
                          {lang.flag} {lang.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700">Empresa</label>
                    <select
                      value={formData.company_id}
                      onChange={(e) => setFormData({ ...formData, company_id: e.target.value })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    >
                      <option value="">Global (todas las empresas)</option>
                      {companies.map(company => (
                        <option key={company.id} value={company.id}>
                          {company.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Preview */}
                <div className="border rounded-md p-4 bg-gray-50">
                  <p className="text-sm font-medium text-gray-700 mb-2">Vista Previa:</p>
                  <div className="text-sm">
                    <p><strong>Pantalla:</strong> {getScreenDisplayName(formData.screen_name) || 'Seleccionar pantalla'}</p>
                    <p><strong>Clave:</strong> <code className="bg-gray-200 px-1 rounded">{formData.text_key || 'clave_del_texto'}</code></p>
                    <p><strong>Idioma:</strong> {getLanguageInfo(formData.language).flag} {getLanguageInfo(formData.language).name}</p>
                    <p><strong>Texto:</strong> {formData.text_value || 'Texto de ejemplo'}</p>
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
                    Texto activo
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
                    {editingText ? 'Actualizar' : 'Crear'}
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
