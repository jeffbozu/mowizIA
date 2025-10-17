import { UITextsService } from '../../services/ui-texts.service'
import { supabase } from '../../config/supabase'

// Mock Supabase client
jest.mock('../../config/supabase', () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      delete: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      single: jest.fn(),
      order: jest.fn().mockReturnThis()
    }))
  }
}))

describe('UITextsService', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should fetch all UI texts', async () => {
    const mockUITexts = [
      {
        id: '1',
        key: 'welcome_message',
        text: 'Bienvenido',
        language: 'es-ES',
        company_id: 'comp1'
      }
    ]
    ;(supabase.from('ui_texts').select as jest.Mock).mockResolvedValue({ data: mockUITexts, error: null })

    const uiTexts = await UITextsService.getAll()
    expect(uiTexts).toEqual(mockUITexts)
    expect(supabase.from).toHaveBeenCalledWith('ui_texts')
    expect(supabase.from('ui_texts').select).toHaveBeenCalledWith('*')
  })

  it('should create a new UI text', async () => {
    const newUITextData = {
      key: 'new_message',
      text: 'Nuevo mensaje',
      language: 'es-ES',
      company_id: 'comp1'
    }
    const createdUIText = { id: '2', ...newUITextData }
    ;(supabase.from('ui_texts').insert as jest.Mock).mockResolvedValue({ data: [createdUIText], error: null })

    const uiText = await UITextsService.create(newUITextData)
    expect(uiText).toEqual(createdUIText)
    expect(supabase.from).toHaveBeenCalledWith('ui_texts')
    expect(supabase.from('ui_texts').insert).toHaveBeenCalledWith(newUITextData)
  })

  it('should update a UI text', async () => {
    const updatedUITextData = {
      text: 'Mensaje actualizado',
      language: 'en-US'
    }
    const updatedUIText = { id: '1', ...updatedUITextData }
    ;(supabase.from('ui_texts').update as jest.Mock).mockResolvedValue({ data: [updatedUIText], error: null })

    const uiText = await UITextsService.update('1', updatedUITextData)
    expect(uiText).toEqual(updatedUIText)
    expect(supabase.from).toHaveBeenCalledWith('ui_texts')
    expect(supabase.from('ui_texts').update).toHaveBeenCalledWith(updatedUITextData)
    expect(supabase.from('ui_texts').update().eq).toHaveBeenCalledWith('id', '1')
  })

  it('should delete a UI text', async () => {
    ;(supabase.from('ui_texts').delete as jest.Mock).mockResolvedValue({ data: [], error: null })

    await UITextsService.delete('1')
    expect(supabase.from).toHaveBeenCalledWith('ui_texts')
    expect(supabase.from('ui_texts').delete).toHaveBeenCalled()
    expect(supabase.from('ui_texts').delete().eq).toHaveBeenCalledWith('id', '1')
  })

  it('should get UI text stats', async () => {
    const mockStats = {
      totalTexts: 10,
      textsByLanguage: {
        'es-ES': 5,
        'en-US': 5
      },
      textsByCompany: {
        'comp1': 7,
        'comp2': 3
      }
    }
    ;(supabase.from('ui_texts').select as jest.Mock).mockResolvedValue({ data: mockStats, error: null })

    const stats = await UITextsService.getStats()
    expect(stats).toEqual(mockStats)
    expect(supabase.from).toHaveBeenCalledWith('ui_texts')
    expect(supabase.from('ui_texts').select).toHaveBeenCalledWith('totalTexts:count,textsByLanguage:language,textsByCompany:company_id')
  })
})
