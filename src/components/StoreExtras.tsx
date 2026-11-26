import React, { useState } from 'react';
import {
  ChevronDown,
  MessageCircle,
  MousePointerClick,
  CreditCard,
  PackageCheck,
  ShieldCheck,
  Zap,
  Clock,
  Wallet,
  HeartHandshake,
} from 'lucide-react';
import { FAQ_ITEMS } from '../data/storeData';
import { buildWhatsAppUrl } from '../utils/whatsappBuilder';

interface StoreExtrasProps {
  waNumber: string;
}

const STEPS = [
  {
    icon: MousePointerClick,
    title: 'Pilih Produk',
    desc: 'Pilih Robux, item, akun, atau layanan joki, lalu isi username Roblox.',
  },
  {
    icon: MessageCircle,
    title: 'Kirim Pesanan',
    desc: 'Klik tombol order, nanti pesannya sudah terisi di WhatsApp. Tinggal kirim.',
  },
  {
    icon: CreditCard,
    title: 'Bayar',
    desc: 'Kami kirim QRIS atau nomor e-wallet/rekening. Untuk joki, harga pasnya dikonfirmasi dulu.',
  },
  {
    icon: PackageCheck,
    title: 'Pesanan Diproses',
    desc: 'Robux, item, data akun, atau jokimu dikerjakan sesuai estimasi tiap produk.',
  },
];

const REASONS = [
  { icon: Wallet, title: 'Harga jelas', desc: 'Robux mulai Rp130/R$, akun mulai Rp15.000, joki mulai Rp1.200.' },
  { icon: Zap, title: 'Lumayan cepat', desc: 'Via Username cuma 5–10 menit, tanpa password.' },
  { icon: ShieldCheck, title: 'Ada nomor pesanan', desc: 'Tiap order punya nomor, jadi gampang dicek kalau ada masalah.' },
  { icon: Clock, title: 'Buka tiap hari', desc: 'Jam 07.00 – 23.00 WIB, termasuk weekend.' },
  { icon: HeartHandshake, title: 'Boleh tanya dulu', desc: 'Bingung setting gamepass atau pilih joki? Tanya aja di WhatsApp.' },
  { icon: CreditCard, title: 'Metode bayar', desc: 'QRIS, DANA, GoPay, OVO, ShopeePay, SeaBank, BCA, BRI.' },
];

export const StoreExtras: React.FC<StoreExtrasProps> = ({ waNumber }) => {
  const [openIdx, setOpenIdx] = useState<number | null>(0);

  return (
    <>
      <section className="max-w-6xl mx-auto px-4 sm:px-6 mt-14 space-y-12">
        {/* Cara Order */}
        <div>
          <div className="text-center mb-6">
            <h2 className="font-heading font-extrabold text-xl sm:text-2xl text-slate-900">
              Cara Order di Lvysky Store
            </h2>
            <p className="text-xs sm:text-sm text-slate-500 mt-1">
              Gampang kok, cuma 4 langkah.
            </p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {STEPS.map((st, i) => (
              <div
                key={st.title}
                className="relative bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs"
              >
                <span className="absolute top-4 right-4 font-heading font-extrabold text-3xl text-slate-100">
                  {i + 1}
                </span>
                <div className="w-10 h-10 rounded-xl bg-indigo-50 text-[#312E81] flex items-center justify-center mb-3">
                  <st.icon className="w-5 h-5" />
                </div>
                <h3 className="font-heading font-bold text-sm text-slate-900">{st.title}</h3>
                <p className="text-xs text-slate-600 mt-1 leading-relaxed">{st.desc}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Kenapa pilih kami */}
        <div>
          <div className="text-center mb-6">
            <h2 className="font-heading font-extrabold text-xl sm:text-2xl text-slate-900">
              Kenapa Belanja di Sini?
            </h2>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {REASONS.map((r) => (
              <div
                key={r.title}
                className="flex items-start gap-3 bg-white rounded-2xl border border-slate-200 p-4"
              >
                <div className="w-9 h-9 shrink-0 rounded-xl bg-sky-50 text-[#0284C7] flex items-center justify-center">
                  <r.icon className="w-4.5 h-4.5" />
                </div>
                <div>
                  <h3 className="font-heading font-bold text-sm text-slate-900">{r.title}</h3>
                  <p className="text-xs text-slate-600 mt-0.5 leading-relaxed">{r.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* FAQ */}
        <div className="max-w-3xl mx-auto">
          <div className="text-center mb-6">
            <h2 className="font-heading font-extrabold text-xl sm:text-2xl text-slate-900">
              Pertanyaan yang Sering Ditanyain
            </h2>
          </div>
          <div className="space-y-2.5">
            {FAQ_ITEMS.map((item, i) => {
              const open = openIdx === i;
              return (
                <div
                  key={item.q}
                  className="bg-white rounded-xl border border-slate-200 overflow-hidden"
                >
                  <button
                    type="button"
                    onClick={() => setOpenIdx(open ? null : i)}
                    className="w-full flex items-center justify-between gap-3 px-4 py-3.5 text-left cursor-pointer"
                  >
                    <span className="font-heading font-bold text-sm text-slate-900">{item.q}</span>
                    <ChevronDown
                      className={`w-4 h-4 text-slate-400 shrink-0 transition ${open ? 'rotate-180' : ''}`}
                    />
                  </button>
                  {open && (
                    <p className="px-4 pb-4 text-xs sm:text-sm text-slate-600 leading-relaxed">
                      {item.a}
                    </p>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Syarat singkat */}
        <div className="rounded-2xl bg-slate-100/80 border border-slate-200 p-5 text-xs text-slate-600 leading-relaxed">
          <h3 className="font-heading font-bold text-sm text-slate-900 mb-1.5">
            Syarat & Ketentuan Singkat
          </h3>
          <ul className="list-disc pl-4 space-y-1">
            <li>Pastikan username Roblox yang kamu isi sudah benar, salah input di luar tanggung jawab kami.</li>
            <li>Pesanan yang sudah diproses tidak bisa dibatalkan, kecuali ada kendala dari pihak kami.</li>
            <li>Untuk Robux 5 Hari, dana Robux masuk status pending sesuai kebijakan Roblox.</li>
            <li>Untuk akun, kamu bertanggung jawab menjaga akun setelah serah terima (ganti password, dll).</li>
          </ul>
        </div>
      </section>

      {/* Floating WhatsApp button */}
      <a
        href={buildWhatsAppUrl(
          waNumber,
          'Halo kak, saya mau tanya-tanya dulu seputar produk di Lvysky Store.'
        )}
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Chat WhatsApp"
        className="fixed bottom-5 right-5 z-50 w-13 h-13 p-3.5 rounded-full bg-[#25D366] hover:bg-[#1EBE5D] text-white shadow-lg shadow-emerald-900/20 flex items-center justify-center transition"
      >
        <MessageCircle className="w-6 h-6" />
      </a>
    </>
  );
};
