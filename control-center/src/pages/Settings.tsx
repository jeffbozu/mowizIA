import React from 'react'
import { User } from '../services/auth.service'

interface SettingsProps {
  user: User
  onLogout: () => void
}

export const Settings: React.FC<SettingsProps> = ({ user, onLogout }) => {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Configuración</h1>
              <p className="text-gray-600">Bienvenido, {user.username}</p>
            </div>
            <button
              onClick={onLogout}
              className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md"
            >
              Cerrar Sesión
            </button>
          </div>
        </div>
      </div>
      
      <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="border-4 border-dashed border-gray-200 rounded-lg h-96 flex items-center justify-center">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Configuración</h2>
              <p className="text-gray-600">Esta página se completará en la siguiente fase del desarrollo.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
