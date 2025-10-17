import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { LoginForm } from '../../../components/auth/LoginForm'

// Mock the AuthService
jest.mock('../../../services/auth.service', () => ({
  AuthService: {
    login: jest.fn()
  }
}))

import { AuthService } from '../../../services/auth.service'

describe('LoginForm', () => {
  const mockOnLogin = jest.fn()

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should render login form fields', () => {
    render(<LoginForm onLogin={mockOnLogin} />)

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/contraseña/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /iniciar sesión/i })).toBeInTheDocument()
  })

  it('should show validation errors for empty fields', async () => {
    const user = userEvent.setup()
    render(<LoginForm onLogin={mockOnLogin} />)

    const submitButton = screen.getByRole('button', { name: /iniciar sesión/i })
    await user.click(submitButton)

    await waitFor(() => {
      expect(screen.getByText(/el email es requerido/i)).toBeInTheDocument()
      expect(screen.getByText(/la contraseña es requerida/i)).toBeInTheDocument()
    })
  })

  it('should show validation error for invalid email', async () => {
    const user = userEvent.setup()
    render(<LoginForm onLogin={mockOnLogin} />)

    const emailInput = screen.getByLabelText(/email/i)
    const submitButton = screen.getByRole('button', { name: /iniciar sesión/i })

    await user.type(emailInput, 'invalid-email')
    await user.click(submitButton)

    await waitFor(() => {
      expect(screen.getByText(/email inválido/i)).toBeInTheDocument()
    })
  })

  it('should call onLogin with user data on successful login', async () => {
    const user = userEvent.setup()
    const mockUser = {
      id: '1',
      email: 'admin@meypark.com',
      username: 'admin'
    }

    ;(AuthService.login as jest.Mock).mockResolvedValue(mockUser)

    render(<LoginForm onLogin={mockOnLogin} />)

    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/contraseña/i)
    const submitButton = screen.getByRole('button', { name: /iniciar sesión/i })

    await user.type(emailInput, 'admin@meypark.com')
    await user.type(passwordInput, 'Admin123!')
    await user.click(submitButton)

    await waitFor(() => {
      expect(AuthService.login).toHaveBeenCalledWith('admin@meypark.com', 'Admin123!')
      expect(mockOnLogin).toHaveBeenCalledWith(mockUser)
    })
  })

  it('should show error message on login failure', async () => {
    const user = userEvent.setup()
    const mockError = new Error('Credenciales inválidas')

    ;(AuthService.login as jest.Mock).mockRejectedValue(mockError)

    render(<LoginForm onLogin={mockOnLogin} />)

    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/contraseña/i)
    const submitButton = screen.getByRole('button', { name: /iniciar sesión/i })

    await user.type(emailInput, 'admin@meypark.com')
    await user.type(passwordInput, 'wrongpassword')
    await user.click(submitButton)

    await waitFor(() => {
      expect(screen.getByText(/credenciales inválidas/i)).toBeInTheDocument()
    })
  })

  it('should show loading state during login', async () => {
    const user = userEvent.setup()
    let resolveLogin: (value: any) => void
    const loginPromise = new Promise(resolve => {
      resolveLogin = resolve
    })

    ;(AuthService.login as jest.Mock).mockReturnValue(loginPromise)

    render(<LoginForm onLogin={mockOnLogin} />)

    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/contraseña/i)
    const submitButton = screen.getByRole('button', { name: /iniciar sesión/i })

    await user.type(emailInput, 'admin@meypark.com')
    await user.type(passwordInput, 'Admin123!')
    await user.click(submitButton)

    expect(screen.getByText(/iniciando sesión/i)).toBeInTheDocument()
    expect(submitButton).toBeDisabled()

    // Resolve the login promise
    resolveLogin!({
      id: '1',
      email: 'admin@meypark.com',
      username: 'admin'
    })

    await waitFor(() => {
      expect(screen.queryByText(/iniciando sesión/i)).not.toBeInTheDocument()
      expect(submitButton).not.toBeDisabled()
    })
  })
})
