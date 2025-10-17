-- Crear tabla invoices para facturación electrónica
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id TEXT UNIQUE NOT NULL,
  company_id UUID REFERENCES companies(id),
  zone_id UUID REFERENCES zones(id),
  zone_name TEXT,
  plate TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_method TEXT,
  duration_minutes INTEGER,
  start_time TIMESTAMP WITH TIME ZONE,
  end_time TIMESTAMP WITH TIME ZONE,
  kiosco_id TEXT,
  is_extend BOOLEAN DEFAULT false,
  fiscal_name TEXT,
  fiscal_nif TEXT,
  fiscal_address TEXT,
  fiscal_city TEXT,
  fiscal_postal_code TEXT,
  fiscal_email TEXT,
  fiscal_phone TEXT,
  invoice_number TEXT UNIQUE,
  invoice_pdf_url TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Public can insert invoices"
  ON invoices FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Public can read invoices by ticket_id"
  ON invoices FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can update invoices"
  ON invoices FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete invoices"
  ON invoices FOR DELETE
  TO authenticated
  USING (true);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_invoices_ticket_id ON invoices(ticket_id);
CREATE INDEX IF NOT EXISTS idx_invoices_company_id ON invoices(company_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON invoices(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_invoices_plate ON invoices(plate);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at
CREATE TRIGGER update_invoices_updated_at 
    BEFORE UPDATE ON invoices 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
