import React, { useState, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { LoginPage } from './pages/Login'
import { Dashboard } from './pages/Dashboard'
import { Companies } from './pages/Companies'
import { Zones } from './pages/Zones'
import { Operators } from './pages/Operators'
import { UITexts } from './pages/UITexts'
import { Invoices } from './pages/Invoices'
import { Settings } from './pages/Settings'
import Analytics from './pages/Analytics'
import { AuthService, User } from './services/auth.service'

function App() {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Check if user is already logged in
    const currentUser = AuthService.getCurrentUser()
    setUser(currentUser)
    setIsLoading(false)
  }, [])

  const handleLoginSuccess = (loggedInUser: User) => {
    setUser(loggedInUser)
  }

  const handleLogout = async () => {
    await AuthService.logout()
    setUser(null)
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  if (!user) {
    return <LoginPage onLoginSuccess={handleLoginSuccess} />
  }

  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Routes>
          <Route path="/login" element={<Navigate to="/" replace />} />
          <Route path="/" element={<Dashboard user={user} onLogout={handleLogout} />} />
          <Route path="/companies" element={<Companies user={user} onLogout={handleLogout} />} />
          <Route path="/zones" element={<Zones user={user} onLogout={handleLogout} />} />
          <Route path="/operators" element={<Operators user={user} onLogout={handleLogout} />} />
          <Route path="/ui-texts" element={<UITexts user={user} onLogout={handleLogout} />} />
          <Route path="/invoices" element={<Invoices user={user} onLogout={handleLogout} />} />
          <Route path="/analytics" element={<Analytics />} />
          <Route path="/settings" element={<Settings user={user} onLogout={handleLogout} />} />
        </Routes>
      </div>
    </Router>
  )
}

export default App
