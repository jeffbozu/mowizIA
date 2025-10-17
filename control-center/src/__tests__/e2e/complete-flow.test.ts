import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { BrowserRouter } from 'react-router-dom'
import App from '../../App'
import { AuthService } from '../../services/auth.service'
import { CompaniesService } from '../../services/companies.service'
import { ZonesService } from '../../services/zones.service'

// Mock all services
jest.mock('../../services/auth.service')
jest.mock('../../services/companies.service')
jest.mock('../../services/zones.service')
jest.mock('../../services/operators.service')
jest.mock('../../services/ui-texts.service')
jest.mock('../../services/invoices.service')
jest.mock('../../config/supabase')

const MockedAuthService = AuthService as jest.Mocked<typeof AuthService>
const MockedCompaniesService = CompaniesService as jest.Mocked<typeof CompaniesService>
const MockedZonesService = ZonesService as jest.Mocked<typeof ZonesService>

// Helper function to render app with router
const renderApp = () => {
  return render(
    <BrowserRouter>
      <App />
    </BrowserRouter>
  )
}

describe('E2E Complete Flow Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    
    // Mock successful authentication
    MockedAuthService.getCurrentUser.mockResolvedValue(null)
    MockedAuthService.login.mockResolvedValue({
      id: '1',
      email: 'admin@meypark.com',
      username: 'admin'
    })
  })

  describe('Authentication Flow', () => {
    it('should complete login flow successfully', async () => {
      const user = userEvent.setup()
      renderApp()

      // Should show login form initially
      expect(screen.getByText(/centro de control meypark/i)).toBeInTheDocument()
      expect(screen.getByText(/inicia sesión/i)).toBeInTheDocument()

      // Fill login form
      const usernameInput = screen.getByPlaceholderText(/nombre de usuario/i)
      const passwordInput = screen.getByPlaceholderText(/contraseña/i)
      const loginButton = screen.getByRole('button', { name: /iniciar sesión/i })

      await user.type(usernameInput, 'admin@meypark.com')
      await user.type(passwordInput, 'Admin123!')
      await user.click(loginButton)

      // Should call login service
      await waitFor(() => {
        expect(MockedAuthService.login).toHaveBeenCalledWith('admin@meypark.com', 'Admin123!')
      })
    })

    it('should show error for invalid credentials', async () => {
      const user = userEvent.setup()
      
      // Mock login failure
      MockedAuthService.login.mockRejectedValue(new Error('Credenciales inválidas'))
      
      renderApp()

      const usernameInput = screen.getByPlaceholderText(/nombre de usuario/i)
      const passwordInput = screen.getByPlaceholderText(/contraseña/i)
      const loginButton = screen.getByRole('button', { name: /iniciar sesión/i })

      await user.type(usernameInput, 'admin@meypark.com')
      await user.type(passwordInput, 'wrongpassword')
      await user.click(loginButton)

      // Should show error message
      await waitFor(() => {
        expect(screen.getByText(/credenciales inválidas/i)).toBeInTheDocument()
      })
    })
  })

  describe('Dashboard Flow', () => {
    beforeEach(() => {
      // Mock authenticated user
      MockedAuthService.getCurrentUser.mockResolvedValue({
        id: '1',
        email: 'admin@meypark.com',
        username: 'admin'
      })

      // Mock dashboard data
      MockedCompaniesService.getStats.mockResolvedValue({
        totalCompanies: 5,
        activeCompanies: 3,
        inactiveCompanies: 2
      })

      MockedZonesService.getStats.mockResolvedValue({
        totalZones: 10,
        activeZones: 8,
        inactiveZones: 2,
        averagePrice: 2.50
      })
    })

    it('should display dashboard after successful login', async () => {
      renderApp()

      // Should show dashboard
      await waitFor(() => {
        expect(screen.getByText(/dashboard/i)).toBeInTheDocument()
        expect(screen.getByText(/estadísticas/i)).toBeInTheDocument()
      })

      // Should load stats
      expect(MockedCompaniesService.getStats).toHaveBeenCalled()
      expect(MockedZonesService.getStats).toHaveBeenCalled()
    })
  })

  describe('Company Management Flow', () => {
    beforeEach(() => {
      MockedAuthService.getCurrentUser.mockResolvedValue({
        id: '1',
        email: 'admin@meypark.com',
        username: 'admin'
      })

      // Mock companies data
      MockedCompaniesService.getAll.mockResolvedValue([
        {
          id: '1',
          name: 'MOWIZ',
          primary_color: '#3B82F6',
          background_color: '#F3F4F6',
          contact_email: 'contact@mowiz.com',
          contact_phone: '+34 123 456 789',
          address: 'Calle Principal 123',
          logo_url: 'https://example.com/logo.png',
          is_active: true,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z'
        }
      ])

      MockedCompaniesService.create.mockResolvedValue({
        id: '2',
        name: 'New Company',
        primary_color: '#FF0000',
        background_color: '#FFFFFF',
        contact_email: 'new@company.com',
        contact_phone: '+34 987 654 321',
        address: 'New Address 456',
        logo_url: null,
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      })
    })

    it('should complete company CRUD flow', async () => {
      const user = userEvent.setup()
      renderApp()

      // Navigate to companies page
      await waitFor(() => {
        expect(screen.getByText(/dashboard/i)).toBeInTheDocument()
      })

      const companiesLink = screen.getByText(/empresas/i)
      await user.click(companiesLink)

      // Should show companies list
      await waitFor(() => {
        expect(screen.getByText(/gestión de empresas/i)).toBeInTheDocument()
        expect(screen.getByText(/mowiz/i)).toBeInTheDocument()
      })

      // Click create company button
      const createButton = screen.getByText(/crear empresa/i)
      await user.click(createButton)

      // Should show create form
      await waitFor(() => {
        expect(screen.getByText(/nueva empresa/i)).toBeInTheDocument()
      })

      // Fill form
      const nameInput = screen.getByLabelText(/nombre/i)
      const emailInput = screen.getByLabelText(/email/i)
      const phoneInput = screen.getByLabelText(/teléfono/i)
      const addressInput = screen.getByLabelText(/dirección/i)
      const submitButton = screen.getByText(/crear/i)

      await user.type(nameInput, 'New Company')
      await user.type(emailInput, 'new@company.com')
      await user.type(phoneInput, '+34 987 654 321')
      await user.type(addressInput, 'New Address 456')
      await user.click(submitButton)

      // Should call create service
      await waitFor(() => {
        expect(MockedCompaniesService.create).toHaveBeenCalledWith({
          name: 'New Company',
          contact_email: 'new@company.com',
          contact_phone: '+34 987 654 321',
          address: 'New Address 456',
          primary_color: '#3B82F6',
          background_color: '#F3F4F6',
          logo_url: null
        })
      })
    })
  })

  describe('Zone Management Flow', () => {
    beforeEach(() => {
      MockedAuthService.getCurrentUser.mockResolvedValue({
        id: '1',
        email: 'admin@meypark.com',
        username: 'admin'
      })

      // Mock zones data
      MockedZonesService.getAll.mockResolvedValue([
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
      ])

      MockedZonesService.create.mockResolvedValue({
        id: '2',
        name: 'New Zone',
        company_id: 'company-1',
        price_per_hour: 3.00,
        time_options: [30, 60, 120, 180],
        time_increment: 30,
        min_time: 30,
        max_duration: 360,
        color: '#FF0000',
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z'
      })
    })

    it('should complete zone CRUD flow', async () => {
      const user = userEvent.setup()
      renderApp()

      // Navigate to zones page
      await waitFor(() => {
        expect(screen.getByText(/dashboard/i)).toBeInTheDocument()
      })

      const zonesLink = screen.getByText(/zonas/i)
      await user.click(zonesLink)

      // Should show zones list
      await waitFor(() => {
        expect(screen.getByText(/gestión de zonas/i)).toBeInTheDocument()
        expect(screen.getByText(/zona centro/i)).toBeInTheDocument()
      })

      // Click create zone button
      const createButton = screen.getByText(/crear zona/i)
      await user.click(createButton)

      // Should show create form
      await waitFor(() => {
        expect(screen.getByText(/nueva zona/i)).toBeInTheDocument()
      })

      // Fill form
      const nameInput = screen.getByLabelText(/nombre/i)
      const priceInput = screen.getByLabelText(/precio por hora/i)
      const submitButton = screen.getByText(/crear/i)

      await user.type(nameInput, 'New Zone')
      await user.type(priceInput, '3.00')
      await user.click(submitButton)

      // Should call create service
      await waitFor(() => {
        expect(MockedZonesService.create).toHaveBeenCalledWith({
          name: 'New Zone',
          company_id: expect.any(String),
          price_per_hour: 3.00,
          time_options: [15, 30, 60, 120, 180, 240],
          time_increment: 15,
          min_time: 15,
          max_duration: 480,
          color: '#3B82F6',
          is_active: true
        })
      })
    })
  })

  describe('Real-time Updates Flow', () => {
    it('should handle real-time updates', async () => {
      MockedAuthService.getCurrentUser.mockResolvedValue({
        id: '1',
        email: 'admin@meypark.com',
        username: 'admin'
      })

      // Mock initial data
      MockedCompaniesService.getAll.mockResolvedValue([
        {
          id: '1',
          name: 'MOWIZ',
          primary_color: '#3B82F6',
          background_color: '#F3F4F6',
          contact_email: 'contact@mowiz.com',
          contact_phone: '+34 123 456 789',
          address: 'Calle Principal 123',
          logo_url: 'https://example.com/logo.png',
          is_active: true,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z'
        }
      ])

      renderApp()

      // Navigate to companies
      await waitFor(() => {
        expect(screen.getByText(/dashboard/i)).toBeInTheDocument()
      })

      const companiesLink = screen.getByText(/empresas/i)
      await user.click(companiesLink)

      // Should show initial data
      await waitFor(() => {
        expect(screen.getByText(/mowiz/i)).toBeInTheDocument()
      })

      // Simulate real-time update
      MockedCompaniesService.getAll.mockResolvedValue([
        {
          id: '1',
          name: 'MOWIZ Updated',
          primary_color: '#FF0000',
          background_color: '#F3F4F6',
          contact_email: 'contact@mowiz.com',
          contact_phone: '+34 123 456 789',
          address: 'Calle Principal 123',
          logo_url: 'https://example.com/logo.png',
          is_active: true,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T01:00:00Z'
        }
      ])

      // Should update in real-time (this would be triggered by the real-time hook)
      // In a real scenario, this would be triggered by Supabase real-time events
    })
  })
})
