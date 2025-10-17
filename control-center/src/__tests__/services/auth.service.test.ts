import { AuthService } from '../../services/auth.service'
import { supabase } from '../../config/supabase'

jest.mock('../../config/supabase')

describe('AuthService', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('login', () => {
    it('should login successfully with valid credentials', async () => {
      const mockUser = {
        id: '1',
        email: 'admin@meypark.com',
        user_metadata: {
          username: 'admin'
        }
      }

      const mockAuthResponse = {
        data: { user: mockUser },
        error: null
      }

      ;(supabase.auth.signInWithPassword as jest.Mock).mockResolvedValue(mockAuthResponse)

      const result = await AuthService.login('admin@meypark.com', 'Admin123!')

      expect(supabase.auth.signInWithPassword).toHaveBeenCalledWith({
        email: 'admin@meypark.com',
        password: 'Admin123!'
      })
      expect(result).toEqual({
        id: '1',
        email: 'admin@meypark.com',
        username: 'admin'
      })
    })

    it('should throw error with invalid credentials', async () => {
      const mockError = { message: 'Invalid login credentials' }
      const mockAuthResponse = {
        data: { user: null },
        error: mockError
      }

      ;(supabase.auth.signInWithPassword as jest.Mock).mockResolvedValue(mockAuthResponse)

      await expect(AuthService.login('admin@meypark.com', 'wrongpassword')).rejects.toThrow('Invalid login credentials')
    })

    it('should throw error when user is null', async () => {
      const mockAuthResponse = {
        data: { user: null },
        error: null
      }

      ;(supabase.auth.signInWithPassword as jest.Mock).mockResolvedValue(mockAuthResponse)

      await expect(AuthService.login('admin@meypark.com', 'Admin123!')).rejects.toThrow('No se pudo iniciar sesión')
    })
  })

  describe('logout', () => {
    it('should logout successfully', async () => {
      const mockLogoutResponse = {
        error: null
      }

      ;(supabase.auth.signOut as jest.Mock).mockResolvedValue(mockLogoutResponse)

      await AuthService.logout()

      expect(supabase.auth.signOut).toHaveBeenCalled()
    })

    it('should handle logout errors', async () => {
      const mockError = { message: 'Logout failed' }
      const mockLogoutResponse = {
        error: mockError
      }

      ;(supabase.auth.signOut as jest.Mock).mockResolvedValue(mockLogoutResponse)

      await expect(AuthService.logout()).rejects.toThrow('Logout failed')
    })
  })

  describe('getCurrentUser', () => {
    it('should return current user when session exists', async () => {
      const mockUser = {
        id: '1',
        email: 'admin@meypark.com',
        user_metadata: {
          username: 'admin'
        }
      }

      const mockSession = {
        user: mockUser
      }

      const mockSessionResponse = {
        data: { session: mockSession },
        error: null
      }

      ;(supabase.auth.getSession as jest.Mock).mockResolvedValue(mockSessionResponse)

      const result = await AuthService.getCurrentUser()

      expect(supabase.auth.getSession).toHaveBeenCalled()
      expect(result).toEqual({
        id: '1',
        email: 'admin@meypark.com',
        username: 'admin'
      })
    })

    it('should return null when no session exists', async () => {
      const mockSessionResponse = {
        data: { session: null },
        error: null
      }

      ;(supabase.auth.getSession as jest.Mock).mockResolvedValue(mockSessionResponse)

      const result = await AuthService.getCurrentUser()

      expect(supabase.auth.getSession).toHaveBeenCalled()
      expect(result).toBeNull()
    })

    it('should handle session errors', async () => {
      const mockError = { message: 'Session error' }
      const mockSessionResponse = {
        data: { session: null },
        error: mockError
      }

      ;(supabase.auth.getSession as jest.Mock).mockResolvedValue(mockSessionResponse)

      await expect(AuthService.getCurrentUser()).rejects.toThrow('Session error')
    })
  })
})
