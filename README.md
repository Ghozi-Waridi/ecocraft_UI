# EcoCraft Flutter Application

Aplikasi mobile dan web untuk sistem perhitungan botol plastik dengan reward untuk top contributors.

## 🚀 Fitur

### User Features
- ✅ Login dengan username
- ✅ Dashboard dengan statistik personal
- ✅ Leaderboard top 10 contributors
- ✅ Profile dengan riwayat reward
- ✅ Real-time update data

### Admin Features
- ✅ Dashboard dengan overview statistik
- ✅ User management (lihat semua user)
- ✅ Increment jumlah botol user
- ✅ Reward management (manual & otomatis)
- ✅ Award top 3 users otomatis

## 📋 Prerequisites

- Flutter SDK (3.9.0 atau lebih baru)
- Dart SDK
- Supabase account
- PostgreSQL database (via Supabase)

## 🛠️ Setup

### 1. Clone & Install Dependencies

```bash
cd /Users/ghoziwaridi/PEMOGRAMAN/flutter/ecocraft
flutter pub get
```

### 2. Setup Supabase Database

1. Buat project baru di [Supabase](https://supabase.com)
2. Jalankan SQL berikut di SQL Editor:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    role VARCHAR(20) DEFAULT 'user',
    total_bottles INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create rewards table
CREATE TABLE rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reward_name VARCHAR(255) NOT NULL,
    reward_description TEXT,
    bottles_count INTEGER NOT NULL,
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_total_bottles ON users(total_bottles DESC);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_rewards_user ON rewards(user_id);
CREATE INDEX idx_rewards_awarded ON rewards(awarded_at DESC);

-- Create trigger for auto-update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_users_timestamp 
BEFORE UPDATE ON users
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();

-- Create leaderboard view
CREATE VIEW leaderboard AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY total_bottles DESC) as rank,
    id,
    username,
    full_name,
    total_bottles,
    created_at
FROM users
ORDER BY total_bottles DESC
LIMIT 10;

-- Create increment_bottles function
CREATE OR REPLACE FUNCTION increment_bottles(user_username TEXT, amount INT DEFAULT 1)
RETURNS void AS $$
BEGIN
    UPDATE users 
    SET total_bottles = total_bottles + amount,
        updated_at = CURRENT_TIMESTAMP
    WHERE username = user_username;
END;
$$ LANGUAGE plpgsql;

-- Insert sample data
INSERT INTO users (username, full_name, email, role, total_bottles) VALUES
    ('admin', 'Administrator', 'admin@ecocraft.com', 'admin', 0),
    ('user1', 'Ahmad Rizki', 'ahmad@example.com', 'user', 150),
    ('user2', 'Siti Nurhaliza', 'siti@example.com', 'user', 120),
    ('user3', 'Budi Santoso', 'budi@example.com', 'user', 95);
```

### 3. Configure Environment Variables

1. Copy `.env.example` ke `.env`:
```bash
cp .env.example .env
```

2. Edit `.env` dan isi dengan credentials Supabase Anda:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Dapatkan credentials dari: Supabase Dashboard → Settings → API

### 4. Run Application

#### Mobile (iOS/Android)
```bash
flutter run
```

#### Web
```bash
flutter run -d chrome
```

#### Desktop (macOS)
```bash
flutter run -d macos
```

## 🎮 Demo Credentials

### Admin
- Username: `admin`
- Password: (tidak diimplementasikan untuk demo)

### User
- Username: `user1`, `user2`, atau `user3`
- Password: (tidak diimplementasikan untuk demo)

> **Note**: Untuk production, implementasikan proper password hashing dengan bcrypt atau argon2.

## 📱 Struktur Aplikasi

```
lib/
├── config/           # Konfigurasi Supabase
├── models/           # Data models
├── services/         # API services
├── providers/        # State management
├── screens/          # UI screens
│   ├── auth/        # Login & splash
│   ├── user/        # User dashboard, leaderboard, profile
│   └── admin/       # Admin dashboard & management
├── widgets/          # Reusable widgets
└── utils/            # Constants & theme
```

## 🎨 Teknologi

- **Framework**: Flutter 3.9+
- **State Management**: Provider
- **Backend**: Supabase (PostgreSQL)
- **UI**: Material Design 3
- **Platform**: iOS, Android, Web, Desktop

## 📝 API Endpoints (Supabase)

### Leaderboard
```dart
GET /leaderboard
```

### Users
```dart
GET /users
POST /rpc/increment_bottles
```

### Rewards
```dart
GET /rewards?user_id=eq.{userId}
POST /rewards
```

## 🔧 Troubleshooting

### Error: Supabase not initialized
- Pastikan file `.env` sudah dibuat dan berisi credentials yang benar
- Restart aplikasi setelah membuat `.env`

### Error: Table not found
- Pastikan semua SQL sudah dijalankan di Supabase SQL Editor
- Cek di Supabase Dashboard → Table Editor

### Build error
```bash
flutter clean
flutter pub get
flutter run
```

## 📄 License

MIT License - Free to use for learning purposes

## 👨‍💻 Developer

Created for EcoCraft Project - November 2025
