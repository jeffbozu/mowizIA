import { CompaniesService } from '../../services/companies.service'
import { supabase } from '../../config/supabase'

// Mock de Supabase
jest.mock('../../config/supabase')

describe('CompaniesService', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('getAll', () => {
    it('should fetch all companies successfully', async () => {
      const mockCompanies = [
        {
          id: '1',
          name: 'MOWIZ',
          primary_color: '#3B82F6',
          background_color: '#F3F4F6',
          logo_url: 'https://example.com/logo.png',
          contact_email: 'contact@mowiz.com',
          contact_phone: '+34 123 456 789',
          address: 'Calle Principal 123',
          is_active: true,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z'
        }
      ]

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue({ data: mockCompanies, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await CompaniesService.getAll()

      expect(supabase.from).toHaveBeenCalledWith('companies')
      expect(mockQuery.select).toHaveBeenCalledWith('*')
      expect(mockQuery.order).toHaveBeenCalledWith('name')
      expect(result).toEqual(mockCompanies)
    })

    it('should handle errors when fetching companies', async () => {
      const mockError = { message: 'Database error' }
      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue({ data: null, error: mockError })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await expect(CompaniesService.getAll()).rejects.toThrow('Database error')
    })
  })

  describe('getById', () => {
    it('should fetch company by id successfully', async () => {
      const mockCompany = {
        id: '1',
        name: 'MOWIZ',
        primary_color: '#3B82F6',
        background_color: '#F3F4F6',
        logo_url: 'https://example.com/logo.png',
        contact_email: 'contact@mowiz.com',
        contact_phone: '+34 123 456 789',
        address: 'Calle Principal 123',
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      }

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockCompany, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await CompaniesService.getById('1')

      expect(supabase.from).toHaveBeenCalledWith('companies')
      expect(mockQuery.select).toHaveBeenCalledWith('*')
      expect(mockQuery.eq).toHaveBeenCalledWith('id', '1')
      expect(result).toEqual(mockCompany)
    })

    it('should handle errors when fetching company by id', async () => {
      const mockError = { message: 'Company not found' }
      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: mockError })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await expect(CompaniesService.getById('1')).rejects.toThrow('Company not found')
    })
  })

  describe('create', () => {
    it('should create company successfully', async () => {
      const companyData = {
        name: 'Test Company',
        primary_color: '#FF0000',
        background_color: '#FFFFFF',
        contact_email: 'test@test.com',
        contact_phone: '+34 987 654 321',
        address: 'Test Address'
      }

      const mockCompany = {
        id: '2',
        ...companyData,
        logo_url: null,
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      }

      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockCompany, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await CompaniesService.create(companyData)

      expect(supabase.from).toHaveBeenCalledWith('companies')
      expect(mockQuery.insert).toHaveBeenCalledWith(companyData)
      expect(result).toEqual(mockCompany)
    })

    it('should handle errors when creating company', async () => {
      const companyData = {
        name: 'Test Company',
        primary_color: '#FF0000',
        background_color: '#FFFFFF',
        contact_email: 'test@test.com',
        contact_phone: '+34 987 654 321',
        address: 'Test Address'
      }

      const mockError = { message: 'Validation error' }
      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: mockError })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await expect(CompaniesService.create(companyData)).rejects.toThrow('Validation error')
    })
  })

  describe('update', () => {
    it('should update company successfully', async () => {
      const updateData = {
        name: 'Updated Company',
        primary_color: '#00FF00'
      }

      const mockUpdatedCompany = {
        id: '1',
        name: 'Updated Company',
        primary_color: '#00FF00',
        background_color: '#F3F4F6',
        logo_url: 'https://example.com/logo.png',
        contact_email: 'contact@mowiz.com',
        contact_phone: '+34 123 456 789',
        address: 'Calle Principal 123',
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      }

      const mockQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockUpdatedCompany, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await CompaniesService.update('1', updateData)

      expect(supabase.from).toHaveBeenCalledWith('companies')
      expect(mockQuery.update).toHaveBeenCalledWith(updateData)
      expect(mockQuery.eq).toHaveBeenCalledWith('id', '1')
      expect(result).toEqual(mockUpdatedCompany)
    })

    it('should handle errors when updating company', async () => {
      const updateData = {
        name: 'Updated Company'
      }

      const mockError = { message: 'Update failed' }
      const mockQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: mockError })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await expect(CompaniesService.update('1', updateData)).rejects.toThrow('Update failed')
    })
  })

  describe('delete', () => {
    it('should delete company successfully', async () => {
      const mockQuery = {
        delete: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: null, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await CompaniesService.delete('1')

      expect(supabase.from).toHaveBeenCalledWith('companies')
      expect(mockQuery.delete).toHaveBeenCalled()
      expect(mockQuery.eq).toHaveBeenCalledWith('id', '1')
    })

    it('should handle errors when deleting company', async () => {
      const mockError = { message: 'Delete failed' }
      const mockQuery = {
        delete: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: null, error: mockError })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await expect(CompaniesService.delete('1')).rejects.toThrow('Delete failed')
    })
  })

  describe('getStats', () => {
    it('should fetch company statistics successfully', async () => {
      const mockStats = {
        totalCompanies: 5,
        activeCompanies: 4,
        inactiveCompanies: 1
      }

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue({ data: [], error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await CompaniesService.getStats()

      expect(supabase.from).toHaveBeenCalledWith('companies')
      expect(result).toHaveProperty('totalCompanies')
      expect(result).toHaveProperty('activeCompanies')
      expect(result).toHaveProperty('inactiveCompanies')
    })
  })
})
