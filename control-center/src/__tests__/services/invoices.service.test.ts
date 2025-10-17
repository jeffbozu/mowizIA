import { InvoicesService } from '../../services/invoices.service'
import { supabase } from '../../config/supabase'

// Mock Supabase client
jest.mock('../../config/supabase', () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      delete: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      single: jest.fn(),
      order: jest.fn().mockReturnThis(),
      gte: jest.fn().mockReturnThis(),
      lte: jest.fn().mockReturnThis()
    }))
  }
}))

describe('InvoicesService', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should fetch all invoices', async () => {
    const mockInvoices = [
      {
        id: '1',
        ticket_id: 'ticket1',
        company_id: 'comp1',
        zone_id: 'zone1',
        plate: 'ABC123',
        amount: 10.50,
        payment_method: 'card',
        duration_minutes: 60,
        start_time: '2024-01-01T10:00:00Z',
        end_time: '2024-01-01T11:00:00Z',
        kiosco_id: 'kiosk1',
        is_extend: false,
        status: 'completed',
        invoice_data: {},
        pdf_url: 'http://example.com/invoice.pdf',
        created_at: '2024-01-01T10:00:00Z',
        updated_at: '2024-01-01T10:00:00Z'
      }
    ]
    ;(supabase.from('invoices').select as jest.Mock).mockResolvedValue({ data: mockInvoices, error: null })

    const invoices = await InvoicesService.getAll()
    expect(invoices).toEqual(mockInvoices)
    expect(supabase.from).toHaveBeenCalledWith('invoices')
    expect(supabase.from('invoices').select).toHaveBeenCalledWith('*')
  })

  it('should create a new invoice', async () => {
    const newInvoiceData = {
      ticket_id: 'ticket2',
      company_id: 'comp1',
      zone_id: 'zone1',
      plate: 'XYZ789',
      amount: 15.00,
      payment_method: 'cash',
      duration_minutes: 90,
      start_time: '2024-01-01T12:00:00Z',
      end_time: '2024-01-01T13:30:00Z',
      kiosco_id: 'kiosk1',
      is_extend: false,
      status: 'pending',
      invoice_data: {}
    }
    const createdInvoice = { id: '2', ...newInvoiceData }
    ;(supabase.from('invoices').insert as jest.Mock).mockResolvedValue({ data: [createdInvoice], error: null })

    const invoice = await InvoicesService.create(newInvoiceData)
    expect(invoice).toEqual(createdInvoice)
    expect(supabase.from).toHaveBeenCalledWith('invoices')
    expect(supabase.from('invoices').insert).toHaveBeenCalledWith(newInvoiceData)
  })

  it('should update an invoice', async () => {
    const updatedInvoiceData = {
      status: 'completed',
      pdf_url: 'http://example.com/updated-invoice.pdf'
    }
    const updatedInvoice = { id: '1', ...updatedInvoiceData }
    ;(supabase.from('invoices').update as jest.Mock).mockResolvedValue({ data: [updatedInvoice], error: null })

    const invoice = await InvoicesService.update('1', updatedInvoiceData)
    expect(invoice).toEqual(updatedInvoice)
    expect(supabase.from).toHaveBeenCalledWith('invoices')
    expect(supabase.from('invoices').update).toHaveBeenCalledWith(updatedInvoiceData)
    expect(supabase.from('invoices').update().eq).toHaveBeenCalledWith('id', '1')
  })

  it('should delete an invoice', async () => {
    ;(supabase.from('invoices').delete as jest.Mock).mockResolvedValue({ data: [], error: null })

    await InvoicesService.delete('1')
    expect(supabase.from).toHaveBeenCalledWith('invoices')
    expect(supabase.from('invoices').delete).toHaveBeenCalled()
    expect(supabase.from('invoices').delete().eq).toHaveBeenCalledWith('id', '1')
  })

  it('should get recent invoices', async () => {
    const mockRecentInvoices = [
      {
        id: '1',
        ticket_id: 'ticket1',
        plate: 'ABC123',
        amount: 10.50,
        status: 'completed',
        created_at: '2024-01-01T10:00:00Z'
      }
    ]
    ;(supabase.from('invoices').select as jest.Mock).mockResolvedValue({ data: mockRecentInvoices, error: null })

    const invoices = await InvoicesService.getRecentInvoices(10)
    expect(invoices).toEqual(mockRecentInvoices)
    expect(supabase.from).toHaveBeenCalledWith('invoices')
    expect(supabase.from('invoices').select).toHaveBeenCalledWith('id, ticket_id, plate, amount, status, created_at')
    expect(supabase.from('invoices').select().order).toHaveBeenCalledWith('created_at', { ascending: false })
  })

  it('should get invoice stats', async () => {
    const mockStats = {
      totalInvoices: 100,
      totalRevenue: 1500.00,
      invoicesByStatus: {
        completed: 80,
        pending: 15,
        failed: 5
      },
      invoicesByPaymentMethod: {
        card: 60,
        cash: 40
      }
    }
    ;(supabase.from('invoices').select as jest.Mock).mockResolvedValue({ data: mockStats, error: null })

    const stats = await InvoicesService.getStats()
    expect(stats).toEqual(mockStats)
    expect(supabase.from).toHaveBeenCalledWith('invoices')
    expect(supabase.from('invoices').select).toHaveBeenCalledWith('totalInvoices:count,totalRevenue:sum(amount),invoicesByStatus:status,invoicesByPaymentMethod:payment_method')
  })

  it('should get status display name', () => {
    expect(InvoicesService.getStatusDisplayName('completed')).toBe('Completada')
    expect(InvoicesService.getStatusDisplayName('pending')).toBe('Pendiente')
    expect(InvoicesService.getStatusDisplayName('failed')).toBe('Fallida')
    expect(InvoicesService.getStatusDisplayName('unknown')).toBe('Desconocido')
  })

  it('should get status color', () => {
    expect(InvoicesService.getStatusColor('completed')).toBe('green')
    expect(InvoicesService.getStatusColor('pending')).toBe('yellow')
    expect(InvoicesService.getStatusColor('failed')).toBe('red')
    expect(InvoicesService.getStatusColor('unknown')).toBe('gray')
  })
})
