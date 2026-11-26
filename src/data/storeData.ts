export type RobuxMethodId = '5hari' | 'username' | 'login';

export interface RobuxPackage {
  id: string;
  methodId: RobuxMethodId;
  robux: number;
  price: number;
  priceRangeLabel?: string;
  altPrice?: number;
  perRobuxLabel: string;
  badge?: string;
  isPopular?: boolean;
  isCustomEceran?: boolean;
  note?: string;
}

export interface RobuxMethodInfo {
  id: RobuxMethodId;
  title: string;
  shortTitle: string;
  subtitle: string;
  rateSummary: string;
  processTime: string;
  referenceNote: string;
  badgeText: string;
  badgeColor: 'emerald' | 'sky' | 'indigo';
  requirements: string[];
  steps: string[];
}

export interface GameItemProduct {
  id: string;
  game: 'Blox Fruits' | 'Dress To Impress' | 'Blade Ball' | 'King Legacy';
  name: string;
  category: 'Gamepass' | 'Permanent Fruit' | 'Item & Bundle';
  robuxValue: number;
  price: number;
  deliveryMethod: string;
  processTime: string;
  stockStatus: 'Tersedia' | 'Stok Terbatas';
  badge?: string;
  description: string;
}

export interface RobloxAccountProduct {
  id: string;
  code: string;
  title: string;
  gameFocus: string;
  price: number;
  specs: string[];
  emailStatus: 'Polosan (Belum Verif Email)' | 'Verified (Siap Ganti Email Pembeli)';
  ageStatus: 'Akun 13+' | 'Akun 18+ Verified';
  stock: number;
  badge?: string;
}

export type JokiCategoryId = 'grind' | 'race' | 'sword' | 'melee' | 'raid';

export interface JokiCategory {
  id: JokiCategoryId;
  label: string;
  shortLabel: string;
  intro: string;
}

export interface JokiService {
  id: string;
  categoryId: JokiCategoryId;
  name: string;
  priceMin: number;
  priceMax: number;
  // Kalau diisi, harga dihitung per satuan ini (mis. "per 100 level") dan pembeli bisa atur jumlahnya
  unit?: string;
  maxQty?: number;
  requirement?: string;
  badge?: string;
}

export interface JokiOrderPayload {
  invoiceId: string;
  serviceName: string;
  categoryLabel: string;
  qty: number;
  unit?: string;
  priceMin: number;
  priceMax: number;
  robloxUsername: string;
  currentProgress?: string;
  note?: string;
  paymentMethodName: string;
}

export interface PaymentMethod {
  id: string;
  name: string;
  category: 'QRIS' | 'E-Wallet' | 'Bank Transfer';
  feeText: string;
  accountHint: string;
  popular?: boolean;
}

export interface SavedOrder {
  invoiceId: string;
  createdAt: string;
  orderType: 'robux' | 'item' | 'account' | 'joki';
  title: string;
  methodLabel: string;
  targetAccount: string;
  paymentMethod: string;
  totalPrice: number;
  whatsappUrl: string;
}

// GANTI dengan nomor WhatsApp tokomu (format 628xxxxxxxxxx)
export const STORE_WA = '6283144027784';

// Metode yang stoknya lagi kosong (hapus dari daftar ini kalau sudah ready lagi)
export const OUT_OF_STOCK_METHODS: RobuxMethodId[] = ['5hari'];

export const ROBUX_METHODS: RobuxMethodInfo[] = [
  {
    id: '5hari',
    title: '1. Robux 5 Hari (5H / Gamepass)',
    shortTitle: 'Robux 5 Hari (Gamepass)',
    subtitle: 'Harga paling terjangkau (~Rp130–Rp155 per 1 Robux) via beli Gamepass',
    rateSummary: 'Rp130 – Rp155 / 1 R$',
    processTime: 'Cair Setelah 5 Hari Kerja (Pending Roblox)',
    referenceNote: 'Referensi harga hemat marketplace itemku • Pajak 30% Roblox otomatis dihitung',
    badgeText: 'Paling murah',
    badgeColor: 'emerald',
    requirements: [
      'Memiliki Experience / Map default di akun Roblox kamu.',
      'Membuat Gamepass sesuai nominal yang dihitung kalkulator (Pajak 30% Roblox ditanggung toko).',
      'Nonaktifkan fitur "Regional Pricing" pada pengaturan Gamepass.',
      'Saldo Robux akan masuk ke Pending Robux setelah dibeli toko dan cair otomatis dalam 5 hari (5x24 jam).',
    ],
    steps: [
      'Pilih nominal Robux 5H atau ketik jumlah eceran bebas.',
      'Masukkan Username Roblox dan buat Gamepass sesuai angka di Kalkulator Pajak.',
      'Lakukan pembayaran dan konfirmasi lewat WhatsApp Lvysky Store.',
    ],
  },
  {
    id: 'username',
    title: '2. Robux Via Username (Instan / Transfer)',
    shortTitle: 'Via Username (Instan)',
    subtitle: 'Proses kilat 5–10 menit tanpa password (rata-rata Rp155 – Rp160 / 1 Robux)',
    rateSummary: '~Rp155 – Rp160 / 1 R$',
    processTime: 'Instan 5 – 10 Menit (Tanpa Password)',
    referenceNote: 'Referensi harga Mbongshop • Aman 100% tanpa perlu login ke akunmu',
    badgeText: 'Tanpa password',
    badgeColor: 'sky',
    requirements: [
      'Wajib Akun Roblox sudah berusia 18+ (Verified Age / pengaturan umur 18 tahun ke atas).',
      'Wajib Verifikasi 2 Langkah (2-Step Verification / 2FA) dalam keadaan AKTIF.',
      'Tidak perlu memberikan password akun sama sekali (cukup Username Roblox yang benar).',
    ],
    steps: [
      'Pastikan akunmu sudah 18+ dan Verifikasi 2 Langkah (2FA) aktif.',
      'Pilih paket Robux Via Username dan ketik Username Roblox kamu.',
      'Klik Order ke WhatsApp, transfer Robux diproses dalam 5–10 menit.',
    ],
  },
  {
    id: 'login',
    title: '3. Robux Via Login (In-App Resmi)',
    shortTitle: 'Robux Via Login',
    subtitle: 'Top up resmi langsung di dalam aplikasi, diproses oleh tim Lvysky Store',
    rateSummary: 'Paket Resmi 80 R$ – 1.000 R$',
    processTime: '10 – 25 Menit (Sesuai Antrean)',
    referenceNote: 'Robux langsung masuk tanpa nunggu 5 hari • Privasi akun dijamin aman',
    badgeText: 'Langsung masuk',
    badgeColor: 'indigo',
    requirements: [
      'Menyiapkan Username dan Password akun Roblox yang valid.',
      'Jika 2-Step Verification (2FA) aktif, siapkan 1 kode Backup Code (9 digit) atau standby kirim OTP di WhatsApp.',
      'Jangan buka/login game selama pesananmu sedang kami proses (sekitar 5–10 menit saat giliranmu).',
    ],
    steps: [
      'Pilih nominal paket Robux Via Login (80 R$ s/d 1.000 R$).',
      'Isi Username Roblox dan catatan keamanan / Backup Code.',
      'Kirim form order lewat WhatsApp untuk langsung diproses.',
    ],
  },
];

export const ROBUX_PACKAGES: RobuxPackage[] = [
  // 1. ROBUX 5 HARI (5H / GAMEPASS)
  {
    id: '5h-eceran',
    methodId: '5hari',
    robux: 1,
    price: 155,
    perRobuxLabel: '~Rp155 / 1 Robux',
    badge: 'Bisa Eceran Bebas',
    isCustomEceran: true,
    note: 'Bebas atur jumlah Robux eceran (kelipatan Rp155/R$)',
  },
  {
    id: '5h-100',
    methodId: '5hari',
    robux: 100,
    price: 16500,
    perRobuxLabel: 'Rp165 / 1 R$',
    note: 'Set harga Gamepass: 143 R$',
  },
  {
    id: '5h-500',
    methodId: '5hari',
    robux: 500,
    price: 65000,
    perRobuxLabel: 'Rp130 / 1 R$ (paling murah)',
    badge: 'Paling sering dibeli',
    isPopular: true,
    note: 'Set harga Gamepass: 715 R$ • Rate Rp130/R$',
  },
  {
    id: '5h-1000',
    methodId: '5hari',
    robux: 1000,
    price: 155000,
    perRobuxLabel: 'Rp155 / 1 R$',
    note: 'Set harga Gamepass: 1.429 R$',
  },

  // 2. ROBUX VIA USERNAME (INSTAN / TRANSFER)
  {
    id: 'user-100',
    methodId: 'username',
    robux: 100,
    price: 16000,
    perRobuxLabel: 'Rp160 / 1 R$',
        isPopular: true,
    note: 'Sekitar 5–10 menit, tanpa password',
  },
  {
    id: 'user-200',
    methodId: 'username',
    robux: 200,
    price: 32000,
    perRobuxLabel: 'Rp160 / 1 R$',
    note: 'Sekitar 5–10 menit, tanpa password',
  },
  {
    id: 'user-400',
    methodId: 'username',
    robux: 400,
    price: 64000,
    perRobuxLabel: 'Rp160 / 1 R$',
    note: 'Sekitar 5–10 menit, tanpa password',
  },
  {
    id: 'user-500',
    methodId: 'username',
    robux: 500,
    price: 80000,
    perRobuxLabel: 'Rp160 / 1 R$',
        note: 'Sekitar 5–10 menit, tanpa password',
  },
  {
    id: 'user-800',
    methodId: 'username',
    robux: 800,
    price: 128000,
    perRobuxLabel: 'Rp160 / 1 R$',
    note: 'Sekitar 5–10 menit, tanpa password',
  },
  {
    id: 'user-1000',
    methodId: 'username',
    robux: 1000,
    price: 160000,
    perRobuxLabel: 'Rp160 / 1 R$',
        note: 'Sekitar 5–10 menit, tanpa password',
  },
  {
    id: 'user-2000',
    methodId: 'username',
    robux: 2000,
    price: 320000,
    perRobuxLabel: 'Rp160 / 1 R$',
        note: 'Sekitar 5–10 menit, tanpa password',
  },

  // 3. ROBUX VIA LOGIN
  {
    id: 'login-80',
    methodId: 'login',
    robux: 80,
    price: 16500,
    perRobuxLabel: '~Rp206 / 1 R$',
    note: 'Top up resmi lewat aplikasi',
  },
  {
    id: 'login-160',
    methodId: 'login',
    robux: 160,
    price: 31000,
    perRobuxLabel: '~Rp193 / 1 R$',
    note: 'Top up resmi lewat aplikasi',
  },
  {
    id: 'login-240',
    methodId: 'login',
    robux: 240,
    price: 46500,
    perRobuxLabel: '~Rp193 / 1 R$',
    note: 'Top up resmi lewat aplikasi',
  },
  {
    id: 'login-320',
    methodId: 'login',
    robux: 320,
    price: 62000,
    perRobuxLabel: '~Rp193 / 1 R$',
    note: 'Top up resmi lewat aplikasi',
  },
  {
    id: 'login-500',
    methodId: 'login',
    robux: 500,
    price: 77500,
    altPrice: 81000,
    priceRangeLabel: 'Rp77.500 – Rp81.000',
    perRobuxLabel: 'Rp155 – Rp162 / 1 R$',
    badge: 'Paling sering dibeli',
    isPopular: true,
    note: 'Reguler Rp77.500 / Prioritas Pack Rp81.000',
  },
  {
    id: 'login-800',
    methodId: 'login',
    robux: 800,
    price: 144769,
    perRobuxLabel: '~Rp181 / 1 R$',
    note: 'Top up resmi lewat aplikasi',
  },
  {
    id: 'login-1000',
    methodId: 'login',
    robux: 1000,
    price: 162000,
    perRobuxLabel: 'Rp162 / 1 R$',
        note: 'Top up resmi lewat aplikasi',
  },
];

export const GAME_ITEMS: GameItemProduct[] = [
  {
    id: 'item-bf-2xmastery',
    game: 'Blox Fruits',
    name: '2x Mastery Gamepass',
    category: 'Gamepass',
    robuxValue: 450,
    price: 62000,
    deliveryMethod: 'Gift In-Game (Tanpa Login)',
    processTime: '5 – 10 Menit',
    stockStatus: 'Tersedia',
    badge: 'Sering dibeli',
    description: 'Dikirim lewat Gift, cukup kasih username Roblox.',
  },
  {
    id: 'item-bf-2xmoney',
    game: 'Blox Fruits',
    name: '2x Money Gamepass',
    category: 'Gamepass',
    robuxValue: 450,
    price: 62000,
    deliveryMethod: 'Gift In-Game (Tanpa Login)',
    processTime: '5 – 10 Menit',
    stockStatus: 'Tersedia',
    description: 'Belly yang kamu dapat jadi dua kali lipat. Dikirim lewat fitur Gift.',
  },
  {
    id: 'item-bf-storage',
    game: 'Blox Fruits',
    name: '+1 Fruit Storage',
    category: 'Gamepass',
    robuxValue: 400,
    price: 55000,
    deliveryMethod: 'Gift In-Game (Tanpa Login)',
    processTime: '5 – 10 Menit',
    stockStatus: 'Tersedia',
        description: 'Tambah kapasitas penyimpanan buah di inventory Blox Fruits.',
  },
  {
    id: 'item-bf-perm-buddha',
    game: 'Blox Fruits',
    name: 'Permanent Buddha Fruit',
    category: 'Permanent Fruit',
    robuxValue: 1650,
    price: 222000,
    deliveryMethod: 'Gift In-Game (Tanpa Login)',
    processTime: '5 – 15 Menit',
    stockStatus: 'Tersedia',
        description: 'Buah yang enak buat grinding di Sea 1 sampai 3, permanen.',
  },
  {
    id: 'item-bf-perm-portal',
    game: 'Blox Fruits',
    name: 'Permanent Portal Fruit',
    category: 'Permanent Fruit',
    robuxValue: 2000,
    price: 268000,
    deliveryMethod: 'Gift In-Game (Tanpa Login)',
    processTime: '5 – 15 Menit',
    stockStatus: 'Tersedia',
    description: 'Bisa teleport antar pulau, enak juga buat PvP. Permanen.',
  },
  {
    id: 'item-bf-darkblade',
    game: 'Blox Fruits',
    name: 'Dark Blade (Yoru)',
    category: 'Gamepass',
    robuxValue: 1200,
    price: 162000,
    deliveryMethod: 'Gift In-Game (Tanpa Login)',
    processTime: '5 – 10 Menit',
    stockStatus: 'Tersedia',
    description: 'Pedang Yoru, dikirim lewat Gift in-game.',
  },
  {
    id: 'item-dti-vip',
    game: 'Dress To Impress',
    name: 'Permanent VIP Pass (DTI)',
    category: 'Gamepass',
    robuxValue: 799,
    price: 112000,
    deliveryMethod: 'Gift Prop In-Game',
    processTime: '5 – 15 Menit',
    stockStatus: 'Tersedia',
    badge: 'Sering dibeli',
    description: 'Akses ruang VIP Dress To Impress, sekali beli untuk seterusnya.',
  },
  {
    id: 'item-dti-makeup',
    game: 'Dress To Impress',
    name: 'Custom Makeup Pass (DTI)',
    category: 'Gamepass',
    robuxValue: 349,
    price: 49000,
    deliveryMethod: 'Gift Prop In-Game',
    processTime: '5 – 15 Menit',
    stockStatus: 'Tersedia',
    description: 'Buka fitur kustomisasi wajah dan makeup di Dress To Impress.',
  },
  {
    id: 'item-bb-pass',
    game: 'Blade Ball',
    name: 'Season Battlepass / 1.000 Token',
    category: 'Item & Bundle',
    robuxValue: 799,
    price: 110000,
    deliveryMethod: 'Gift In-Game',
    processTime: '5 – 15 Menit',
    stockStatus: 'Stok Terbatas',
    description: 'Battlepass atau token Blade Ball, dikirim lewat Gift.',
  },
  {
    id: 'item-kl-2xdrop',
    game: 'King Legacy',
    name: 'Legacy Pose / 2x Drop Chance',
    category: 'Gamepass',
    robuxValue: 400,
    price: 55000,
    deliveryMethod: 'Gift In-Game',
    processTime: '5 – 15 Menit',
    stockStatus: 'Tersedia',
    description: 'Naikin peluang drop dari boss di King Legacy.',
  },
];

export const ROBLOX_ACCOUNTS: RobloxAccountProduct[] = [
  {
    id: 'acc-bf-max-godhuman',
    code: 'LVY-ACC01',
    title: 'Akun Blox Fruits Max Level 2600 + Godhuman + CDK + Soul Guitar',
    gameFocus: 'Blox Fruits',
    price: 45000,
    specs: [
      'Level 2600 (MAX) • Fighting Style Godhuman Unlock',
      'Cursed Dual Katana (CDK) & Soul Guitar Full Mastery',
      'Belly 25 juta+ dan fragment 40.000+',
      'Ada Mythical Fruit di inventory',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 7,
    badge: 'Sering dibeli',
  },
  {
    id: 'acc-bf-kitsune',
    code: 'LVY-ACC02',
    title: 'Akun Blox Fruits Max Level + Equipped Kitsune / Gas + Sanguine Art',
    gameFocus: 'Blox Fruits',
    price: 85000,
    specs: [
      'Fighting Style Sanguine Art & Godhuman Lengkap',
      'Buah Kitsune / Gas Aktif Full Mastery',
      'Race V4 Tier 1–3 Siap Pakai PvP',
      'Akun polosan, password bebas kamu ganti',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 3,
    badge: 'Cocok PvP',
  },
  {
    id: 'acc-18plus-verified',
    code: 'LVY-ACC03',
    title: 'Akun Roblox 18+ Verified + 2FA Siap Top Up Via Username Instan',
    gameFocus: 'All Game / Polosan 18+',
    price: 25000,
    specs: [
      'Status Umur 18+ Aktif (Bisa Voice Chat & Transfer Robux Via Username)',
      'Email bisa langsung diganti ke email pribadi pembeli',
      'Akun lama, dibuat sekitar 2019–2021',
    ],
    emailStatus: 'Verified (Siap Ganti Email Pembeli)',
    ageStatus: 'Akun 18+ Verified',
    stock: 5,
    badge: 'Bisa voice chat',
  },
  {
    id: 'acc-fishit-elemental',
    code: 'LVY-ACC04',
    title: 'Akun Fish It • Elemental Rod + Bait Sanguine Art',
    gameFocus: 'Fish It',
    price: 40000,
    specs: [
      'Elemental Rod sudah kebuka & siap dipakai farming',
      'Bait Sanguine Art ada di inventory',
      'Buat yang gak mau mulai farming dari nol',
      'Akun polosan, password boleh langsung kamu ganti',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 3,
    badge: 'Paling lengkap',
  },
  {
    id: 'acc-fishit-ghostfin',
    code: 'LVY-ACC05',
    title: 'Akun Fish It • Ghostfin Rod + Sanguine Art Bait',
    gameFocus: 'Fish It',
    price: 15000,
    specs: [
      'Ghostfin Rod sudah ready di inventory',
      'Sanguine Art Bait sudah ada',
      'Cukup buat yang baru mulai dan budgetnya pas-pasan',
      'Akun polosan',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 6,
    badge: 'Hemat',
  },
];

export const JOKI_CATEGORIES: JokiCategory[] = [
  {
    id: 'grind',
    label: 'Level, Mastery, Belly & Bounty',
    shortLabel: 'Level & Grind',
    intro: 'Buat yang males grinding. Level, mastery, belly, sampai bounty kami yang jalanin.',
  },
  {
    id: 'race',
    label: 'Race V1 – V4',
    shortLabel: 'Race',
    intro: 'Upgrade race dari V1 sampai trial V4. Harga beda tiap tahap, tergantung race yang kamu pakai.',
  },
  {
    id: 'sword',
    label: 'Sword & Gun',
    shortLabel: 'Sword & Gun',
    intro: 'Unlock pedang dan senjata langka. Cek syarat tiap item dulu sebelum order ya.',
  },
  {
    id: 'melee',
    label: 'Fighting Style (Melee)',
    shortLabel: 'Melee',
    intro: 'Dari melee standar sampai Godhuman dan Sanguine Art.',
  },
  {
    id: 'raid',
    label: 'Raid, Boss & Sea Event',
    shortLabel: 'Raid & Boss',
    intro: 'Raid, spawn boss, sampai hunt Leviathan. Bisa per sekali jalan.',
  },
];

export const JOKI_SERVICES: JokiService[] = [
  // Level, Mastery, Belly & Bounty
  { id: 'joki-level', categoryId: 'grind', name: 'Joki Level', priceMin: 1500, priceMax: 4000, unit: 'per 100 level', maxQty: 26 },
  { id: 'joki-mastery', categoryId: 'grind', name: 'Joki Mastery', priceMin: 1800, priceMax: 5000, unit: 'per 100 mastery', maxQty: 6 },
  { id: 'joki-mastery-max', categoryId: 'grind', name: 'Joki Mastery 1 sampai Max (600)', priceMin: 10000, priceMax: 15000 },
  { id: 'joki-belly', categoryId: 'grind', name: 'Joki Belly', priceMin: 2500, priceMax: 5000, unit: 'per 1 juta', maxQty: 50 },
  { id: 'joki-bounty', categoryId: 'grind', name: 'Joki Bounty / Honor', priceMin: 10000, priceMax: 20000, unit: 'per 1 juta', maxQty: 30 },
  { id: 'joki-haki', categoryId: 'grind', name: 'Joki Haki Warna (Rainbow / Legendary)', priceMin: 8000, priceMax: 15000 },

  // Race
  { id: 'race-v2', categoryId: 'race', name: 'Race V1 ke V2', priceMin: 4000, priceMax: 6000 },
  { id: 'race-v3', categoryId: 'race', name: 'Race V2 ke V3', priceMin: 5000, priceMax: 8000 },
  { id: 'race-ghoul-cyborg', categoryId: 'race', name: 'Unlock Race Ghoul / Cyborg', priceMin: 10000, priceMax: 25000 },
  { id: 'race-mirage', categoryId: 'race', name: 'Cari Mirage Island + Blue Gear', priceMin: 10000, priceMax: 20000 },
  { id: 'race-v4-trial', categoryId: 'race', name: 'Trial Race V4', priceMin: 5000, priceMax: 10000, unit: 'per 1x trial', maxQty: 10 },

  // Sword & Gun
  { id: 'sword-cdk', categoryId: 'sword', name: 'Cursed Dual Katana (CDK)', priceMin: 10500, priceMax: 25000, requirement: 'Yama & Tushita harus sudah Lv. 350' },
  { id: 'sword-ttk', categoryId: 'sword', name: 'True Triple Katana (TTK)', priceMin: 20000, priceMax: 35000, requirement: '3 pedang Zoro sudah ada + 8M Belly' },
  { id: 'sword-soulguitar', categoryId: 'sword', name: 'Soul Guitar', priceMin: 10000, priceMax: 20000, requirement: 'Level 2300+ dan material sudah lengkap' },
  { id: 'sword-darkblade', categoryId: 'sword', name: 'Dark Blade V2 / V3', priceMin: 10000, priceMax: 25000, requirement: 'Wajib sudah punya Gamepass-nya' },
  { id: 'sword-shark', categoryId: 'sword', name: 'Shark Anchor', priceMin: 20000, priceMax: 35000 },
  { id: 'sword-foxlamp', categoryId: 'sword', name: 'Fox Lamp (Kitsune Shrine)', priceMin: 18000, priceMax: 35000 },

  // Melee
  { id: 'melee-standar', categoryId: 'melee', name: 'Melee V1 / V2 Standar', priceMin: 12000, priceMax: 20000, requirement: 'Death Step, Sharkman Karate, Electric Claw, Dragon Talon' },
  { id: 'melee-godhuman', categoryId: 'melee', name: 'Godhuman', priceMin: 20000, priceMax: 35000, requirement: 'Semua melee V1 & V2 sudah mastery 400' },
  { id: 'melee-sanguine', categoryId: 'melee', name: 'Sanguine Art', priceMin: 27000, priceMax: 50000 },

  // Raid, Boss, Sea Event
  { id: 'raid-normal', categoryId: 'raid', name: 'Raid Normal / Fragment', priceMin: 1200, priceMax: 1500, unit: 'per 1x raid', maxQty: 30 },
  { id: 'raid-spesial', categoryId: 'raid', name: 'Raid Spesial (Dough / Phoenix)', priceMin: 3000, priceMax: 5000, unit: 'per 1x raid', maxQty: 20 },
  { id: 'boss-spawn', categoryId: 'raid', name: 'Spawn & Kill Boss', priceMin: 7500, priceMax: 15000, requirement: 'Rip Indra, Dough King, Darkbeard' },
  { id: 'sea-leviathan', categoryId: 'raid', name: 'Leviathan Hunt', priceMin: 25000, priceMax: 45000, requirement: 'Termasuk bekuin Hydra / ambil Heart' },
];

export const PAYMENT_METHODS: PaymentMethod[] = [
  {
    id: 'qris',
    name: 'QRIS All Payment',
    category: 'QRIS',
    feeText: 'Bebas Biaya Admin',
    accountHint: 'Scan dari DANA, GoPay, OVO, ShopeePay, BCA, BRI, Mandiri, SeaBank',
    popular: true,
  },
  {
    id: 'dana',
    name: 'DANA',
    category: 'E-Wallet',
    feeText: 'Proses Instan',
    accountHint: 'Kirim ke nomor DANA Lvysky Store',
    popular: true,
  },
  {
    id: 'gopay',
    name: 'GoPay',
    category: 'E-Wallet',
    feeText: 'Proses Instan',
    accountHint: 'Kirim ke nomor GoPay Lvysky Store',
  },
  {
    id: 'ovo',
    name: 'OVO',
    category: 'E-Wallet',
    feeText: 'Proses Instan',
    accountHint: 'Kirim ke nomor OVO Lvysky Store',
  },
  {
    id: 'shopeepay',
    name: 'ShopeePay',
    category: 'E-Wallet',
    feeText: 'Proses Instan',
    accountHint: 'Kirim ke ShopeePay Lvysky Store',
  },
  {
    id: 'seabank',
    name: 'SeaBank',
    category: 'Bank Transfer',
    feeText: 'Gratis Transfer',
    accountHint: 'Rekening SeaBank Lvysky Store',
  },
  {
    id: 'bca',
    name: 'Bank BCA',
    category: 'Bank Transfer',
    feeText: 'Cek Cepat',
    accountHint: 'Rekening BCA Lvysky Store',
  },
  {
    id: 'bri',
    name: 'Bank BRI',
    category: 'Bank Transfer',
    feeText: 'Cek Cepat',
    accountHint: 'Rekening BRI Lvysky Store',
  },
];

export const BUYER_TESTIMONIALS = [
  {
    id: 't1',
    user: 'rzk***_rbx',
    method: 'Robux 5 Hari (500 R$)',
    timeAgo: '18 menit lalu',
    comment: 'Sempet bingung set gamepass 715 R$, tapi dipandu pelan-pelan sama adminnya. Udah masuk pending, harganya paling murah yang saya temuin.',
    rating: 5,
  },
  {
    id: 't2',
    user: 'nay***_dti',
    method: 'Via Username (100 R$)',
    timeAgo: '42 menit lalu',
    comment: 'cuma kasih username doang, gak diminta password. sekitar 6 menit robux udah masuk',
    rating: 5,
  },
  {
    id: 't3',
    user: 'kvn***_bf',
    method: 'Joki CDK',
    timeAgo: '1 jam lalu',
    comment: 'Titip akun buat unlock CDK, ditinggal tidur eh bangun udah kelar. Adminnya juga ngabarin pas mulai dan pas selesai.',
    rating: 5,
  },
  {
    id: 't4',
    user: 'dim***_fsh',
    method: 'Akun Fish It (Elemental Rod)',
    timeAgo: '3 jam lalu',
    comment: 'Beli akun Elemental Rod 40k. Sesuai deskripsi, data dikirim abis bayar. Udah bisa langsung farming.',
    rating: 4,
  },
  {
    id: 't5',
    user: 'ayu***_rbl',
    method: 'Akun Fish It (Ghostfin Rod)',
    timeAgo: '5 jam lalu',
    comment: '15k dapet Ghostfin Rod sama baitnya. Buat pemula kayak saya udah cukup. Makasih kak',
    rating: 5,
  },
  {
    id: 't6',
    user: 'bgs***_ply',
    method: 'Joki Level (300 level)',
    timeAgo: 'Kemarin',
    comment: 'Harga akhirnya dikasih tau dulu sebelum bayar, jadi gak kaget. Prosesnya agak lama karena antre, tapi hasilnya sesuai.',
    rating: 5,
  },
];

export const FAQ_ITEMS = [
  {
    q: 'Joki Blox Fruits itu gimana jalannya?',
    a: 'Pilih layanan di menu Joki, isi username dan progress akunmu, lalu kirim lewat WhatsApp. Admin akan konfirmasi harga pastinya (di web cuma tertera kisaran) dan jelasin soal akses akun. Pembayaran dilakukan setelah harga disepakati.',
  },
  {
    q: 'Aman gak titip akun buat dijokiin?',
    a: 'Ada risikonya, namanya juga akun dipegang orang lain. Biar lebih tenang, pakai password khusus yang bisa langsung kamu ganti setelah selesai, dan jangan login selama akunmu dikerjakan. Password dikirim lewat chat, jangan lewat form di web.',
  },
  {
    q: 'Kenapa harga jokinya berupa kisaran?',
    a: 'Soalnya tergantung kondisi akun, misalnya bahan yang sudah kamu punya, dan juga antrean. Setelah kamu kirim detail akun, admin kasih harga pastinya sebelum mulai.',
  },
  {
    q: 'Gimana cara ordernya?',
    a: 'Pilih produk, isi username Roblox dan metode bayar, lalu klik tombol order. Kamu dibawa ke WhatsApp dengan pesan yang sudah terisi, tinggal dikirim.',
  },
  {
    q: 'Beda Robux 5 Hari, Via Username, dan Via Login apa?',
    a: '5 Hari paling murah tapi Robux masuk pending dulu selama 5x24 jam (aturan Roblox). Via Username cepat 5–10 menit tanpa password, tapi akunmu wajib 18+ dan 2FA aktif. Via Login langsung masuk lewat top up resmi di aplikasi, jadi kami butuh akses login sementara.',
  },
  {
    q: 'Aman gak beli akun di sini?',
    a: 'Akun yang kami jual sesuai spesifikasi di katalog. Setelah bayar, data akun dikirim lewat chat pribadi. Kalau ada yang gak sesuai deskripsi saat serah terima, kabarin kami langsung dan kita bantu selesaikan.',
  },
  {
    q: 'Akun Fish It-nya itemnya apa aja?',
    a: 'Ada dua pilihan: Elemental Rod + Bait Sanguine Art (Rp40.000) dan Ghostfin Rod + Sanguine Art Bait (Rp15.000). Detail lengkapnya ada di menu Akun, dan kamu boleh minta screenshot inventory sebelum bayar.',
  },
  {
    q: 'Kalau stok akunnya habis gimana?',
    a: 'Stok yang tampil di katalog diperbarui berkala. Kalau pas kamu order ternyata baru aja habis, kami kabari dan kamu bisa pilih akun lain atau minta refund penuh.',
  },
  {
    q: 'Metode pembayaran apa aja yang tersedia?',
    a: 'QRIS, DANA, GoPay, OVO, ShopeePay, SeaBank, BCA, dan BRI. Detail nomor atau QRIS dikirim lewat chat setelah kamu order.',
  },
  {
    q: 'Jam operasional kapan?',
    a: 'Setiap hari pukul 07.00–23.00 WIB. Di luar jam itu kamu tetap boleh kirim pesanan, nanti diproses paling awal saat toko buka.',
  },
  {
    q: 'Pesanan saya belum masuk, harus gimana?',
    a: 'Cek dulu estimasi waktunya di tiap metode. Kalau sudah lewat, chat lagi lewat WhatsApp dan sebutin nomor pesananmu biar cepat dicek.',
  },
];

export function formatRupiah(amount: number): string {
  return 'Rp' + Math.round(amount).toLocaleString('id-ID');
}

export function calculateGamepassPrice(desiredRobux: number): {
  gamepassPrice: number;
  robloxTax: number;
  netReceived: number;
} {
  if (!desiredRobux || desiredRobux <= 0) {
    return { gamepassPrice: 0, robloxTax: 0, netReceived: 0 };
  }
  const gamepassPrice = Math.ceil(desiredRobux / 0.7);
  const robloxTax = gamepassPrice - desiredRobux;
  return {
    gamepassPrice,
    robloxTax,
    netReceived: desiredRobux,
  };
}

export function formatRupiahRange(min: number, max: number): string {
  if (min === max) return formatRupiah(min);
  return `${formatRupiah(min)} – ${formatRupiah(max)}`;
}
