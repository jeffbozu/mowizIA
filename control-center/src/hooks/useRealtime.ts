import { useEffect, useRef } from 'react'
import { supabase } from '../config/supabase'

interface UseRealtimeOptions {
  table: string
  onInsert?: (payload: any) => void
  onUpdate?: (payload: any) => void
  onDelete?: (payload: any) => void
  filter?: string
}

export function useRealtime({
  table,
  onInsert,
  onUpdate,
  onDelete,
  filter
}: UseRealtimeOptions) {
  const channelRef = useRef<any>(null)

  useEffect(() => {
    // Crear canal de tiempo real
    const channel = supabase
      .channel(`realtime:${table}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table,
          filter: filter ? `company_id=eq.${filter}` : undefined
        },
        (payload) => {
          console.log(`🔄 Nuevo registro insertado en ${table}:`, payload.new)
          onInsert?.(payload)
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table,
          filter: filter ? `company_id=eq.${filter}` : undefined
        },
        (payload) => {
          console.log(`🔄 Registro actualizado en ${table}:`, payload.new)
          onUpdate?.(payload)
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'DELETE',
          schema: 'public',
          table,
          filter: filter ? `company_id=eq.${filter}` : undefined
        },
        (payload) => {
          console.log(`🔄 Registro eliminado en ${table}:`, payload.old)
          onDelete?.(payload)
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log(`✅ Suscrito a cambios en tiempo real: ${table}`)
        } else if (status === 'CHANNEL_ERROR') {
          console.error(`❌ Error en canal de tiempo real: ${table}`)
        }
      })

    channelRef.current = channel

    // Cleanup al desmontar
    return () => {
      if (channelRef.current) {
        supabase.removeChannel(channelRef.current)
        console.log(`🔌 Desuscrito de cambios en tiempo real: ${table}`)
      }
    }
  }, [table, onInsert, onUpdate, onDelete, filter])

  return {
    isConnected: channelRef.current?.state === 'joined'
  }
}

// Hook específico para actualizar listas
export function useRealtimeList(
  table: string,
  loadData: () => Promise<void>,
  filter?: string
) {
  const handleInsert = () => {
    console.log(`📥 Nuevo elemento en ${table}, recargando datos...`)
    loadData()
  }

  const handleUpdate = () => {
    console.log(`📝 Elemento actualizado en ${table}, recargando datos...`)
    loadData()
  }

  const handleDelete = () => {
    console.log(`🗑️ Elemento eliminado en ${table}, recargando datos...`)
    loadData()
  }

  const { isConnected } = useRealtime({
    table,
    onInsert: handleInsert,
    onUpdate: handleUpdate,
    onDelete: handleDelete,
    filter
  })

  return { isConnected }
}

// Hook para estadísticas en tiempo real
export function useRealtimeStats(
  tables: string[],
  loadStats: () => Promise<void>
) {
  useEffect(() => {
    const handleChange = () => {
      console.log('📊 Cambio detectado, actualizando estadísticas...')
      loadStats()
    }

    const channels = tables.map(table => 
      supabase
        .channel(`stats:${table}`)
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table
          },
          handleChange
        )
        .subscribe()
    )

    return () => {
      channels.forEach(channel => {
        supabase.removeChannel(channel)
      })
    }
  }, [tables, loadStats])
}
