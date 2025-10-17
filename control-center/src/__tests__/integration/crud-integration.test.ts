import { CompaniesService } from '../../services/companies.service'
import { ZonesService } from '../../services/zones.service'
import { OperatorsService } from '../../services/operators.service'
import { UITextsService } from '../../services/ui-texts.service'
import { supabase } from '../../config/supabase'

// Mock Supabase client para tests de integración
jest.mock('../../config/supabase', () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      delete: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      single: jest.fn(),
      order: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      storage: {
        from: jest.fn(() => ({
          upload: jest.fn(),
          remove: jest.fn(),
          getPublicUrl: jest.fn(() => ({ data: { publicUrl: 'http://mockurl.com/logo.png' } }))
        }))
      }
    }))
  }
}))

describe('CRUD Integration Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('Company CRUD Flow', () => {
    it('should complete full CRUD cycle for companies', async () => {
      // 1. Create company
      const newCompany = {
        name: 'Test Company',
        primary_color: '#FF0000',
        background_color: '#FFFFFF',
        contact_email: 'test@company.com',
        contact_phone: '+34 123 456 789',
        address: 'Test Address 123'
      }

      const createdCompany = { id: '1', ...newCompany, is_active: true, created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' }
      
      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: createdCompany, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await CompaniesService.create(newCompany)
      expect(result).toEqual(createdCompany)

      // 2. Read company
      const mockReadQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: createdCompany, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockReadQuery)

      const readResult = await CompaniesService.getById('1')
      expect(readResult).toEqual(createdCompany)

      // 3. Update company
      const updateData = { name: 'Updated Test Company', primary_color: '#00FF00' }
      const updatedCompany = { ...createdCompany, ...updateData, updated_at: '2024-01-01T01:00:00Z' }
      
      const mockUpdateQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: updatedCompany, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockUpdateQuery)

      const updateResult = await CompaniesService.update('1', updateData)
      expect(updateResult).toEqual(updatedCompany)

      // 4. Delete company (soft delete)
      const mockDeleteQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: null, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockDeleteQuery)

      await CompaniesService.delete('1')
      expect(mockDeleteQuery.update).toHaveBeenCalledWith({ is_active: false, updated_at: expect.any(String) })
    })
  })

  describe('Zone CRUD Flow', () => {
    it('should complete full CRUD cycle for zones', async () => {
      // 1. Create zone
      const newZone = {
        name: 'Test Zone',
        company_id: 'company-1',
        price_per_hour: 2.50,
        time_options: [15, 30, 60, 120],
        time_increment: 15,
        min_time: 15,
        max_duration: 480,
        color: '#3B82F6',
        is_active: true
      }

      const createdZone = { id: '1', ...newZone, created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' }
      
      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: createdZone, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await ZonesService.create(newZone)
      expect(result).toEqual(createdZone)

      // 2. Update zone pricing
      const updateData = { price_per_hour: 3.00, time_options: [30, 60, 120, 180] }
      const updatedZone = { ...createdZone, ...updateData, updated_at: '2024-01-01T01:00:00Z' }
      
      const mockUpdateQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: updatedZone, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockUpdateQuery)

      const updateResult = await ZonesService.update('1', updateData)
      expect(updateResult).toEqual(updatedZone)

      // 3. Deactivate zone
      const mockDeleteQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: null, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockDeleteQuery)

      await ZonesService.delete('1')
      expect(mockDeleteQuery.update).toHaveBeenCalledWith({ is_active: false, updated_at: expect.any(String) })
    })
  })

  describe('Operator CRUD Flow', () => {
    it('should complete full CRUD cycle for operators', async () => {
      // 1. Create operator
      const newOperator = {
        username: 'testoperator',
        password_hash: 'hashedpassword123',
        role: 'operator',
        permissions: {
          can_manage_companies: false,
          can_manage_zones: false,
          can_manage_operators: false,
          can_manage_ui_texts: false,
          can_view_invoices: true
        },
        is_active: true
      }

      const createdOperator = { id: '1', ...newOperator, created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' }
      
      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: createdOperator, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await OperatorsService.create(newOperator)
      expect(result).toEqual(createdOperator)

      // 2. Update operator role
      const updateData = { 
        role: 'admin',
        permissions: {
          can_manage_companies: true,
          can_manage_zones: true,
          can_manage_operators: true,
          can_manage_ui_texts: true,
          can_view_invoices: true
        }
      }
      const updatedOperator = { ...createdOperator, ...updateData, updated_at: '2024-01-01T01:00:00Z' }
      
      const mockUpdateQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: updatedOperator, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockUpdateQuery)

      const updateResult = await OperatorsService.update('1', updateData)
      expect(updateResult).toEqual(updatedOperator)

      // 3. Deactivate operator
      const mockDeleteQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: null, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockDeleteQuery)

      await OperatorsService.delete('1')
      expect(mockDeleteQuery.update).toHaveBeenCalledWith({ is_active: false, updated_at: expect.any(String) })
    })
  })

  describe('UI Text CRUD Flow', () => {
    it('should complete full CRUD cycle for UI texts', async () => {
      // 1. Create UI text
      const newUIText = {
        key: 'test_message',
        text: 'Test Message',
        language: 'es-ES',
        company_id: 'company-1'
      }

      const createdUIText = { id: '1', ...newUIText, created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' }
      
      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: createdUIText, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await UITextsService.create(newUIText)
      expect(result).toEqual(createdUIText)

      // 2. Update UI text
      const updateData = { text: 'Updated Test Message', language: 'en-US' }
      const updatedUIText = { ...createdUIText, ...updateData, updated_at: '2024-01-01T01:00:00Z' }
      
      const mockUpdateQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: updatedUIText, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockUpdateQuery)

      const updateResult = await UITextsService.update('1', updateData)
      expect(updateResult).toEqual(updatedUIText)

      // 3. Delete UI text
      const mockDeleteQuery = {
        delete: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: null, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockDeleteQuery)

      await UITextsService.delete('1')
      expect(mockDeleteQuery.delete).toHaveBeenCalled()
      expect(mockDeleteQuery.eq).toHaveBeenCalledWith('id', '1')
    })
  })

  describe('Cross-Entity Dependencies', () => {
    it('should handle company-zone relationships correctly', async () => {
      // Create company first
      const company = {
        name: 'Test Company',
        primary_color: '#FF0000',
        background_color: '#FFFFFF',
        contact_email: 'test@company.com',
        contact_phone: '+34 123 456 789',
        address: 'Test Address 123'
      }

      const createdCompany = { id: 'company-1', ...company, is_active: true, created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' }
      
      const mockCompanyQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: createdCompany, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockCompanyQuery)

      await CompaniesService.create(company)

      // Create zone for the company
      const zone = {
        name: 'Company Zone',
        company_id: 'company-1',
        price_per_hour: 2.50,
        time_options: [15, 30, 60, 120],
        time_increment: 15,
        min_time: 15,
        max_duration: 480,
        color: '#3B82F6',
        is_active: true
      }

      const createdZone = { id: 'zone-1', ...zone, created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' }
      
      const mockZoneQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: createdZone, error: null })
      }
      ;(supabase.from as jest.Mock).mockReturnValue(mockZoneQuery)

      const zoneResult = await ZonesService.create(zone)
      expect(zoneResult.company_id).toBe('company-1')

      // Verify zone belongs to company
      expect(zoneResult).toEqual(createdZone)
    })
  })
})
