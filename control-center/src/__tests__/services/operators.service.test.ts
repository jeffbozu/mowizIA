import { OperatorsService } from '../../services/operators.service'
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
      order: jest.fn().mockReturnThis()
    }))
  }
}))

describe('OperatorsService', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should fetch all operators', async () => {
    const mockOperators = [
      {
        id: '1',
        username: 'operator1',
        role: 'operator',
        permissions: {
          can_manage_companies: false,
          can_manage_zones: false,
          can_manage_operators: false,
          can_manage_ui_texts: false,
          can_view_invoices: true
        },
        is_active: true
      }
    ]
    ;(supabase.from('operators').select as jest.Mock).mockResolvedValue({ data: mockOperators, error: null })

    const operators = await OperatorsService.getAll()
    expect(operators).toEqual(mockOperators)
    expect(supabase.from).toHaveBeenCalledWith('operators')
    expect(supabase.from('operators').select).toHaveBeenCalledWith('*')
  })

  it('should create a new operator', async () => {
    const newOperatorData = {
      username: 'newoperator',
      password_hash: 'hashedpassword',
      role: 'operator',
      permissions: {
        can_manage_companies: false,
        can_manage_zones: false,
        can_manage_operators: false,
        can_manage_ui_texts: false,
        can_view_invoices: true
      },
      is_active: true
    }
    const createdOperator = { id: '2', ...newOperatorData }
    ;(supabase.from('operators').insert as jest.Mock).mockResolvedValue({ data: [createdOperator], error: null })

    const operator = await OperatorsService.create(newOperatorData)
    expect(operator).toEqual(createdOperator)
    expect(supabase.from).toHaveBeenCalledWith('operators')
    expect(supabase.from('operators').insert).toHaveBeenCalledWith(newOperatorData)
  })

  it('should update an operator', async () => {
    const updatedOperatorData = {
      username: 'updatedoperator',
      role: 'admin',
      permissions: {
        can_manage_companies: true,
        can_manage_zones: true,
        can_manage_operators: true,
        can_manage_ui_texts: true,
        can_view_invoices: true
      }
    }
    const updatedOperator = { id: '1', ...updatedOperatorData }
    ;(supabase.from('operators').update as jest.Mock).mockResolvedValue({ data: [updatedOperator], error: null })

    const operator = await OperatorsService.update('1', updatedOperatorData)
    expect(operator).toEqual(updatedOperator)
    expect(supabase.from).toHaveBeenCalledWith('operators')
    expect(supabase.from('operators').update).toHaveBeenCalledWith(updatedOperatorData)
    expect(supabase.from('operators').update().eq).toHaveBeenCalledWith('id', '1')
  })

  it('should delete an operator', async () => {
    ;(supabase.from('operators').delete as jest.Mock).mockResolvedValue({ data: [], error: null })

    await OperatorsService.delete('1')
    expect(supabase.from).toHaveBeenCalledWith('operators')
    expect(supabase.from('operators').delete).toHaveBeenCalled()
    expect(supabase.from('operators').delete().eq).toHaveBeenCalledWith('id', '1')
  })

  it('should get operator stats', async () => {
    const mockStats = {
      totalOperators: 5,
      activeOperators: 3,
      inactiveOperators: 2,
      operatorsByRole: {
        admin: 1,
        operator: 4
      }
    }
    ;(supabase.from('operators').select as jest.Mock).mockResolvedValue({ data: mockStats, error: null })

    const stats = await OperatorsService.getStats()
    expect(stats).toEqual(mockStats)
    expect(supabase.from).toHaveBeenCalledWith('operators')
    expect(supabase.from('operators').select).toHaveBeenCalledWith('totalOperators:count,activeOperators:count(id.filter=is_active.eq.true),inactiveOperators:count(id.filter=is_active.eq.false),operatorsByRole:role')
  })
})
