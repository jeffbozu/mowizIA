import { ZonesService } from '../../services/zones.service'
import { supabase } from '../../config/supabase'

jest.mock('../../config/supabase')

describe('ZonesService', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('getAll', () => {
    it('should fetch all zones successfully', async () => {
      const mockZones = [
        {
          id: '1',
          name: 'Zona Centro',
          company_id: 'company-1',
          price_per_hour: 2.50,
          time_options: [15, 30, 60, 120],
          time_increment: 15,
          min_time: 15,
          max_duration: 480,
          color: '#3B82F6',
          is_active: true,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z'
        }
      ]

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue({ data: mockZones, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await ZonesService.getAll()

      expect(supabase.from).toHaveBeenCalledWith('zones')
      expect(mockQuery.select).toHaveBeenCalledWith('*')
      expect(result).toEqual(mockZones)
    })

    it('should handle errors when fetching zones', async () => {
      const mockError = { message: 'Database error' }
      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue({ data: null, error: mockError })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await expect(ZonesService.getAll()).rejects.toThrow('Database error')
    })
  })

  describe('getById', () => {
    it('should fetch zone by id successfully', async () => {
      const mockZone = {
        id: '1',
        name: 'Zona Centro',
        company_id: 'company-1',
        price_per_hour: 2.50,
        time_options: [15, 30, 60, 120],
        time_increment: 15,
        min_time: 15,
        max_duration: 480,
        color: '#3B82F6',
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      }

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockZone, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await ZonesService.getById('1')

      expect(supabase.from).toHaveBeenCalledWith('zones')
      expect(mockQuery.select).toHaveBeenCalledWith('*')
      expect(mockQuery.eq).toHaveBeenCalledWith('id', '1')
      expect(result).toEqual(mockZone)
    })
  })

  describe('create', () => {
    it('should create zone successfully', async () => {
      const zoneData = {
        name: 'Nueva Zona',
        company_id: 'company-1',
        price_per_hour: 3.00,
        time_options: [30, 60, 120, 180],
        time_increment: 30,
        min_time: 30,
        max_duration: 360,
        color: '#FF0000',
        is_active: true
      }

      const mockZone = {
        id: '2',
        ...zoneData,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      }

      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockZone, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await ZonesService.create(zoneData)

      expect(supabase.from).toHaveBeenCalledWith('zones')
      expect(mockQuery.insert).toHaveBeenCalledWith(zoneData)
      expect(result).toEqual(mockZone)
    })

    it('should handle errors when creating zone', async () => {
      const zoneData = {
        name: 'Nueva Zona',
        company_id: 'company-1',
        price_per_hour: 3.00,
        time_options: [30, 60, 120, 180],
        time_increment: 30,
        min_time: 30,
        max_duration: 360,
        color: '#FF0000',
        is_active: true
      }

      const mockError = { message: 'Validation error' }
      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: mockError })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await expect(ZonesService.create(zoneData)).rejects.toThrow('Validation error')
    })
  })

  describe('update', () => {
    it('should update zone successfully', async () => {
      const updateData = {
        name: 'Zona Actualizada',
        price_per_hour: 4.00
      }

      const mockUpdatedZone = {
        id: '1',
        name: 'Zona Actualizada',
        company_id: 'company-1',
        price_per_hour: 4.00,
        time_options: [15, 30, 60, 120],
        time_increment: 15,
        min_time: 15,
        max_duration: 480,
        color: '#3B82F6',
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      }

      const mockQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockUpdatedZone, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await ZonesService.update('1', updateData)

      expect(supabase.from).toHaveBeenCalledWith('zones')
      expect(mockQuery.update).toHaveBeenCalledWith(updateData)
      expect(mockQuery.eq).toHaveBeenCalledWith('id', '1')
      expect(result).toEqual(mockUpdatedZone)
    })
  })

  describe('delete', () => {
    it('should delete zone successfully', async () => {
      const mockQuery = {
        delete: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: null, error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      await ZonesService.delete('1')

      expect(supabase.from).toHaveBeenCalledWith('zones')
      expect(mockQuery.delete).toHaveBeenCalled()
      expect(mockQuery.eq).toHaveBeenCalledWith('id', '1')
    })
  })

  describe('getStats', () => {
    it('should fetch zone statistics successfully', async () => {
      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        limit: jest.fn().mockResolvedValue({ data: [], error: null })
      }

      ;(supabase.from as jest.Mock).mockReturnValue(mockQuery)

      const result = await ZonesService.getStats()

      expect(supabase.from).toHaveBeenCalledWith('zones')
      expect(result).toHaveProperty('totalZones')
      expect(result).toHaveProperty('activeZones')
      expect(result).toHaveProperty('inactiveZones')
      expect(result).toHaveProperty('averagePrice')
    })
  })
})
