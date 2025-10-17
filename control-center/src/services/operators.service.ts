import { supabase } from '../config/supabase'
import { Database } from '../config/supabase'

type Operator = Database['public']['Tables']['operators']['Row']
type OperatorInsert = Database['public']['Tables']['operators']['Insert']
type OperatorUpdate = Database['public']['Tables']['operators']['Update']

export class OperatorsService {
  static async getAll(): Promise<Operator[]> {
    const { data, error } = await supabase
      .from('operators')
      .select(`
        *,
        companies!inner(name)
      `)
      .order('username')

    if (error) {
      console.error('Error fetching operators:', error)
      throw new Error('Error al cargar operadores')
    }

    return data || []
  }

  static async getByCompany(companyId: string): Promise<Operator[]> {
    const { data, error } = await supabase
      .from('operators')
      .select(`
        *,
        companies!inner(name)
      `)
      .eq('company_id', companyId)
      .order('username')

    if (error) {
      console.error('Error fetching operators by company:', error)
      throw new Error('Error al cargar operadores de la empresa')
    }

    return data || []
  }

  static async getById(id: string): Promise<Operator | null> {
    const { data, error } = await supabase
      .from('operators')
      .select(`
        *,
        companies!inner(name)
      `)
      .eq('id', id)
      .single()

    if (error) {
      console.error('Error fetching operator:', error)
      return null
    }

    return data
  }

  static async create(operator: OperatorInsert): Promise<Operator> {
    // Check if username already exists
    const { data: existingOperator } = await supabase
      .from('operators')
      .select('id')
      .eq('username', operator.username)
      .single()

    if (existingOperator) {
      throw new Error('El nombre de usuario ya existe')
    }

    const { data, error } = await supabase
      .from('operators')
      .insert(operator)
      .select(`
        *,
        companies!inner(name)
      `)
      .single()

    if (error) {
      console.error('Error creating operator:', error)
      throw new Error('Error al crear operador')
    }

    return data
  }

  static async update(id: string, updates: OperatorUpdate): Promise<Operator> {
    // If username is being updated, check for duplicates
    if (updates.username) {
      const { data: existingOperator } = await supabase
        .from('operators')
        .select('id')
        .eq('username', updates.username)
        .neq('id', id)
        .single()

      if (existingOperator) {
        throw new Error('El nombre de usuario ya existe')
      }
    }

    const { data, error } = await supabase
      .from('operators')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select(`
        *,
        companies!inner(name)
      `)
      .single()

    if (error) {
      console.error('Error updating operator:', error)
      throw new Error('Error al actualizar operador')
    }

    return data
  }

  static async delete(id: string): Promise<void> {
    // Soft delete - set is_active to false
    const { error } = await supabase
      .from('operators')
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .eq('id', id)

    if (error) {
      console.error('Error deleting operator:', error)
      throw new Error('Error al eliminar operador')
    }
  }

  static async changePassword(id: string, newPassword: string): Promise<void> {
    // For demo purposes, we'll store plain text
    // In production, hash with bcrypt
    const { error } = await supabase
      .from('operators')
      .update({ 
        password_hash: newPassword,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)

    if (error) {
      console.error('Error changing password:', error)
      throw new Error('Error al cambiar contraseña')
    }
  }

  static validateUsername(username: string): string[] {
    const errors: string[] = []

    if (!username || username.trim().length === 0) {
      errors.push('El nombre de usuario es requerido')
    }

    if (username.length < 3) {
      errors.push('El nombre de usuario debe tener al menos 3 caracteres')
    }

    if (username.length > 50) {
      errors.push('El nombre de usuario no puede tener más de 50 caracteres')
    }

    // Check for valid characters (alphanumeric, @, ., -, _)
    const validUsernameRegex = /^[a-zA-Z0-9@._-]+$/
    if (!validUsernameRegex.test(username)) {
      errors.push('El nombre de usuario solo puede contener letras, números, @, ., - y _')
    }

    return errors
  }

  static validatePassword(password: string): string[] {
    const errors: string[] = []

    if (!password || password.length === 0) {
      errors.push('La contraseña es requerida')
    }

    if (password.length < 6) {
      errors.push('La contraseña debe tener al menos 6 caracteres')
    }

    if (password.length > 100) {
      errors.push('La contraseña no puede tener más de 100 caracteres')
    }

    return errors
  }

  static getRoleDisplayName(role: string): string {
    const roleNames = {
      'superadmin': 'Super Administrador',
      'admin': 'Administrador',
      'operator': 'Operador',
      'viewer': 'Visualizador'
    }

    return roleNames[role as keyof typeof roleNames] || role
  }

  static getRoleDescription(role: string): string {
    const descriptions = {
      'superadmin': 'Acceso completo al sistema, puede gestionar todo',
      'admin': 'Puede gestionar empresas, zonas y operadores',
      'operator': 'Puede gestionar zonas y ver reportes',
      'viewer': 'Solo puede ver información, no puede modificar'
    }

    return descriptions[role as keyof typeof descriptions] || 'Rol no definido'
  }

  static async getStats(): Promise<{
    totalOperators: number
    activeOperators: number
    inactiveOperators: number
    operatorsByRole: Record<string, number>
  }> {
    const { data, error } = await supabase
      .from('operators')
      .select('is_active, role')

    if (error) {
      console.error('Error fetching operator stats:', error)
      return {
        totalOperators: 0,
        activeOperators: 0,
        inactiveOperators: 0,
        operatorsByRole: {}
      }
    }

    const totalOperators = data.length
    const activeOperators = data.filter(o => o.is_active).length
    const inactiveOperators = totalOperators - activeOperators

    const operatorsByRole = data.reduce((acc, operator) => {
      acc[operator.role] = (acc[operator.role] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    return {
      totalOperators,
      activeOperators,
      inactiveOperators,
      operatorsByRole
    }
  }
}
