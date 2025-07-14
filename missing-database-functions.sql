-- Missing Database Functions for Finance Hub
-- These functions are expected by the application but missing from migrations

-- 1. NANOID function for generating unique IDs
CREATE OR REPLACE FUNCTION nanoid(size integer DEFAULT 21, alphabet text DEFAULT '_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', additionalbytesfactor numeric DEFAULT 1.6)
RETURNS text
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    idSize int := size;
    mask int := (2 << cast(floor(log(length(alphabet) - 1) / log(2)) as int)) - 1;
    step int := cast(ceil(additionalbytesfactor * mask * idSize / length(alphabet)) AS int);
    id text := '';
    bytes bytea;
    byte int;
    i int;
BEGIN
    LOOP
        bytes := gen_random_bytes(step);
        i := 0;
        
        WHILE i < step AND length(id) < idSize LOOP
            byte := get_byte(bytes, i);
            IF (byte & mask) < length(alphabet) THEN
                id := id || substr(alphabet, 1 + (byte & mask), 1);
            END IF;
            i := i + 1;
        END LOOP;
        
        IF length(id) >= idSize THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN left(id, idSize);
END
$$;

-- 1a. NANOID function overload for single parameter
CREATE OR REPLACE FUNCTION nanoid(size integer)
RETURNS text
LANGUAGE plpgsql
VOLATILE
AS $$
BEGIN
    RETURN nanoid(size, '_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 1.6);
END
$$;

-- 2. GENERATE_INBOX function for team inbox IDs
CREATE OR REPLACE FUNCTION generate_inbox(size integer DEFAULT 10)
RETURNS text
LANGUAGE plpgsql
VOLATILE
AS $$
BEGIN
    RETURN 'inbox_' || nanoid(size);
END
$$;

-- 3. EXTRACT_PRODUCT_NAMES function for inbox search
CREATE OR REPLACE FUNCTION extract_product_names(products_json json)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    product_names text := '';
    product_record json;
BEGIN
    IF products_json IS NULL THEN
        RETURN '';
    END IF;
    
    FOR product_record IN SELECT value FROM json_array_elements(products_json)
    LOOP
        IF product_record->>'name' IS NOT NULL THEN
            product_names := product_names || ' ' || (product_record->>'name');
        END IF;
        
        IF product_record->>'description' IS NOT NULL THEN
            product_names := product_names || ' ' || (product_record->>'description');
        END IF;
    END LOOP;
    
    RETURN trim(product_names);
END
$$;

-- 4. GENERATE_INBOX_FTS function for full-text search
CREATE OR REPLACE FUNCTION generate_inbox_fts(display_name text, product_names text)
RETURNS tsvector
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN to_tsvector('english', 
        COALESCE(display_name, '') || ' ' || COALESCE(product_names, '')
    );
END
$$;

-- 5. GET_NEXT_INVOICE_NUMBER function for invoice numbering
CREATE OR REPLACE FUNCTION get_next_invoice_number(team_id_param text)
RETURNS text
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    next_number integer;
    invoice_number text;
    current_year text;
BEGIN
    current_year := EXTRACT(YEAR FROM CURRENT_DATE)::text;
    
    -- Get the highest invoice number for this team and year
    SELECT COALESCE(
        MAX(CAST(REGEXP_REPLACE(invoice_number, '[^0-9]', '', 'g') AS integer)),
        0
    ) + 1
    INTO next_number
    FROM invoices 
    WHERE team_id = team_id_param 
    AND invoice_number LIKE current_year || '%';
    
    -- If no invoices exist for this year, start with 1
    IF next_number IS NULL OR next_number = 1 THEN
        next_number := 1;
    END IF;
    
    -- Format: YYYY-0001, YYYY-0002, etc.
    invoice_number := current_year || '-' || LPAD(next_number::text, 4, '0');
    
    RETURN invoice_number;
END
$$;

-- 6. GET_PAYMENT_SCORE function for payment analytics
CREATE OR REPLACE FUNCTION get_payment_score(team_id_param text)
RETURNS TABLE(score numeric, payment_status text)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    total_invoices integer;
    paid_invoices integer;
    overdue_invoices integer;
    calculated_score numeric;
    status_text text;
BEGIN
    -- Count total invoices for the team
    SELECT COUNT(*) INTO total_invoices
    FROM invoices 
    WHERE team_id = team_id_param;
    
    -- If no invoices, return default score
    IF total_invoices = 0 THEN
        RETURN QUERY SELECT 85.0::numeric, 'good'::text;
        RETURN;
    END IF;
    
    -- Count paid invoices
    SELECT COUNT(*) INTO paid_invoices
    FROM invoices 
    WHERE team_id = team_id_param 
    AND status = 'paid';
    
    -- Count overdue invoices
    SELECT COUNT(*) INTO overdue_invoices
    FROM invoices 
    WHERE team_id = team_id_param 
    AND status = 'overdue'
    AND due_date < CURRENT_DATE;
    
    -- Calculate score (0-100)
    -- Base score is percentage of paid invoices
    calculated_score := (paid_invoices::numeric / total_invoices::numeric) * 100;
    
    -- Penalty for overdue invoices
    calculated_score := calculated_score - (overdue_invoices::numeric / total_invoices::numeric) * 20;
    
    -- Ensure score is between 0 and 100
    calculated_score := GREATEST(0, LEAST(100, calculated_score));
    
    -- Determine status text
    IF calculated_score >= 80 THEN
        status_text := 'excellent';
    ELSIF calculated_score >= 60 THEN
        status_text := 'good';
    ELSIF calculated_score >= 40 THEN
        status_text := 'fair';
    ELSE
        status_text := 'poor';
    END IF;
    
    RETURN QUERY SELECT calculated_score, status_text;
END
$$;

-- 7. CREATE INVOICES TABLE (missing from schema)
CREATE TABLE IF NOT EXISTS "invoices" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "team_id" uuid NOT NULL,
  "invoice_number" text NOT NULL,
  "status" text DEFAULT 'draft',
  "amount" numeric,
  "due_date" date,
  "customer_id" uuid,
  "customer_name" text,
  "customer_details" jsonb,
  "from_details" jsonb,
  "payment_details" jsonb,
  "note_details" jsonb,
  "line_items" jsonb,
  "currency" text DEFAULT 'USD',
  "tax" numeric,
  "discount" numeric,
  "subtotal" numeric,
  "vat" numeric,
  "template" jsonb,
  "user_id" uuid,
  "sent_at" timestamp with time zone,
  "paid_at" timestamp with time zone,
  "reminder_sent_at" timestamp with time zone,
  "token" text,
  CONSTRAINT "invoices_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE cascade,
  CONSTRAINT "invoices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE set null
);

-- Enable RLS for invoices
ALTER TABLE "invoices" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for invoices
CREATE POLICY "invoices_team_access" ON "invoices" 
  FOR ALL USING (true); -- Simplified for now

-- 8. CREATE INVOICE_TEMPLATES TABLE (missing from schema)
CREATE TABLE IF NOT EXISTS "invoice_templates" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "team_id" uuid NOT NULL,
  "title" text,
  "customer_label" text,
  "from_label" text,
  "invoice_no_label" text,
  "issue_date_label" text,
  "due_date_label" text,
  "description_label" text,
  "price_label" text,
  "quantity_label" text,
  "total_label" text,
  "subtotal_label" text,
  "vat_label" text,
  "tax_label" text,
  "payment_label" text,
  "note_label" text,
  "logo_url" text,
  "currency" text,
  "size" text,
  "include_vat" boolean DEFAULT true,
  "include_tax" boolean DEFAULT false,
  "include_discount" boolean DEFAULT false,
  "include_decimals" boolean DEFAULT false,
  "include_units" boolean DEFAULT false,
  "include_qr" boolean DEFAULT true,
  "include_pdf" boolean DEFAULT false,
  "send_copy" boolean DEFAULT false,
  "date_format" text,
  "delivery_type" text,
  "tax_rate" numeric DEFAULT 0,
  "vat_rate" numeric DEFAULT 0,
  "discount_label" text,
  "total_summary_label" text,
  "payment_details" jsonb,
  "from_details" jsonb,
  CONSTRAINT "invoice_templates_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE cascade
);

-- Enable RLS for invoice_templates
ALTER TABLE "invoice_templates" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for invoice_templates
CREATE POLICY "invoice_templates_team_access" ON "invoice_templates" 
  FOR ALL USING (true); -- Simplified for now

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION nanoid(integer, text, numeric) TO authenticated;
GRANT EXECUTE ON FUNCTION nanoid(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION generate_inbox(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION extract_product_names(json) TO authenticated;
GRANT EXECUTE ON FUNCTION generate_inbox_fts(text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION get_next_invoice_number(text) TO authenticated;
GRANT EXECUTE ON FUNCTION get_payment_score(text) TO authenticated;