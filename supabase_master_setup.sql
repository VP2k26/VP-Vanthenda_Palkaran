-- ==============================================================================
-- 🥛 VANTHENDA PAALKARAN — MASTER DATABASE INITIALIZATION SCRIPT
-- ==============================================================================
-- Architecture:
-- 1. VENDOR  (Dairy Owner / Admin) -> Business owner, sets rates, collects payments
-- 2. STAFF   (Delivery Boy)         -> Assigned to delivery routes, logs milk drop
-- 3. CUSTOMER (Subscriber)          -> Daily milk consumer, sets quota, pays bills
-- ==============================================================================

-- 1. Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 2. CORE MASTER TABLES
-- ==============================================================================

-- 🏢 VENDORS (Dairy Business Owner)
CREATE TABLE IF NOT EXISTS public.vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL DEFAULT 'Vanthenda Central Dairy',
    owner_name VARCHAR(255) NOT NULL DEFAULT 'Dairy Owner',
    phone VARCHAR(20) DEFAULT '9840123456',
    address TEXT DEFAULT 'Anna Nagar, Chennai',
    upi_id VARCHAR(100) DEFAULT 'paalkaran@oksbi',
    logo_url TEXT,
    gst_number VARCHAR(15),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ⚙️ VENDOR SETTINGS
CREATE TABLE IF NOT EXISTS public.vendor_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    default_language VARCHAR(10) DEFAULT 'ta',
    currency VARCHAR(10) DEFAULT 'INR',
    invoice_prefix VARCHAR(10) DEFAULT 'INV-',
    enable_notifications BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 🥛 MILK PRICING (Global Standard Milk Rate)
CREATE TABLE IF NOT EXISTS public.milk_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL DEFAULT 'Milk',
    description TEXT DEFAULT 'Pure Farm Fresh Milk',
    price_per_liter DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 🚴 STAFF (Delivery Boys & Field Workers under Vendor)
CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) NOT NULL DEFAULT 'Delivery Boy' CHECK (role IN ('Manager', 'Delivery Boy', 'Accountant')),
    assigned_route VARCHAR(255),
    passcode VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_staff_vendor_id ON public.staff(vendor_id);

-- 👤 CUSTOMERS (Subscribers receiving milk)
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    assigned_staff_id UUID REFERENCES public.staff(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    area VARCHAR(255),
    apartment VARCHAR(255),
    street VARCHAR(255),
    route VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    notes TEXT,
    customer_group VARCHAR(100) DEFAULT 'General',
    default_morning_qty DECIMAL(5, 2) DEFAULT 1.0,
    default_evening_qty DECIMAL(5, 2) DEFAULT 0.5,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_customers_vendor_id ON public.customers(vendor_id);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON public.customers(phone);

-- ==============================================================================
-- 3. DAILY OPERATIONS & DELIVERY LOGGING
-- ==============================================================================

-- 📦 DELIVERIES (Digital Milk Card Daily Entry)
CREATE TABLE IF NOT EXISTS public.deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    delivered_by_staff_id UUID REFERENCES public.staff(id) ON DELETE SET NULL,
    delivery_date DATE NOT NULL DEFAULT CURRENT_DATE,
    session VARCHAR(10) NOT NULL CHECK (session IN ('morning', 'evening')),
    quantity DECIMAL(5, 2) NOT NULL DEFAULT 1.0,
    price_per_liter DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    status VARCHAR(20) DEFAULT 'delivered' CHECK (status IN ('pending', 'delivered', 'cancelled', 'skipped')),
    delivery_time TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_deliveries_vendor_date ON public.deliveries(vendor_id, delivery_date);
CREATE INDEX IF NOT EXISTS idx_deliveries_customer ON public.deliveries(customer_id);

-- 🏖️ VACATIONS (Temporary Pause on Milk Deliveries)
CREATE TABLE IF NOT EXISTS public.vacations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 🚨 EMERGENCY / EXTRA MILK REQUESTS
CREATE TABLE IF NOT EXISTS public.emergency_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    request_date DATE NOT NULL DEFAULT CURRENT_DATE,
    type VARCHAR(50) DEFAULT 'extra_milk',
    quantity DECIMAL(5, 2) DEFAULT 1.0,
    note TEXT,
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 4. INVOICES, BILLING & PAYMENT COLLECTIONS
-- ==============================================================================

-- 🧾 BILLS (Monthly Customer Invoices)
CREATE TABLE IF NOT EXISTS public.bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    billing_month INTEGER NOT NULL,
    billing_year INTEGER NOT NULL,
    total_liters DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) DEFAULT 0,
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    amount_due DECIMAL(10, 2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'partial', 'paid')),
    is_paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMPTZ,
    payment_method VARCHAR(50),
    invoice_number VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bills_vendor_month ON public.bills(vendor_id, billing_year, billing_month);
CREATE INDEX IF NOT EXISTS idx_bills_customer ON public.bills(customer_id);

-- 💵 PAYMENTS (Cash & UPI Settlement Receipts)
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    bill_id UUID REFERENCES public.bills(id) ON DELETE SET NULL,
    collected_by_staff_id UUID REFERENCES public.staff(id) ON DELETE SET NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(50) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'upi', 'bank_transfer', 'online')),
    reference_id VARCHAR(100),
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 5. DATABASE FUNCTIONS & RPCs
-- ==============================================================================

-- Function to detect active vendor ID
CREATE OR REPLACE FUNCTION public.get_vendor_id()
RETURNS UUID AS $$
DECLARE
    v_vendor_id UUID;
BEGIN
    SELECT id INTO v_vendor_id FROM public.vendors WHERE user_id = auth.uid() LIMIT 1;
    IF v_vendor_id IS NULL THEN
        SELECT vendor_id INTO v_vendor_id FROM public.staff WHERE user_id = auth.uid() LIMIT 1;
    END IF;
    IF v_vendor_id IS NULL THEN
        SELECT vendor_id INTO v_vendor_id FROM public.customers WHERE user_id = auth.uid() LIMIT 1;
    END IF;
    IF v_vendor_id IS NULL THEN
        SELECT id INTO v_vendor_id FROM public.vendors LIMIT 1;
    END IF;
    RETURN v_vendor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to determine user role (vendor / staff / customer)
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
DECLARE
    v_role TEXT;
BEGIN
    IF EXISTS (SELECT 1 FROM public.vendors WHERE user_id = auth.uid()) THEN
        RETURN 'vendor';
    ELSIF EXISTS (SELECT 1 FROM public.staff WHERE user_id = auth.uid()) THEN
        RETURN 'staff';
    ELSIF EXISTS (SELECT 1 FROM public.customers WHERE user_id = auth.uid()) THEN
        RETURN 'customer';
    ELSE
        RETURN 'vendor';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Monthly Bill Generator
CREATE OR REPLACE FUNCTION public.generate_monthly_bills(p_vendor_id UUID, p_month INT, p_year INT)
RETURNS INT AS $$
DECLARE
    v_customer RECORD;
    v_total_liters DECIMAL(10,2);
    v_total_amount DECIMAL(10,2);
    v_bills_created INT := 0;
BEGIN
    FOR v_customer IN 
        SELECT id, name FROM public.customers WHERE vendor_id = p_vendor_id AND is_active = TRUE
    LOOP
        SELECT COALESCE(SUM(quantity), 0), COALESCE(SUM(total_amount), 0)
        INTO v_total_liters, v_total_amount
        FROM public.deliveries
        WHERE customer_id = v_customer.id
          AND EXTRACT(MONTH FROM delivery_date) = p_month
          AND EXTRACT(YEAR FROM delivery_date) = p_year
          AND status = 'delivered';

        INSERT INTO public.bills (
            vendor_id, customer_id, billing_month, billing_year,
            total_liters, total_amount, amount_due, is_paid, status, invoice_number
        ) VALUES (
            p_vendor_id, v_customer.id, p_month, p_year,
            v_total_liters, v_total_amount, v_total_amount, FALSE, 'pending',
            'INV-' || p_year || '-' || LPAD(p_month::text, 2, '0') || '-' || SUBSTRING(v_customer.id::text, 1, 6)
        )
        ON CONFLICT DO NOTHING;

        v_bills_created := v_bills_created + 1;
    END LOOP;
    RETURN v_bills_created;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.milk_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vacations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_requests ENABLE ROW LEVEL SECURITY;

-- Authenticated Full Access Policies
CREATE POLICY "Allow authenticated full access to vendors" ON public.vendors FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to vendor_settings" ON public.vendor_settings FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to milk_types" ON public.milk_types FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to staff" ON public.staff FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to customers" ON public.customers FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to deliveries" ON public.deliveries FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to bills" ON public.bills FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to payments" ON public.payments FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to vacations" ON public.vacations FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated full access to emergency_requests" ON public.emergency_requests FOR ALL TO authenticated USING (true);

-- Public / Anon Read Access (for quick demo & app startup)
CREATE POLICY "Allow anon read vendors" ON public.vendors FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anon read milk_types" ON public.milk_types FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anon read customers" ON public.customers FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anon read staff" ON public.staff FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anon read deliveries" ON public.deliveries FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anon read bills" ON public.bills FOR SELECT TO anon USING (true);

-- ==============================================================================
-- 7. INITIAL SEED DATA (Ready for immediate testing)
-- ==============================================================================

-- 🏢 1. Seed Vendor (Dairy Owner)
INSERT INTO public.vendors (id, business_name, owner_name, phone, upi_id, address)
VALUES ('00000000-0000-0000-0000-000000000001', 'Vanthenda Central Dairy', 'Dairy Owner', '9840123456', 'paalkaran@oksbi', 'Anna Nagar, Chennai')
ON CONFLICT (id) DO NOTHING;

-- 🥛 2. Seed Flat Milk Price (₹50.00/L)
INSERT INTO public.milk_types (id, vendor_id, name, price_per_liter)
VALUES ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Milk', 50.00)
ON CONFLICT (id) DO NOTHING;

-- 🚴 3. Seed Staff (Delivery Boys)
INSERT INTO public.staff (id, vendor_id, name, phone, role, assigned_route)
VALUES 
  ('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000001', 'Murugan', '9840111111', 'Delivery Boy', 'Anna Nagar Route 1'),
  ('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000001', 'Suresh', '9840222222', 'Delivery Boy', 'T Nagar Route 2')
ON CONFLICT (id) DO NOTHING;

-- 👤 4. Seed Customers (Subscribers)
INSERT INTO public.customers (id, vendor_id, assigned_staff_id, name, phone, area, default_morning_qty, default_evening_qty)
VALUES 
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000020', 'Karthik Raja', '9840123451', 'Anna Nagar', 1.0, 0.5),
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000021', 'Priya Sundaram', '9840123452', 'T Nagar', 1.5, 0.5),
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000020', 'Ramesh Kumar', '9840123453', 'Velachery', 1.0, 0.0)
ON CONFLICT (id) DO NOTHING;

-- 🧾 5. Seed Initial Customer Bills (Current Month)
INSERT INTO public.bills (vendor_id, customer_id, billing_month, billing_year, total_liters, total_amount, amount_due, is_paid, status, invoice_number)
VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000010', EXTRACT(MONTH FROM CURRENT_DATE)::INT, EXTRACT(YEAR FROM CURRENT_DATE)::INT, 45.0, 2250.0, 2250.0, FALSE, 'pending', 'INV-2026-08-001'),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000011', EXTRACT(MONTH FROM CURRENT_DATE)::INT, EXTRACT(YEAR FROM CURRENT_DATE)::INT, 60.0, 3000.0, 3000.0, FALSE, 'pending', 'INV-2026-08-002')
ON CONFLICT (id) DO NOTHING;
