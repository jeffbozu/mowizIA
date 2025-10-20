import { supabase } from '../config/supabase'
import { Database } from '../config/supabase'

type Zone = Database['public']['Tables']['zones']['Row']
type ZoneInsert = Database['public']['Tables']['zones']['Insert']
type ZoneUpdate = Database['public']['Tables']['zones']['Update']

export class ZonesService {
  static async getAll(): Promise<Zone[]> {
    const { data, error } = await supabase
      .from('zones')
      .select(`
        *,
        companies!inner(name)
      `)
      .order('name')

    if (error) {
      console.error('Error fetching zones:', error)
      throw new Error('Error al cargar zonas')
    }

    return data || []
  }

  static async getByCompany(companyId: string): Promise<Zone[]> {
    const { data, error } = await supabase
      .from('zones')
      .select(`
        *,
        companies!inner(name)
      `)
      .eq('company_id', companyId)
      .order('name')

    if (error) {
      console.error('Error fetching zones by company:', error)
      throw new Error('Error al cargar zonas de la empresa')
    }

    return data || []
  }

  static async getById(id: string): Promise<Zone | null> {
    const { data, error } = await supabase
      .from('zones')
      .select(`
        *,
        companies!inner(name)
      `)
      .eq('id', id)
      .single()

    if (error) {
      console.error('Error fetching zone:', error)
      return null
    }

    return data
  }

  static async create(zone: ZoneInsert): Promise<Zone> {
    const { data, error } = await supabase
      .from('zones')
      .insert(zone)
      .select(`
        *,
        companies!inner(name)
      `)
      .single()

    if (error) {
      console.error('Error creating zone:', error)
      throw new Error('Error al crear zona')
    }

    return data
  }

  static async update(id: string, updates: ZoneUpdate): Promise<Zone> {
    // Enviar a Edge Function control-center
    const { data, error } = await supabase.functions.invoke('control-center', {
      body: {
        action: 'update_zone',
        data: { id, updates }
      }
    })

    if (error || !data?.success) {
      console.error('Error updating zone via function:', error || data)
      throw new Error('Error al actualizar zona')
    }

    return data.data as Zone
  }

  static async delete(id: string): Promise<void> {
    // Soft delete - set is_active to false
    const { error } = await supabase
      .from('zones')
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .eq('id', id)

    if (error) {
      console.error('Error deleting zone:', error)
      throw new Error('Error al eliminar zona')
    }
  }

  static calculatePrice(pricePerHour: number, minutes: number): number {
    const hours = minutes / 60
    return Math.round((pricePerHour * hours) * 100) / 100 // Round to 2 decimal places
  }

  static validateTimeOptions(timeOptions: number[]): boolean {
    // Validate that all time options are positive integers
    return timeOptions.every(option => 
      Number.isInteger(option) && option > 0
    )
  }

  static validatePricing(pricePerHour: number, timeOptions: number[], timeIncrement: number, minTime: number): string[] {
    const errors: string[] = []

    if (pricePerHour <= 0) {
      errors.push('El precio por hora debe ser mayor que 0')
    }

    if (timeIncrement <= 0) {
      errors.push('El incremento de tiempo debe ser mayor que 0')
    }

    if (minTime <= 0) {
      errors.push('El tiempo mínimo debe ser mayor que 0')
    }

    if (minTime > Math.min(...timeOptions)) {
      errors.push('El tiempo mínimo no puede ser mayor que la opción más pequeña')
    }

    if (!this.validateTimeOptions(timeOptions)) {
      errors.push('Las opciones de tiempo deben ser números enteros positivos')
    }

    return errors
  }

  static async getStats(): Promise<{
    totalZones: number
    activeZones: number
    inactiveZones: number
    averagePrice: number
  }> {
    const { data, error } = await supabase
      .from('zones')
      .select('is_active, price_per_hour')

    if (error) {
      console.error('Error fetching zone stats:', error)
      return {
        totalZones: 0,
        activeZones: 0,
        inactiveZones: 0,
        averagePrice: 0
      }
    }

    const totalZones = data.length
    const activeZones = data.filter(z => z.is_active).length
    const inactiveZones = totalZones - activeZones
    const averagePrice = data.length > 0 
      ? data.reduce((sum, z) => sum + z.price_per_hour, 0) / data.length 
      : 0

    return {
      totalZones,
      activeZones,
      inactiveZones,
      averagePrice: Math.round(averagePrice * 100) / 100
    }
  }
}
