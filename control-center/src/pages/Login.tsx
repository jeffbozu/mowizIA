import React from 'react'
import { LoginForm } from '../components/auth/LoginForm'
import { User } from '../services/auth.service'

interface LoginPageProps {
  onLoginSuccess: (user: User) => void
}

export const LoginPage: React.FC<LoginPageProps> = ({ onLoginSuccess }) => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50">
      <LoginForm onLoginSuccess={onLoginSuccess} />
    </div>
  )
}
