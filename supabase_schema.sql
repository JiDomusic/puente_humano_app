-- ==============================================
-- ESQUEMA DE BASE DE DATOS PARA PUENTEHUMANO
-- ==============================================

-- Configurar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================
-- TABLA: users (Usuarios del sistema)
-- ==============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('donante', 'transportista', 'biblioteca')),
    language VARCHAR(5) DEFAULT 'es',
    phone VARCHAR(50),
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    photo TEXT,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    ratings_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- TABLA: libraries (Bibliotecas comunitarias)
-- ==============================================
CREATE TABLE libraries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    library_code VARCHAR(20) UNIQUE NOT NULL, -- LIB-001, LIB-002, etc.
    name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(50),
    address TEXT NOT NULL,
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    needs TEXT, -- "Infantiles, diccionarios, novelas"
    received_count INTEGER DEFAULT 0,
    about TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- TABLA: trips (Viajes de transportistas)
-- ==============================================
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_code VARCHAR(20) UNIQUE NOT NULL, -- TRIP-001, TRIP-002, etc.
    traveler_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    origin_city VARCHAR(255) NOT NULL,
    origin_country VARCHAR(255) NOT NULL,
    origin_lat DECIMAL(10, 8) NOT NULL,
    origin_lng DECIMAL(11, 8) NOT NULL,
    dest_city VARCHAR(255) NOT NULL,
    dest_country VARCHAR(255) NOT NULL,
    dest_lat DECIMAL(10, 8) NOT NULL,
    dest_lng DECIMAL(11, 8) NOT NULL,
    depart_date DATE NOT NULL,
    arrive_date DATE NOT NULL,
    capacity_kg DECIMAL(5, 2) NOT NULL,
    used_kg DECIMAL(5, 2) DEFAULT 0,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'activo' CHECK (status IN ('activo', 'completado', 'cancelado')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- TABLA: donations (Libros donados)
-- ==============================================
CREATE TABLE donations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donation_code VARCHAR(20) UNIQUE NOT NULL, -- DON-001, DON-002, etc.
    donor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    author VARCHAR(255) NOT NULL,
    weight_kg DECIMAL(5, 2) NOT NULL,
    target_library_id UUID NOT NULL REFERENCES libraries(id),
    notes TEXT,
    status VARCHAR(20) DEFAULT 'pendiente' CHECK (status IN ('pendiente', 'en_camino', 'entregado')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- TABLA: shipments (Envíos - empareja donación + viaje)
-- ==============================================
CREATE TABLE shipments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_code VARCHAR(20) UNIQUE NOT NULL, -- SHIP-001, SHIP-002, etc.
    donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE CASCADE,
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    traveler_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    donor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_library_id UUID NOT NULL REFERENCES libraries(id),
    status VARCHAR(20) DEFAULT 'en_camino' CHECK (status IN ('en_camino', 'entregado')),
    pin VARCHAR(10) NOT NULL,
    qr_text VARCHAR(50) NOT NULL,
    scan_value VARCHAR(50),
    pin_ingresado VARCHAR(10),
    delivered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- TABLA: ratings (Calificaciones entre usuarios)
-- ==============================================
CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    about_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shipment_id UUID REFERENCES shipments(id) ON DELETE SET NULL,
    role_of_about VARCHAR(20) NOT NULL,
    stars INTEGER NOT NULL CHECK (stars >= 1 AND stars <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(about_user_id, by_user_id, shipment_id)
);

-- ==============================================
-- TABLA: chats (Mensajes de chat)
-- ==============================================
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id UUID NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- TABLA: notifications (Notificaciones)
-- ==============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'shipment_created', 'trip_matched', 'delivery_confirmed', etc.
    reference_id UUID, -- ID del shipment, trip, etc.
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- FUNCIONES Y TRIGGERS
-- ==============================================

-- Función para generar PIN automático
CREATE OR REPLACE FUNCTION generate_pin()
RETURNS VARCHAR(6) AS $$
BEGIN
    RETURN LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar promedio de ratings
CREATE OR REPLACE FUNCTION update_user_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users 
    SET 
        average_rating = (
            SELECT COALESCE(AVG(stars), 0)
            FROM ratings 
            WHERE about_user_id = NEW.about_user_id
        ),
        ratings_count = (
            SELECT COUNT(*)
            FROM ratings 
            WHERE about_user_id = NEW.about_user_id
        )
    WHERE id = NEW.about_user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar ratings
CREATE TRIGGER trigger_update_user_rating
    AFTER INSERT OR UPDATE ON ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_user_rating();

-- Trigger para generar PIN y QR en shipments
CREATE OR REPLACE FUNCTION generate_shipment_codes()
RETURNS TRIGGER AS $$
BEGIN
    NEW.pin = generate_pin();
    NEW.qr_text = 'SHIP-' || NEW.shipment_code;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_shipment_codes
    BEFORE INSERT ON shipments
    FOR EACH ROW
    EXECUTE FUNCTION generate_shipment_codes();

-- ==============================================
-- POLÍTICAS RLS (Row Level Security)
-- ==============================================

-- Activar RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE libraries ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Políticas para users
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Anyone can view public user info" ON users FOR SELECT USING (true);

-- Políticas para libraries
CREATE POLICY "Anyone can view libraries" ON libraries FOR SELECT USING (true);

-- Políticas para trips
CREATE POLICY "Anyone can view active trips" ON trips FOR SELECT USING (status = 'activo');
CREATE POLICY "Travelers can manage own trips" ON trips FOR ALL USING (auth.uid() = traveler_id);

-- Políticas para donations
CREATE POLICY "Anyone can view pending donations" ON donations FOR SELECT USING (status = 'pendiente');
CREATE POLICY "Donors can manage own donations" ON donations FOR ALL USING (auth.uid() = donor_id);

-- Políticas para shipments
CREATE POLICY "Participants can view shipments" ON shipments FOR SELECT USING (
    auth.uid() = traveler_id OR auth.uid() = donor_id OR 
    EXISTS (SELECT 1 FROM libraries WHERE id = target_library_id AND contact_email = (SELECT email FROM users WHERE id = auth.uid()))
);

-- Políticas para ratings
CREATE POLICY "Anyone can view ratings" ON ratings FOR SELECT USING (true);
CREATE POLICY "Users can create ratings" ON ratings FOR INSERT WITH CHECK (auth.uid() = by_user_id);

-- Políticas para chats
CREATE POLICY "Participants can access chat" ON chats FOR ALL USING (
    EXISTS (
        SELECT 1 FROM shipments 
        WHERE id = shipment_id AND (traveler_id = auth.uid() OR donor_id = auth.uid())
    )
);

-- Políticas para notifications
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- ==============================================
-- DATOS DE EJEMPLO
-- ==============================================

-- Insertar datos de ejemplo
INSERT INTO libraries (library_code, name, contact_email, contact_phone, address, city, country, lat, lng, needs, about) VALUES
('LIB-001', 'Biblioteca Popular Sol', 'biblio1@mail.com', '+54 9 261 555-3333', 'San Martín 123', 'Mendoza', 'Argentina', -32.8895, -68.8458, 'Infantiles, diccionarios, novelas', 'Biblioteca comunitaria en zona periurbana'),
('LIB-002', 'Biblioteca Escolar Esperanza', 'esperanza@mail.com', '+54 9 387 555-6666', 'Rivadavia 456', 'Salta', 'Argentina', -24.7821, -65.4232, 'Educativos, ciencias, matemáticas', 'Escuela rural necesita material educativo'),
('LIB-003', 'Centro Cultural Norte', 'centro@mail.com', '+54 9 223 555-7777', 'Belgrano 789', 'Mar del Plata', 'Argentina', -38.0055, -57.5426, 'Literatura, arte, filosofía', 'Centro comunitario con biblioteca pública');