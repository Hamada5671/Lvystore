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
  orderType: 'robux' | 'item' | 'account';
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
    badgeText: 'Paling Hemat',
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
    badgeText: 'Kilat Tanpa Password',
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
    badgeText: 'Langsung Cair',
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
    perRobuxLabel: 'Rp130 / 1 R$ (Termurah!)',
    badge: 'Best Seller Hemat',
    isPopular: true,
    note: 'Set harga Gamepass: 715 R$ • Rate Rp130/R$',
  },
  {
    id: '5h-1000',
    methodId: '5hari',
    robux: 1000,
    price: 155000,
    perRobuxLabel: 'Rp155 / 1 R$',
    badge: 'Paket Sultan',
    note: 'Set harga Gamepass: 1.429 R$',
  },

  // 2. ROBUX VIA USERNAME (INSTAN / TRANSFER)
  {
    id: 'user-100',
    methodId: 'username',
    robux: 100,
    price: 16000,
    perRobuxLabel: 'Rp160 / 1 R$',
    badge: 'Populer',
    isPopular: true,
    note: 'Proses 5–10 menit • Tanpa password',
  },
  {
    id: 'user-200',
    methodId: 'username',
    robux: 200,
    price: 32000,
    perRobuxLabel: 'Rp160 / 1 R$',
    note: 'Proses 5–10 menit • Tanpa password',
  },
  {
    id: 'user-400',
    methodId: 'username',
    robux: 400,
    price: 64000,
    perRobuxLabel: 'Rp160 / 1 R$',
    note: 'Proses 5–10 menit • Tanpa password',
  },
  {
    id: 'user-500',
    methodId: 'username',
    robux: 500,
    price: 80000,
    perRobuxLabel: 'Rp160 / 1 R$',
    badge: 'Paket Populer',
    note: 'Proses 5–10 menit • Tanpa password',
  },
  {
    id: 'user-800',
    methodId: 'username',
    robux: 800,
    price: 128000,
    perRobuxLabel: 'Rp160 / 1 R$',
    note: 'Proses 5–10 menit • Tanpa password',
  },
  {
    id: 'user-1000',
    methodId: 'username',
    robux: 1000,
    price: 160000,
    perRobuxLabel: 'Rp160 / 1 R$',
    badge: 'Instan Favorit',
    note: 'Proses 5–10 menit • Tanpa password',
  },
  {
    id: 'user-2000',
    methodId: 'username',
    robux: 2000,
    price: 320000,
    perRobuxLabel: 'Rp160 / 1 R$',
    badge: 'Stok Siap',
    note: 'Proses 5–10 menit • Tanpa password',
  },

  // 3. ROBUX VIA LOGIN
  {
    id: 'login-80',
    methodId: 'login',
    robux: 80,
    price: 16500,
    perRobuxLabel: '~Rp206 / 1 R$',
    note: 'Top up resmi in-app • Langsung cair',
  },
  {
    id: 'login-160',
    methodId: 'login',
    robux: 160,
    price: 31000,
    perRobuxLabel: '~Rp193 / 1 R$',
    note: 'Top up resmi in-app • Langsung cair',
  },
  {
    id: 'login-240',
    methodId: 'login',
    robux: 240,
    price: 46500,
    perRobuxLabel: '~Rp193 / 1 R$',
    note: 'Top up resmi in-app • Langsung cair',
  },
  {
    id: 'login-320',
    methodId: 'login',
    robux: 320,
    price: 62000,
    perRobuxLabel: '~Rp193 / 1 R$',
    note: 'Top up resmi in-app • Langsung cair',
  },
  {
    id: 'login-500',
    methodId: 'login',
    robux: 500,
    price: 77500,
    altPrice: 81000,
    priceRangeLabel: 'Rp77.500 – Rp81.000',
    perRobuxLabel: 'Rp155 – Rp162 / 1 R$',
    badge: 'Paling Laris',
    isPopular: true,
    note: 'Reguler Rp77.500 / Prioritas Pack Rp81.000',
  },
  {
    id: 'login-800',
    methodId: 'login',
    robux: 800,
    price: 144769,
    perRobuxLabel: '~Rp181 / 1 R$',
    note: 'Top up resmi in-app • Langsung cair',
  },
  {
    id: 'login-1000',
    methodId: 'login',
    robux: 1000,
    price: 162000,
    perRobuxLabel: 'Rp162 / 1 R$',
    badge: 'Full Pack',
    note: 'Top up resmi in-app • Langsung cair',
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
    badge: 'Terlaris',
    description: 'Gift langsung ke inventory Blox Fruits kamu cukup dengan Username Roblox.',
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
    description: 'Gandakan perolehan Beli di Blox Fruits. Pengiriman instan via fitur Gift.',
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
    badge: 'Favorit',
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
    badge: 'Wajib Grinding',
    description: 'Buah terbaik untuk grinding Sea 1, 2, dan 3 secara permanen.',
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
    description: 'Teleportasi instan antar pulau dan PvP mobilitas tinggi selamanya.',
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
    description: 'Pedang Mythical legendaris Yoru dikirim langsung via Gift In-Game.',
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
    badge: 'Best Seller DTI',
    description: 'Akses ruang VIP Dress To Impress selamanya tanpa batas waktu.',
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
    description: 'Buka fitur kustomisasi wajah dan makeup lengkap di Dress To Impress.',
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
    description: 'Gift Battlepass atau Token Blade Ball langsung ke akun kamu.',
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
    description: 'Tingkatkan drop rate boss di King Legacy via Gift resmi.',
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
      'Beli 25 Juta+ & Fragment 40.000+',
      'Bonus Mythical Fruit di Inventory',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 7,
    badge: 'Paling Laris',
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
      'Data Polosan 100% Aman Anti-Hackback',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 3,
    badge: 'Spek PvP',
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
      'Akun pembuatan tahun lama (2019–2021) lebih tahan banting',
    ],
    emailStatus: 'Verified (Siap Ganti Email Pembeli)',
    ageStatus: 'Akun 18+ Verified',
    stock: 5,
    badge: 'Siap Voice Chat',
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
      'Cocok buat yang mau langsung grinding tanpa mulai dari nol',
      'Bonus: akun polosan, bebas kamu ganti password setelah serah terima',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 3,
    badge: 'Spek Terbaik',
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
      'Paling pas buat pemula yang mau mulai dengan budget hemat',
      'Akun polosan, aman buat dipakai sendiri',
    ],
    emailStatus: 'Polosan (Belum Verif Email)',
    ageStatus: 'Akun 13+',
    stock: 6,
    badge: 'Murah Meriah',
  },
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
    comment: 'Awalnya bingung cara set harga gamepass 715 R$, tapi dikasih panduan step by step, sabar banget. Udah masuk pending, harga paling murah yang aku temuin.',
    rating: 5,
  },
  {
    id: 't2',
    user: 'nay***_dti',
    method: 'Via Username (100 R$)',
    timeAgo: '42 menit lalu',
    comment: 'Beneran gak minta password, cuma username aja. Sekitar 6 menit Robux udah masuk. Next topup di sini lagi.',
    rating: 5,
  },
  {
    id: 't3',
    user: 'kvn***_bf',
    method: 'Robux Via Login (500 R$)',
    timeAgo: '1 jam lalu',
    comment: 'Order jam 9 pagi, belum 15 menit udah beres. Langsung kepake buat beli Perm Portal. Mantap pokoknya.',
    rating: 5,
  },
  {
    id: 't4',
    user: 'dim***_fsh',
    method: 'Akun Fish It (Elemental Rod)',
    timeAgo: '3 jam lalu',
    comment: 'Beli akun Elemental Rod + Sanguine Art Bait 40k. Sesuai deskripsi, data dikirim abis bayar, langsung gas farming. Worth it banget.',
    rating: 5,
  },
  {
    id: 't5',
    user: 'ayu***_rbl',
    method: 'Akun Fish It (Ghostfin Rod)',
    timeAgo: '5 jam lalu',
    comment: 'Cuma 15k dapet Ghostfin Rod sama baitnya. Buat pemula kayak aku udah lebih dari cukup. Makasih ya kak!',
    rating: 5,
  },
  {
    id: 't6',
    user: 'bgs***_ply',
    method: 'Item Blox Fruits (2x Mastery)',
    timeAgo: 'Kemarin',
    comment: 'Gift masuk cepet, tinggal join server terus diterima. Prosesnya gak ribet sama sekali.',
    rating: 5,
  },
];

export const FAQ_ITEMS = [
  {
    q: 'Gimana cara ordernya?',
    a: 'Pilih produk, isi username Roblox dan metode bayar, lalu klik tombol beli. Kamu bakal diarahkan ke WhatsApp dengan format pesanan yang udah terisi rapi, tinggal kirim aja.',
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
    a: 'Santai, cek dulu estimasi waktu di tiap metode. Kalau udah lewat dari estimasi, chat lagi lewat WhatsApp sambil kirim nomor pesanan kamu supaya cepat dicek.',
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
