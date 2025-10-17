import { supabase } from '../config/supabase'
import { Database } from '../config/supabase'

type Company = Database['public']['Tables']['companies']['Row']
type CompanyInsert = Database['public']['Tables']['companies']['Insert']
type CompanyUpdate = Database['public']['Tables']['companies']['Update']

export class CompaniesService {
  static async getAll(): Promise<Company[]> {
    const { data, error } = await supabase
      .from('companies')
      .select('*')
      .order('name')

    if (error) {
      console.error('Error fetching companies:', error)
      throw new Error('Error al cargar empresas')
    }

    return data || []
  }

  static async getById(id: string): Promise<Company | null> {
    const { data, error } = await supabase
      .from('companies')
      .select('*')
      .eq('id', id)
      .single()
    
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const result = data

    if (error) {
      console.error('Error fetching company:', error)
      return null
    }

    return data
  }

  static async create(company: CompanyInsert): Promise<Company> {
    const { data, error } = await supabase
      .from('companies')
      .insert(company)
      .select()
      .single()

    if (error) {
      console.error('Error creating company:', error)
      throw new Error('Error al crear empresa')
    }

    return data
  }

  static async update(id: string, updates: CompanyUpdate): Promise<Company> {
    const { data, error } = await supabase
      .from('companies')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single()

    if (error) {
      console.error('Error updating company:', error)
      throw new Error('Error al actualizar empresa')
    }

    return data
  }

  static async delete(id: string): Promise<void> {
    // Soft delete - set is_active to false
    const { error } = await supabase
      .from('companies')
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .eq('id', id)

    if (error) {
      console.error('Error deleting company:', error)
      throw new Error('Error al eliminar empresa')
    }
  }

  static async uploadLogo(file: File, companyId: string): Promise<string> {
    try {
      // Create unique filename
      const fileExt = file.name.split('.').pop()
      const fileName = `logo_${companyId}_${Date.now()}.${fileExt}`

      // Upload to Supabase Storage
      const { data, error } = await supabase.storage
        .from('logos')
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false
        })
      
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const result = data

      if (error) {
        console.error('Error uploading logo:', error)
        throw new Error('Error al subir logo')
      }

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('logos')
        .getPublicUrl(fileName)

      return urlData.publicUrl
    } catch (error) {
      console.error('Logo upload error:', error)
      throw new Error('Error al subir logo')
    }
  }

  static async getStats(): Promise<{
    totalCompanies: number
    activeCompanies: number
    inactiveCompanies: number
  }> {
    const { data, error } = await supabase
      .from('companies')
      .select('is_active')

    if (error) {
      console.error('Error fetching company stats:', error)
      return {
        totalCompanies: 0,
        activeCompanies: 0,
        inactiveCompanies: 0
      }
    }

    const totalCompanies = data.length
    const activeCompanies = data.filter(c => c.is_active).length
    const inactiveCompanies = totalCompanies - activeCompanies

    return {
      totalCompanies,
      activeCompanies,
      inactiveCompanies
    }
  }
}
