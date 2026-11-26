import { formatRupiah, calculateGamepassPrice, RobuxMethodId } from '../data/storeData';

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
  if (hour >= 4 && hour < 11) return 'Selamat pagi';
  if (hour >= 11 && hour < 15) return 'Selamat siang';
  if (hour >= 15 && hour < 18) return 'Selamat sore';
  return 'Selamat malam';
}

export function buildRobuxWhatsAppMessage(payload: RobuxOrderPayload): string {
  const greeting = getTimeGreeting();
  const lines: string[] = [
    `Halo kak Admin *Lvysky Store*, ${greeting.toLowerCase()}! 👋`,
    `Saya mau top up Robux, berikut detail pesanan saya ya:`,
    ``,
    `🧾 *No. Pesanan:* #${payload.invoiceId}`,
    `📦 *Metode:* ${payload.methodTitle}`,
    `💎 *Nominal:* ${payload.robuxAmount.toLocaleString('id-ID')} Robux${payload.variantLabel ? ` (${payload.variantLabel})` : ''}`,
    `💰 *Total Harga:* ${formatRupiah(payload.totalPrice)}`,
    `💳 *Pembayaran:* ${payload.paymentMethodName}`,
    ``,
    `👤 *Data Akun Roblox:*`,
    `• Username: *${payload.robloxUsername.trim()}*`,
  ];

  if (payload.methodId === '5hari') {
    const gp = calculateGamepassPrice(payload.robuxAmount);
    lines.push(`• Harga Gamepass Disetel: *${gp.gamepassPrice.toLocaleString('id-ID')} R$* (Terima bersih ${payload.robuxAmount.toLocaleString('id-ID')} R$)`);
    lines.push(`• Regional Pricing: *Sudah Dinonaktifkan (OFF)*`);
    if (payload.gamepassLinkOrMap?.trim()) {
      lines.push(`• Link Gamepass / Nama Map: ${payload.gamepassLinkOrMap.trim()}`);
    }
  } else if (payload.methodId === 'username') {
    lines.push(`• Status Akun: *Sudah 18+ & Verifikasi 2 Langkah (2FA) Aktif*`);
    lines.push(`• Estimasi: Proses Instan 5–10 Menit Tanpa Password`);
  } else if (payload.methodId === 'login') {
    if (payload.loginPasswordOrNote?.trim()) {
      lines.push(`• Info Login / Catatan: ${payload.loginPasswordOrNote.trim()}`);
    } else {
      lines.push(`• Info Login: Password saya kirim setelah admin balas ya`);
    }
    if (payload.backupCode2FA?.trim()) {
      lines.push(`• Kode Backup 2FA: ${payload.backupCode2FA.trim()}`);
    }
  }

  if (payload.buyerWhatsapp?.trim()) {
    lines.push(`• Kontak Pembeli: ${payload.buyerWhatsapp.trim()}`);
  }

  lines.push(
    ``,
    `Mohon info nomor pembayaran / QRIS-nya ya min supaya langsung saya transfer. Terima kasih! 🙏`
  );

  return lines.join('\n');
}

export function buildItemWhatsAppMessage(payload: ItemOrderPayload): string {
  const greeting = getTimeGreeting();
  return [
    `Halo kak Admin *Lvysky Store*, ${greeting.toLowerCase()}! 👋`,
    `Saya mau beli *Item / Gamepass Roblox*, ini detailnya ya:`,
    ``,
    `🧾 *No. Pesanan:* #${payload.invoiceId}`,
    `🎮 *Game:* ${payload.gameName}`,
    `🎁 *Item / Pass:* ${payload.itemName} (${payload.category})`,
    `💰 *Harga:* ${formatRupiah(payload.price)}`,
    `💳 *Pembayaran:* ${payload.paymentMethodName}`,
    ``,
    `👤 *Username Tujuan Gift:* *${payload.robloxUsername.trim()}*`,
    payload.inGameNote?.trim() ? `📝 *Catatan:* ${payload.inGameNote.trim()}` : '',
    ``,
    `Apakah stoknya ready min? Mohon info pembayarannya ya, terima kasih! 🙏`,
  ]
    .filter(Boolean)
    .join('\n');
}

export function buildAccountWhatsAppMessage(payload: AccountOrderPayload): string {
  const greeting = getTimeGreeting();
  return [
    `Halo kak Admin *Lvysky Store*, ${greeting.toLowerCase()}! 👋`,
    `Saya tertarik mau beli *Akun Roblox* berikut:`,
    ``,
    `🧾 *No. Pesanan:* #${payload.invoiceId}`,
    `🏷️ *Kode Akun:* ${payload.accountCode}`,
    `👤 *Spesifikasi:* ${payload.accountTitle}`,
    `💰 *Harga:* ${formatRupiah(payload.price)}`,
    `💳 *Pembayaran:* ${payload.paymentMethodName}`,
    payload.buyerNote?.trim() ? `📝 *Catatan:* ${payload.buyerNote.trim()}` : '',
    ``,
    `Apakah akun dengan kode *${payload.accountCode}* masih ready min? Mohon info detail pembayarannya ya, terima kasih! 🙏`,
  ]
    .filter(Boolean)
    .join('\n');
}

export function buildWhatsAppUrl(phone: string, message: string): string {
  const cleanPhone = phone.replace(/[^0-9]/g, '');
  const normalizedPhone = cleanPhone.startsWith('0')
    ? '62' + cleanPhone.slice(1)
    : cleanPhone || '6281234567890';
  return `https://wa.me/${normalizedPhone}?text=${encodeURIComponent(message)}`;
}
