import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { User } from '../services/auth.service'
import { OperatorsService } from '../services/operators.service'
import { CompaniesService } from '../services/companies.service'
import { Database } from '../config/supabase'

type Operator = Database['public']['Tables']['operators']['Row']
type Company = Database['public']['Tables']['companies']['Row']

interface OperatorsProps {
  user: User
  onLogout: () => void
}

const ROLES = [
  { value: 'superadmin', label: 'Super Administrador', description: 'Acceso completo al sistema' },
  { value: 'admin', label: 'Administrador', description: 'Gestión de empresas y zonas' },
  { value: 'operator', label: 'Operador', description: 'Operaciones básicas' },
  { value: 'viewer', label: 'Visualizador', description: 'Solo lectura' }
]

export const Operators: React.FC<OperatorsProps> = ({ user, onLogout }) => {
  const [operators, setOperators] = useState<Operator[]>([])
  const [companies, setCompanies] = useState<Company[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editingOperator, setEditingOperator] = useState<Operator | null>(null)
  const [selectedCompany, setSelectedCompany] = useState<string>('')
  const [selectedRole, setSelectedRole] = useState<string>('')
  const [formData, setFormData] = useState({
    name: '',
    username: '',
    password: '',
    company_id: '',
    role: 'operator',
    is_active: true,
    permissions: {
      can_manage_companies: false,
      can_manage_zones: false,
      can_manage_operators: false,
      can_manage_ui_texts: false,
      can_view_invoices: false,
      can_manage_invoices: false
    }
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setIsLoading(true)
      const [operatorsData, companiesData] = await Promise.all([
        OperatorsService.getAll(),
        CompaniesService.getAll()
      ])
      setOperators(operatorsData)
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
      const operatorData = {
        ...formData,
        role: formData.role as 'superadmin' | 'admin' | 'operator' | 'viewer',
        permissions: Object.values(formData.permissions) as any[],
        password_hash: formData.password // El servicio se encargará del hash
      }
      
      if (editingOperator) {
        await OperatorsService.update(editingOperator.id, operatorData)
      } else {
        await OperatorsService.create(operatorData)
      }
      setShowModal(false)
      setEditingOperator(null)
      resetForm()
      loadData()
    } catch (error) {
      console.error('Error saving operator:', error)
    }
  }

  const handleEdit = (operator: Operator) => {
    setEditingOperator(operator)
    setFormData({
      name: operator.username, // Usar username como name temporalmente
      username: operator.username,
      password: '', // No mostrar contraseña
      company_id: operator.company_id,
      role: operator.role,
      is_active: operator.is_active,
      permissions: {
        can_manage_companies: false,
        can_manage_zones: false,
        can_manage_operators: false,
        can_manage_ui_texts: false,
        can_view_invoices: false,
        can_manage_invoices: false
      }
    })
    setShowModal(true)
  }

  const handleDelete = async (operator: Operator) => {
    if (window.confirm(`¿Estás seguro de que quieres eliminar el operador "${operator.username}"?`)) {
      try {
        await OperatorsService.delete(operator.id)
        loadData()
      } catch (error) {
        console.error('Error deleting operator:', error)
      }
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      username: '',
      password: '',
      company_id: '',
      role: 'operator',
      is_active: true,
      permissions: {
        can_manage_companies: false,
        can_manage_zones: false,
        can_manage_operators: false,
        can_manage_ui_texts: false,
        can_view_invoices: false,
        can_manage_invoices: false
      }
    })
  }

  const openCreateModal = () => {
    setEditingOperator(null)
    resetForm()
    setShowModal(true)
  }

  const updatePermission = (permission: string, value: boolean) => {
    setFormData({
      ...formData,
      permissions: {
        ...formData.permissions,
        [permission]: value
      }
    })
  }

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'superadmin': return 'bg-red-100 text-red-800'
      case 'admin': return 'bg-blue-100 text-blue-800'
      case 'operator': return 'bg-green-100 text-green-800'
      case 'viewer': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredOperators = operators.filter(operator => {
    const companyMatch = !selectedCompany || operator.company_id === selectedCompany
    const roleMatch = !selectedRole || operator.role === selectedRole
    return companyMatch && roleMatch
  })

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
                <h1 className="text-3xl font-bold text-gray-900">Gestión de Operadores</h1>
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
              <h2 className="text-lg font-medium text-gray-900">Lista de Operadores</h2>
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
              <select
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value)}
                className="border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="">Todos los roles</option>
                {ROLES.map(role => (
                  <option key={role.value} value={role.value}>
                    {role.label}
                  </option>
                ))}
              </select>
            </div>
            <button
              onClick={openCreateModal}
              className="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md transition-colors"
            >
              Crear Operador
            </button>
          </div>

          {/* Operators Table */}
          <div className="bg-white shadow overflow-hidden sm:rounded-md">
            <ul className="divide-y divide-gray-200">
              {filteredOperators.map((operator) => (
                <li key={operator.id}>
                  <div className="px-4 py-4 flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="flex-shrink-0">
                        <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center">
                          <span className="text-primary-600 font-medium text-sm">
                            {operator.username.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="flex items-center">
                          <p className="text-sm font-medium text-gray-900">{operator.username}</p>
                          <span className={`ml-2 inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            operator.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                            {operator.is_active ? 'Activo' : 'Inactivo'}
                          </span>
                          <span className={`ml-2 inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getRoleColor(operator.role)}`}>
                            {ROLES.find(r => r.value === operator.role)?.label || operator.role}
                          </span>
                        </div>
                        <div className="flex items-center mt-1">
                          <p className="text-sm text-gray-500">@{operator.username}</p>
                          <span className="mx-2">•</span>
                          <p className="text-sm text-gray-500">
                            {companies.find(c => c.id === operator.company_id)?.name || 'Sin empresa'}
                          </p>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => handleEdit(operator)}
                        className="text-primary-600 hover:text-primary-900 text-sm font-medium"
                      >
                        Editar
                      </button>
                      <button
                        onClick={() => handleDelete(operator)}
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
                {editingOperator ? 'Editar Operador' : 'Crear Operador'}
              </h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Nombre Completo</label>
                    <input
                      type="text"
                      required
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Nombre de Usuario</label>
                    <input
                      type="text"
                      required
                      value={formData.username}
                      onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Contraseña {editingOperator && '(dejar vacío para mantener actual)'}
                    </label>
                    <input
                      type="password"
                      required={!editingOperator}
                      value={formData.password}
                      onChange={(e) => setFormData({ ...formData, password: e.target.value })}
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

                <div>
                  <label className="block text-sm font-medium text-gray-700">Rol</label>
                  <select
                    required
                    value={formData.role}
                    onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  >
                    {ROLES.map(role => (
                      <option key={role.value} value={role.value}>
                        {role.label} - {role.description}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Permissions */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Permisos Específicos</label>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.permissions.can_manage_companies}
                          onChange={(e) => updatePermission('can_manage_companies', e.target.checked)}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-900">Gestionar Empresas</span>
                      </label>
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.permissions.can_manage_zones}
                          onChange={(e) => updatePermission('can_manage_zones', e.target.checked)}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-900">Gestionar Zonas</span>
                      </label>
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.permissions.can_manage_operators}
                          onChange={(e) => updatePermission('can_manage_operators', e.target.checked)}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-900">Gestionar Operadores</span>
                      </label>
                    </div>
                    <div className="space-y-2">
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.permissions.can_manage_ui_texts}
                          onChange={(e) => updatePermission('can_manage_ui_texts', e.target.checked)}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-900">Gestionar Textos UI</span>
                      </label>
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.permissions.can_view_invoices}
                          onChange={(e) => updatePermission('can_view_invoices', e.target.checked)}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-900">Ver Facturas</span>
                      </label>
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.permissions.can_manage_invoices}
                          onChange={(e) => updatePermission('can_manage_invoices', e.target.checked)}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-900">Gestionar Facturas</span>
                      </label>
                    </div>
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
                    Operador activo
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
                    {editingOperator ? 'Actualizar' : 'Crear'}
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
