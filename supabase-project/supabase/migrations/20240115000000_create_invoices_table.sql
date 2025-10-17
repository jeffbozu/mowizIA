-- Migration: Create invoices table for electronic invoicing system
-- Date: 2024-01-15
-- Description: Table to store ticket transactions for electronic invoice generation

-- Create invoices table
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id TEXT UNIQUE NOT NULL,
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
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

-- Enable Row Level Security
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
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

-- Create indexes for performance
CREATE INDEX idx_invoices_ticket_id ON invoices(ticket_id);
CREATE INDEX idx_invoices_company_id ON invoices(company_id);
CREATE INDEX idx_invoices_zone_id ON invoices(zone_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_created_at ON invoices(created_at DESC);
CREATE INDEX idx_invoices_plate ON invoices(plate);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_invoices_updated_at 
    BEFORE UPDATE ON invoices 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to generate invoice number
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TEXT AS $$
DECLARE
    year_part TEXT;
    month_part TEXT;
    sequence_num INTEGER;
    invoice_num TEXT;
BEGIN
    -- Get current year and month
    year_part := EXTRACT(YEAR FROM NOW())::TEXT;
    month_part := LPAD(EXTRACT(MONTH FROM NOW())::TEXT, 2, '0');
    
    -- Get next sequence number for this month
    SELECT COALESCE(MAX(CAST(SUBSTRING(invoice_number FROM 8) AS INTEGER)), 0) + 1
    INTO sequence_num
    FROM invoices 
    WHERE invoice_number LIKE 'INV-' || year_part || month_part || '%';
    
    -- Format: INV-YYYYMM-XXXX
    invoice_num := 'INV-' || year_part || month_part || '-' || LPAD(sequence_num::TEXT, 4, '0');
    
    RETURN invoice_num;
END;
$$ LANGUAGE plpgsql;

-- Create function to auto-generate invoice number when status changes to completed
CREATE OR REPLACE FUNCTION auto_generate_invoice_number()
RETURNS TRIGGER AS $$
BEGIN
    -- Only generate invoice number when status changes to 'completed' and invoice_number is null
    IF NEW.status = 'completed' AND (OLD.status != 'completed' OR OLD.status IS NULL) AND NEW.invoice_number IS NULL THEN
        NEW.invoice_number := generate_invoice_number();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_generate_invoice_number_trigger
    BEFORE UPDATE ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_invoice_number();

-- Insert sample data for testing (optional)
-- INSERT INTO invoices (
--   ticket_id,
--   company_id,
--   zone_id,
--   zone_name,
--   plate,
--   amount,
--   payment_method,
--   duration_minutes,
--   start_time,
--   end_time,
--   kiosco_id,
--   status
-- ) VALUES (
--   'TXN_TEST_001',
--   (SELECT id FROM companies WHERE name = 'MOWIZ' LIMIT 1),
--   (SELECT id FROM zones WHERE name = 'Zona Centro' LIMIT 1),
--   'Zona Centro',
--   '1234ABC',
--   2.50,
--   'cash',
--   60,
--   NOW() - INTERVAL '1 hour',
--   NOW(),
--   'KIOSK_001',
--   'pending'
-- );

-- Create view for invoice statistics
CREATE VIEW invoice_stats AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_invoices,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_invoices,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_invoices,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_invoices,
    SUM(amount) as total_amount,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as completed_amount,
    AVG(amount) as avg_amount
FROM invoices
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Grant permissions
GRANT SELECT ON invoice_stats TO authenticated;
GRANT SELECT ON invoice_stats TO anon;

-- Add comments for documentation
COMMENT ON TABLE invoices IS 'Stores ticket transactions for electronic invoice generation';
COMMENT ON COLUMN invoices.ticket_id IS 'Unique ticket identifier from Flutter app';
COMMENT ON COLUMN invoices.company_id IS 'Reference to companies table';
COMMENT ON COLUMN invoices.zone_id IS 'Reference to zones table';
COMMENT ON COLUMN invoices.zone_name IS 'Zone name for display purposes';
COMMENT ON COLUMN invoices.plate IS 'Vehicle license plate';
COMMENT ON COLUMN invoices.amount IS 'Total amount paid (including taxes)';
COMMENT ON COLUMN invoices.payment_method IS 'Payment method used (cash, card, etc.)';
COMMENT ON COLUMN invoices.duration_minutes IS 'Parking duration in minutes';
COMMENT ON COLUMN invoices.start_time IS 'Parking start time';
COMMENT ON COLUMN invoices.end_time IS 'Parking end time';
COMMENT ON COLUMN invoices.kiosco_id IS 'Kiosk identifier where payment was made';
COMMENT ON COLUMN invoices.is_extend IS 'Whether this is an extension of existing parking';
COMMENT ON COLUMN invoices.fiscal_name IS 'Company name for invoice';
COMMENT ON COLUMN invoices.fiscal_nif IS 'Tax ID (NIF/CIF) for invoice';
COMMENT ON COLUMN invoices.fiscal_address IS 'Company address for invoice';
COMMENT ON COLUMN invoices.fiscal_city IS 'Company city for invoice';
COMMENT ON COLUMN invoices.fiscal_postal_code IS 'Company postal code for invoice';
COMMENT ON COLUMN invoices.fiscal_email IS 'Company email for invoice';
COMMENT ON COLUMN invoices.fiscal_phone IS 'Company phone for invoice';
COMMENT ON COLUMN invoices.invoice_number IS 'Auto-generated invoice number';
COMMENT ON COLUMN invoices.invoice_pdf_url IS 'URL to generated PDF in Supabase Storage';
COMMENT ON COLUMN invoices.status IS 'Invoice status: pending, completed, failed';
