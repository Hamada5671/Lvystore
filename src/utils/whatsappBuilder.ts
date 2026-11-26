import {
  formatRupiah,
  formatRupiahRange,
  calculateGamepassPrice,
  RobuxMethodId,
  JokiOrderPayload,
} from '../data/storeData';

export interface RobuxOrderPayload {
  invoiceId: string;
  methodId: RobuxMethodId;
  methodTitle: string;
  robuxAmount: number;
  totalPrice: number;
  variantLabel?: string;
  robloxUsername: string;
  gamepassLinkOrMap?: string;
  loginPasswordOrNote?: string;
  backupCode2FA?: string;
  paymentMethodName: string;
  buyerWhatsapp?: string;
}

export interface ItemOrderPayload {
  invoiceId: string;
  gameName: string;
  itemName: string;
  category: string;
  price: number;
  robloxUsername: string;
  inGameNote?: string;
  paymentMethodName: string;
}

export interface AccountOrderPayload {
  invoiceId: string;
  accountCode: string;
  accountTitle: string;
  price: number;
  buyerNote?: string;
  paymentMethodName: string;
}

export function generateInvoiceId(): string {
  const now = new Date();
  const mm = String(now.getMonth() + 1).padStart(2, '0');
  const dd = String(now.getDate()).padStart(2, '0');
  const randomDigits = Math.floor(1000 + Math.random() * 9000);
  return `LVY-${dd}${mm}-${randomDigits}`;
}

function getTimeGreeting(): string {
  const hour = new Date().getHours();
  if (hour >= 4 && hour < 11) return 'pagi';
  if (hour >= 11 && hour < 15) return 'siang';
  if (hour >= 15 && hour < 18) return 'sore';
  return 'malam';
}

export function buildRobuxWhatsAppMessage(payload: RobuxOrderPayload): string {
  const lines: string[] = [
    `Halo kak, selamat ${getTimeGreeting()}. Mau order Robux di Lvysky Store ya.`,
    ``,
    `No. pesanan: #${payload.invoiceId}`,
    `Metode: ${payload.methodTitle}`,
    `Nominal: ${payload.robuxAmount.toLocaleString('id-ID')} Robux${payload.variantLabel ? ` (${payload.variantLabel})` : ''}`,
    `Total: ${formatRupiah(payload.totalPrice)}`,
    `Bayar pakai: ${payload.paymentMethodName}`,
    ``,
    `Username Roblox: ${payload.robloxUsername.trim()}`,
  ];

  if (payload.methodId === '5hari') {
    const gp = calculateGamepassPrice(payload.robuxAmount);
    lines.push(`Harga gamepass: ${gp.gamepassPrice.toLocaleString('id-ID')} R$ (bersih ${payload.robuxAmount.toLocaleString('id-ID')} R$), regional pricing sudah saya matiin`);
    if (payload.gamepassLinkOrMap?.trim()) {
      lines.push(`Link gamepass / nama map: ${payload.gamepassLinkOrMap.trim()}`);
    }
  } else if (payload.methodId === 'username') {
    lines.push(`Akun saya sudah 18+ dan 2FA aktif`);
  } else if (payload.methodId === 'login') {
    if (payload.loginPasswordOrNote?.trim()) {
      lines.push(`Info login / catatan: ${payload.loginPasswordOrNote.trim()}`);
    } else {
      lines.push(`Password nanti saya kirim setelah kakak balas`);
    }
    if (payload.backupCode2FA?.trim()) {
      lines.push(`Backup code 2FA: ${payload.backupCode2FA.trim()}`);
    }
  }

  if (payload.buyerWhatsapp?.trim()) {
    lines.push(`Kontak lain: ${payload.buyerWhatsapp.trim()}`);
  }

  lines.push(``, `Tolong kirim info pembayarannya ya kak, makasih.`);

  return lines.join('\n');
}

export function buildItemWhatsAppMessage(payload: ItemOrderPayload): string {
  return [
    `Halo kak, selamat ${getTimeGreeting()}. Saya mau beli item di Lvysky Store.`,
    ``,
    `No. pesanan: #${payload.invoiceId}`,
    `Game: ${payload.gameName}`,
    `Item: ${payload.itemName} (${payload.category})`,
    `Harga: ${formatRupiah(payload.price)}`,
    `Bayar pakai: ${payload.paymentMethodName}`,
    ``,
    `Username tujuan gift: ${payload.robloxUsername.trim()}`,
    payload.inGameNote?.trim() ? `Catatan: ${payload.inGameNote.trim()}` : null,
    ``,
    `Stoknya masih ada kak? Kalau ada, kirim info bayarnya ya.`,
  ]
    .filter((l) => l !== null)
    .join('\n');
}

export function buildAccountWhatsAppMessage(payload: AccountOrderPayload): string {
  return [
    `Halo kak, selamat ${getTimeGreeting()}. Saya tertarik sama akun ini:`,
    ``,
    `No. pesanan: #${payload.invoiceId}`,
    `Kode akun: ${payload.accountCode}`,
    `Judul: ${payload.accountTitle}`,
    `Harga: ${formatRupiah(payload.price)}`,
    `Bayar pakai: ${payload.paymentMethodName}`,
    payload.buyerNote?.trim() ? `Catatan: ${payload.buyerNote.trim()}` : null,
    ``,
    `Akun ${payload.accountCode} masih ready kak? Boleh minta screenshot inventorynya juga.`,
  ]
    .filter((l) => l !== null)
    .join('\n');
}

export function buildJokiWhatsAppMessage(payload: JokiOrderPayload): string {
  const totalMin = payload.priceMin * payload.qty;
  const totalMax = payload.priceMax * payload.qty;
  const qtyLine = payload.unit
    ? `Jumlah: ${payload.qty}x (${payload.unit})`
    : null;
  return [
    `Halo kak, selamat ${getTimeGreeting()}. Saya mau pakai jasa joki Blox Fruits.`,
    ``,
    `No. pesanan: #${payload.invoiceId}`,
    `Kategori: ${payload.categoryLabel}`,
    `Layanan: ${payload.serviceName}`,
    qtyLine,
    `Estimasi harga: ${formatRupiahRange(totalMin, totalMax)}`,
    `Bayar pakai: ${payload.paymentMethodName}`,
    ``,
    `Username Roblox: ${payload.robloxUsername.trim()}`,
    payload.currentProgress?.trim() ? `Progress sekarang: ${payload.currentProgress.trim()}` : null,
    payload.note?.trim() ? `Catatan: ${payload.note.trim()}` : null,
    ``,
    `Kira-kira harga pastinya berapa kak, dan bisa mulai kapan? Soal login nanti saya ikut arahan kakak.`,
  ]
    .filter((l) => l !== null)
    .join('\n');
}

export function buildWhatsAppUrl(phone: string, message: string): string {
  const cleanPhone = phone.replace(/[^0-9]/g, '');
  const normalizedPhone = cleanPhone.startsWith('0')
    ? '62' + cleanPhone.slice(1)
    : cleanPhone || '6283144027784';
  return `https://wa.me/${normalizedPhone}?text=${encodeURIComponent(message)}`;
}
