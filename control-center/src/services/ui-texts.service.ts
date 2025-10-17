import { supabase } from '../config/supabase'
import { Database } from '../config/supabase'

type UIText = Database['public']['Tables']['ui_texts']['Row']
type UITextInsert = Database['public']['Tables']['ui_texts']['Insert']
type UITextUpdate = Database['public']['Tables']['ui_texts']['Update']

export class UITextsService {
  static async getAll(): Promise<UIText[]> {
    const { data, error } = await supabase
      .from('ui_texts')
      .select(`
        *,
        companies(name)
      `)
      .order('screen_name, text_key, language')

    if (error) {
      console.error('Error fetching UI texts:', error)
      throw new Error('Error al cargar textos UI')
    }

    return data || []
  }

  static async getByScreen(screenName: string, companyId?: string): Promise<UIText[]> {
    let query = supabase
      .from('ui_texts')
      .select(`
        *,
        companies(name)
      `)
      .eq('screen_name', screenName)
      .order('text_key, language')

    if (companyId) {
      query = query.eq('company_id', companyId)
    } else {
      query = query.is('company_id', null)
    }

    const { data, error } = await query

    if (error) {
      console.error('Error fetching UI texts by screen:', error)
      throw new Error('Error al cargar textos de la pantalla')
    }

    return data || []
  }

  static async getByLanguage(language: string, companyId?: string): Promise<UIText[]> {
    let query = supabase
      .from('ui_texts')
      .select(`
        *,
        companies(name)
      `)
      .eq('language', language)
      .order('screen_name, text_key')

    if (companyId) {
      query = query.eq('company_id', companyId)
    } else {
      query = query.is('company_id', null)
    }

    const { data, error } = await query

    if (error) {
      console.error('Error fetching UI texts by language:', error)
      throw new Error('Error al cargar textos del idioma')
    }

    return data || []
  }

  static async getById(id: string): Promise<UIText | null> {
    const { data, error } = await supabase
      .from('ui_texts')
      .select(`
        *,
        companies(name)
      `)
      .eq('id', id)
      .single()

    if (error) {
      console.error('Error fetching UI text:', error)
      return null
    }

    return data
  }

  static async create(uiText: UITextInsert): Promise<UIText> {
    // Check if text already exists for this screen/key/language/company combination
    const { data: existingText } = await supabase
      .from('ui_texts')
      .select('id')
      .eq('screen_name', uiText.screen_name)
      .eq('text_key', uiText.text_key)
      .eq('language', uiText.language)
      .eq('company_id', uiText.company_id || null)
      .single()

    if (existingText) {
      throw new Error('Ya existe un texto para esta combinación de pantalla/clave/idioma/empresa')
    }

    const { data, error } = await supabase
      .from('ui_texts')
      .insert(uiText)
      .select(`
        *,
        companies(name)
      `)
      .single()

    if (error) {
      console.error('Error creating UI text:', error)
      throw new Error('Error al crear texto UI')
    }

    return data
  }

  static async update(id: string, updates: UITextUpdate): Promise<UIText> {
    const { data, error } = await supabase
      .from('ui_texts')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select(`
        *,
        companies(name)
      `)
      .single()

    if (error) {
      console.error('Error updating UI text:', error)
      throw new Error('Error al actualizar texto UI')
    }

    return data
  }

  static async delete(id: string): Promise<void> {
    const { error } = await supabase
      .from('ui_texts')
      .delete()
      .eq('id', id)

    if (error) {
      console.error('Error deleting UI text:', error)
      throw new Error('Error al eliminar texto UI')
    }
  }

  static getAvailableScreens(): string[] {
    return [
      'login',
      'home',
      'zone_selection',
      'time_selection',
      'payment',
      'ticket',
      'extend',
      'settings',
      'error',
      'success'
    ]
  }

  static getAvailableLanguages(): string[] {
    return [
      'es-ES',
      'en-US',
      'ca-ES'
    ]
  }

  static getLanguageDisplayName(language: string): string {
    const languageNames = {
      'es-ES': 'Español (España)',
      'en-US': 'English (United States)',
      'ca-ES': 'Català (Espanya)'
    }

    return languageNames[language as keyof typeof languageNames] || language
  }

  static getScreenDisplayName(screenName: string): string {
    const screenNames = {
      'login': 'Pantalla de Login',
      'home': 'Pantalla Principal',
      'zone_selection': 'Selección de Zona',
      'time_selection': 'Selección de Tiempo',
      'payment': 'Pantalla de Pago',
      'ticket': 'Pantalla de Ticket',
      'extend': 'Extensión de Tiempo',
      'settings': 'Configuración',
      'error': 'Pantalla de Error',
      'success': 'Pantalla de Éxito'
    }

    return screenNames[screenName as keyof typeof screenNames] || screenName
  }

  static validateTextKey(textKey: string): string[] {
    const errors: string[] = []

    if (!textKey || textKey.trim().length === 0) {
      errors.push('La clave del texto es requerida')
    }

    if (textKey.length < 2) {
      errors.push('La clave del texto debe tener al menos 2 caracteres')
    }

    if (textKey.length > 100) {
      errors.push('La clave del texto no puede tener más de 100 caracteres')
    }

    // Check for valid characters (alphanumeric, underscore, dot)
    const validKeyRegex = /^[a-zA-Z0-9._]+$/
    if (!validKeyRegex.test(textKey)) {
      errors.push('La clave del texto solo puede contener letras, números, punto y guión bajo')
    }

    return errors
  }

  static validateTextValue(textValue: string): string[] {
    const errors: string[] = []

    if (!textValue || textValue.trim().length === 0) {
      errors.push('El valor del texto es requerido')
    }

    if (textValue.length > 500) {
      errors.push('El valor del texto no puede tener más de 500 caracteres')
    }

    return errors
  }

  static async getStats(): Promise<{
    totalTexts: number
    textsByLanguage: Record<string, number>
    textsByScreen: Record<string, number>
    globalTexts: number
    companyTexts: number
  }> {
    const { data, error } = await supabase
      .from('ui_texts')
      .select('language, screen_name, company_id')

    if (error) {
      console.error('Error fetching UI text stats:', error)
      return {
        totalTexts: 0,
        textsByLanguage: {},
        textsByScreen: {},
        globalTexts: 0,
        companyTexts: 0
      }
    }

    const totalTexts = data.length
    const globalTexts = data.filter(t => !t.company_id).length
    const companyTexts = totalTexts - globalTexts

    const textsByLanguage = data.reduce((acc, text) => {
      acc[text.language] = (acc[text.language] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    const textsByScreen = data.reduce((acc, text) => {
      acc[text.screen_name] = (acc[text.screen_name] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    return {
      totalTexts,
      textsByLanguage,
      textsByScreen,
      globalTexts,
      companyTexts
    }
  }
}
