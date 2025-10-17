import { supabase } from '../config/supabase'

export interface User {
  id: string
  username: string
  role: 'superadmin' | 'admin' | 'operator' | 'viewer'
  company_id: string
  is_active: boolean
}

export interface LoginCredentials {
  username: string
  password: string
}

export class AuthService {
  private static currentUser: User | null = null

  static async login(credentials: LoginCredentials): Promise<{ user: User | null; error: string | null }> {
    try {
      // Get user from operators table
      const { data: operator, error } = await supabase
        .from('operators')
        .select('*')
        .eq('username', credentials.username)
        .eq('is_active', true)
        .single()

      if (error || !operator) {
        return { user: null, error: 'Usuario no encontrado o inactivo' }
      }

      // For demo purposes, we'll use plain text comparison
      // In production, use bcrypt.compare(credentials.password, operator.password_hash)
      const isValidPassword = credentials.password === operator.password_hash

      if (!isValidPassword) {
        return { user: null, error: 'Contraseña incorrecta' }
      }

      const user: User = {
        id: operator.id,
        username: operator.username,
        role: operator.role,
        company_id: operator.company_id,
        is_active: operator.is_active
      }

      this.currentUser = user
      
      // Store user in localStorage for persistence
      localStorage.setItem('meypark_user', JSON.stringify(user))

      return { user, error: null }
    } catch (error) {
      console.error('Login error:', error)
      return { user: null, error: 'Error interno del servidor' }
    }
  }

  static async logout(): Promise<void> {
    this.currentUser = null
    localStorage.removeItem('meypark_user')
  }

  static getCurrentUser(): User | null {
    if (this.currentUser) {
      return this.currentUser
    }

    // Try to restore from localStorage
    const storedUser = localStorage.getItem('meypark_user')
    if (storedUser) {
      try {
        this.currentUser = JSON.parse(storedUser)
        return this.currentUser
      } catch (error) {
        localStorage.removeItem('meypark_user')
      }
    }

    return null
  }

  static isAuthenticated(): boolean {
    return this.getCurrentUser() !== null
  }

  static hasRole(requiredRole: string): boolean {
    const user = this.getCurrentUser()
    if (!user) return false

    const roleHierarchy = {
      'viewer': 1,
      'operator': 2,
      'admin': 3,
      'superadmin': 4
    }

    const userLevel = roleHierarchy[user.role as keyof typeof roleHierarchy] || 0
    const requiredLevel = roleHierarchy[requiredRole as keyof typeof roleHierarchy] || 0

    return userLevel >= requiredLevel
  }

  static canEdit(): boolean {
    return this.hasRole('admin')
  }

  static canDelete(): boolean {
    return this.hasRole('superadmin')
  }

  static async changePassword(oldPassword: string, newPassword: string): Promise<{ success: boolean; error: string | null }> {
    try {
      const user = this.getCurrentUser()
      if (!user) {
        return { success: false, error: 'Usuario no autenticado' }
      }

      // Get current operator data
      const { data: operator, error } = await supabase
        .from('operators')
        .select('*')
        .eq('id', user.id)
        .single()

      if (error || !operator) {
        return { success: false, error: 'Error al obtener datos del usuario' }
      }

      // Verify old password
      const isValidOldPassword = oldPassword === operator.password_hash
      if (!isValidOldPassword) {
        return { success: false, error: 'Contraseña actual incorrecta' }
      }

      // Hash new password (in production)
      const hashedNewPassword = newPassword // For demo, we'll store plain text

      // Update password
      const { error: updateError } = await supabase
        .from('operators')
        .update({ password_hash: hashedNewPassword })
        .eq('id', user.id)

      if (updateError) {
        return { success: false, error: 'Error al actualizar contraseña' }
      }

      return { success: true, error: null }
    } catch (error) {
      console.error('Change password error:', error)
      return { success: false, error: 'Error interno del servidor' }
    }
  }
}
