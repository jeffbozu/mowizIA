import { renderHook } from '@testing-library/react'
import { useRealtimeList, useRealtimeStats } from '../../hooks/useRealtime'
import { supabase } from '../../config/supabase'

jest.mock('../../config/supabase')

describe('useRealtime hooks', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('useRealtimeList', () => {
    it('should subscribe to table changes', () => {
      const mockChannel = {
        on: jest.fn().mockReturnThis(),
        subscribe: jest.fn().mockReturnThis(),
        state: 'joined'
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadData = jest.fn()

      renderHook(() => useRealtimeList('companies', mockLoadData))

      expect(supabase.channel).toHaveBeenCalledWith('realtime:companies')
      expect(mockChannel.on).toHaveBeenCalledWith(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'companies' },
        expect.any(Function)
      )
      expect(mockChannel.subscribe).toHaveBeenCalled()
    })

    it('should subscribe with filter when provided', () => {
      const mockChannel = {
        on: jest.fn().mockReturnThis(),
        subscribe: jest.fn().mockReturnThis(),
        state: 'joined'
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadData = jest.fn()

      renderHook(() => useRealtimeList('zones', mockLoadData, 'company_id=eq.comp1'))

      expect(supabase.channel).toHaveBeenCalledWith('realtime:zones:company_id=eq.comp1')
    })

    it('should call loadData when change is detected', () => {
      const mockChannel = {
        on: jest.fn().mockImplementation((event, config, callback) => {
          // Simulate a change event
          callback()
          return mockChannel
        }),
        subscribe: jest.fn().mockReturnThis(),
        state: 'joined'
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadData = jest.fn()

      renderHook(() => useRealtimeList('companies', mockLoadData))

      expect(mockLoadData).toHaveBeenCalled()
    })

    it('should return connection status', () => {
      const mockChannel = {
        on: jest.fn().mockReturnThis(),
        subscribe: jest.fn().mockReturnThis(),
        state: 'joined'
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadData = jest.fn()

      const { result } = renderHook(() => useRealtimeList('companies', mockLoadData))

      expect(result.current.isConnected).toBe(true)
    })

    it('should cleanup channel on unmount', () => {
      const mockChannel = {
        on: jest.fn().mockReturnThis(),
        subscribe: jest.fn().mockReturnThis(),
        state: 'joined'
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadData = jest.fn()

      const { unmount } = renderHook(() => useRealtimeList('companies', mockLoadData))

      unmount()

      expect(supabase.removeChannel).toHaveBeenCalledWith(mockChannel)
    })
  })

  describe('useRealtimeStats', () => {
    it('should subscribe to multiple table changes', () => {
      const mockChannel = {
        on: jest.fn().mockReturnThis(),
        subscribe: jest.fn().mockReturnThis()
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadStats = jest.fn()

      renderHook(() => useRealtimeStats(['companies', 'zones'], mockLoadStats))

      expect(supabase.channel).toHaveBeenCalledWith('stats:companies')
      expect(supabase.channel).toHaveBeenCalledWith('stats:zones')
      expect(mockChannel.subscribe).toHaveBeenCalledTimes(2)
    })

    it('should call loadStats when change is detected', () => {
      const mockChannel = {
        on: jest.fn().mockImplementation((event, config, callback) => {
          // Simulate a change event
          callback()
          return mockChannel
        }),
        subscribe: jest.fn().mockReturnThis()
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadStats = jest.fn()

      renderHook(() => useRealtimeStats(['companies'], mockLoadStats))

      expect(mockLoadStats).toHaveBeenCalled()
    })

    it('should cleanup all channels on unmount', () => {
      const mockChannel = {
        on: jest.fn().mockReturnThis(),
        subscribe: jest.fn().mockReturnThis()
      }

      ;(supabase.channel as jest.Mock).mockReturnValue(mockChannel)
      ;(supabase.removeChannel as jest.Mock).mockImplementation(() => {})

      const mockLoadStats = jest.fn()

      const { unmount } = renderHook(() => useRealtimeStats(['companies', 'zones'], mockLoadStats))

      unmount()

      expect(supabase.removeChannel).toHaveBeenCalledTimes(2)
    })
  })
})
