import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || 'https://thfmuoqcrkhxduxuygro.supabase.co'
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b3FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Database types
export interface Database {
  public: {
    Tables: {
      companies: {
        Row: {
          id: string
          name: string
          primary_color: string
          background_color: string
          logo_url: string | null
          contact_email: string | null
          contact_phone: string | null
          address: string | null
          created_at: string
          updated_at: string
          is_active: boolean
        }
        Insert: {
          id?: string
          name: string
          primary_color?: string
          background_color?: string
          logo_url?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          address?: string | null
          created_at?: string
          updated_at?: string
          is_active?: boolean
        }
        Update: {
          id?: string
          name?: string
          primary_color?: string
          background_color?: string
          logo_url?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          address?: string | null
          created_at?: string
          updated_at?: string
          is_active?: boolean
        }
      }
      zones: {
        Row: {
          id: string
          company_id: string
          name: string
          color: string
          price_per_hour: number
          max_duration: number
          description: string | null
          time_options: number[]
          time_increment: number
          min_time: number
          created_at: string
          updated_at: string
          is_active: boolean
        }
        Insert: {
          id?: string
          company_id: string
          name: string
          color?: string
          price_per_hour: number
          max_duration?: number
          description?: string | null
          time_options?: number[]
          time_increment?: number
          min_time?: number
          created_at?: string
          updated_at?: string
          is_active?: boolean
        }
        Update: {
          id?: string
          company_id?: string
          name?: string
          color?: string
          price_per_hour?: number
          max_duration?: number
          description?: string | null
          time_options?: number[]
          time_increment?: number
          min_time?: number
          created_at?: string
          updated_at?: string
          is_active?: boolean
        }
      }
      operators: {
        Row: {
          id: string
          company_id: string
          username: string
          password_hash: string
          role: 'superadmin' | 'admin' | 'operator' | 'viewer'
          permissions: any[]
          created_at: string
          updated_at: string
          is_active: boolean
        }
        Insert: {
          id?: string
          company_id: string
          username: string
          password_hash: string
          role?: 'superadmin' | 'admin' | 'operator' | 'viewer'
          permissions?: any[]
          created_at?: string
          updated_at?: string
          is_active?: boolean
        }
        Update: {
          id?: string
          company_id?: string
          username?: string
          password_hash?: string
          role?: 'superadmin' | 'admin' | 'operator' | 'viewer'
          permissions?: any[]
          created_at?: string
          updated_at?: string
          is_active?: boolean
        }
      }
      ui_texts: {
        Row: {
          id: string
          company_id: string | null
          screen_name: string
          text_key: string
          text_value: string
          language: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          company_id?: string | null
          screen_name: string
          text_key: string
          text_value: string
          language: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          company_id?: string | null
          screen_name?: string
          text_key?: string
          text_value?: string
          language?: string
          created_at?: string
          updated_at?: string
        }
      }
      invoices: {
        Row: {
          id: string
          ticket_id: string
          company_id: string | null
          zone_id: string | null
          zone_name: string | null
          plate: string
          amount: number
          payment_method: string | null
          duration_minutes: number | null
          start_time: string | null
          end_time: string | null
          kiosco_id: string | null
          is_extend: boolean
          fiscal_name: string | null
          fiscal_nif: string | null
          fiscal_address: string | null
          fiscal_city: string | null
          fiscal_postal_code: string | null
          fiscal_email: string | null
          fiscal_phone: string | null
          invoice_number: string | null
          invoice_pdf_url: string | null
          status: 'pending' | 'completed' | 'failed'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          ticket_id: string
          company_id?: string | null
          zone_id?: string | null
          zone_name?: string | null
          plate: string
          amount: number
          payment_method?: string | null
          duration_minutes?: number | null
          start_time?: string | null
          end_time?: string | null
          kiosco_id?: string | null
          is_extend?: boolean
          fiscal_name?: string | null
          fiscal_nif?: string | null
          fiscal_address?: string | null
          fiscal_city?: string | null
          fiscal_postal_code?: string | null
          fiscal_email?: string | null
          fiscal_phone?: string | null
          invoice_number?: string | null
          invoice_pdf_url?: string | null
          status?: 'pending' | 'completed' | 'failed'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          ticket_id?: string
          company_id?: string | null
          zone_id?: string | null
          zone_name?: string | null
          plate?: string
          amount?: number
          payment_method?: string | null
          duration_minutes?: number | null
          start_time?: string | null
          end_time?: string | null
          kiosco_id?: string | null
          is_extend?: boolean
          fiscal_name?: string | null
          fiscal_nif?: string | null
          fiscal_address?: string | null
          fiscal_city?: string | null
          fiscal_postal_code?: string | null
          fiscal_email?: string | null
          fiscal_phone?: string | null
          invoice_number?: string | null
          invoice_pdf_url?: string | null
          status?: 'pending' | 'completed' | 'failed'
          created_at?: string
          updated_at?: string
        }
      }
    }
  }
}
