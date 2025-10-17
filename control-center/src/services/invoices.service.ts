import { supabase } from '../config/supabase'
import { Database } from '../config/supabase'

type Invoice = Database['public']['Tables']['invoices']['Row']
type InvoiceInsert = Database['public']['Tables']['invoices']['Insert']
type InvoiceUpdate = Database['public']['Tables']['invoices']['Update']

export class InvoicesService {
  static async getAll(): Promise<Invoice[]> {
    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching invoices:', error)
      throw new Error('Error al cargar facturas')
    }

    return data || []
  }

  static async getByDateRange(startDate: string, endDate: string): Promise<Invoice[]> {
    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .gte('created_at', startDate)
      .lte('created_at', endDate)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching invoices by date range:', error)
      throw new Error('Error al cargar facturas por rango de fechas')
    }

    return data || []
  }

  static async getByCompany(companyId: string): Promise<Invoice[]> {
    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .eq('company_id', companyId)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching invoices by company:', error)
      throw new Error('Error al cargar facturas de la empresa')
    }

    return data || []
  }

  static async getByStatus(status: 'pending' | 'completed' | 'failed'): Promise<Invoice[]> {
    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .eq('status', status)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching invoices by status:', error)
      throw new Error('Error al cargar facturas por estado')
    }

    return data || []
  }

  static async getByTicketId(ticketId: string): Promise<Invoice | null> {
    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .eq('ticket_id', ticketId)
      .single()

    if (error) {
      console.error('Error fetching invoice by ticket ID:', error)
      return null
    }

    return data
  }

  static async getById(id: string): Promise<Invoice | null> {
    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .eq('id', id)
      .single()

    if (error) {
      console.error('Error fetching invoice:', error)
      return null
    }

    return data
  }

  static async create(invoice: InvoiceInsert): Promise<Invoice> {
    const { data, error } = await supabase
      .from('invoices')
      .insert(invoice)
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .single()

    if (error) {
      console.error('Error creating invoice:', error)
      throw new Error('Error al crear factura')
    }

    return data
  }

  static async update(id: string, updates: InvoiceUpdate): Promise<Invoice> {
    const { data, error } = await supabase
      .from('invoices')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .single()

    if (error) {
      console.error('Error updating invoice:', error)
      throw new Error('Error al actualizar factura')
    }

    return data
  }

  static async generatePDF(invoiceId: string): Promise<{ success: boolean; pdfUrl?: string; error?: string }> {
    try {
      const { data, error } = await supabase.functions.invoke('generate-invoice-pdf', {
        body: { invoiceId }
      })

      if (error) {
        console.error('Error generating PDF:', error)
        return { success: false, error: 'Error al generar PDF' }
      }

      return { success: true, pdfUrl: data.pdfUrl }
    } catch (error) {
      console.error('Error calling PDF generation function:', error)
      return { success: false, error: 'Error al generar PDF' }
    }
  }

  static async downloadPDF(pdfUrl: string): Promise<void> {
    try {
      // Create a temporary link to download the PDF
      const link = document.createElement('a')
      link.href = pdfUrl
      link.download = `factura_${Date.now()}.pdf`
      link.target = '_blank'
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
    } catch (error) {
      console.error('Error downloading PDF:', error)
      throw new Error('Error al descargar PDF')
    }
  }

  static getStatusDisplayName(status: string): string {
    const statusNames = {
      'pending': 'Pendiente',
      'completed': 'Completada',
      'failed': 'Fallida'
    }

    return statusNames[status as keyof typeof statusNames] || status
  }

  static getStatusColor(status: string): string {
    const statusColors = {
      'pending': 'text-yellow-600 bg-yellow-100',
      'completed': 'text-green-600 bg-green-100',
      'failed': 'text-red-600 bg-red-100'
    }

    return statusColors[status as keyof typeof statusColors] || 'text-gray-600 bg-gray-100'
  }

  static getPaymentMethodDisplayName(method: string): string {
    const methodNames = {
      'cash': 'Efectivo',
      'card': 'Tarjeta',
      'chip': 'Chip+PIN',
      'contactless': 'Contactless'
    }

    return methodNames[method as keyof typeof methodNames] || method
  }

  static async getStats(): Promise<{
    totalInvoices: number
    pendingInvoices: number
    completedInvoices: number
    failedInvoices: number
    totalAmount: number
    completedAmount: number
    averageAmount: number
  }> {
    const { data, error } = await supabase
      .from('invoices')
      .select('status, amount')

    if (error) {
      console.error('Error fetching invoice stats:', error)
      return {
        totalInvoices: 0,
        pendingInvoices: 0,
        completedInvoices: 0,
        failedInvoices: 0,
        totalAmount: 0,
        completedAmount: 0,
        averageAmount: 0
      }
    }

    const totalInvoices = data.length
    const pendingInvoices = data.filter(i => i.status === 'pending').length
    const completedInvoices = data.filter(i => i.status === 'completed').length
    const failedInvoices = data.filter(i => i.status === 'failed').length

    const totalAmount = data.reduce((sum, invoice) => sum + invoice.amount, 0)
    const completedAmount = data
      .filter(i => i.status === 'completed')
      .reduce((sum, invoice) => sum + invoice.amount, 0)
    const averageAmount = totalInvoices > 0 ? totalAmount / totalInvoices : 0

    return {
      totalInvoices,
      pendingInvoices,
      completedInvoices,
      failedInvoices,
      totalAmount: Math.round(totalAmount * 100) / 100,
      completedAmount: Math.round(completedAmount * 100) / 100,
      averageAmount: Math.round(averageAmount * 100) / 100
    }
  }

  static async getRecentInvoices(limit: number = 10): Promise<Invoice[]> {
    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        companies(name),
        zones(name)
      `)
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) {
      console.error('Error fetching recent invoices:', error)
      throw new Error('Error al cargar facturas recientes')
    }

    return data || []
  }
}
