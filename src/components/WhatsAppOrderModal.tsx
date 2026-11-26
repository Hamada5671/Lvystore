import React, { useState } from 'react';
import {
  X,
  MessageCircle,
  Copy,
  Check,
  ShieldCheck,
  Clock,
  ExternalLink,
  Sparkles,
} from 'lucide-react';
import { formatRupiah } from '../data/storeData';
import { OperationalStatus } from '../utils/operationalClock';

interface WhatsAppOrderModalProps {
  isOpen: boolean;
  onClose: () => void;
  invoiceId: string;
  orderTitle: string;
  methodName: string;
  targetAccount: string;
  paymentMethodName: string;
  totalPrice: number;
  whatsappMessage: string;
  whatsappUrl: string;
  operationalStatus: OperationalStatus;
}

export const WhatsAppOrderModal: React.FC<WhatsAppOrderModalProps> = ({
  isOpen,
  onClose,
  invoiceId,
  orderTitle,
  methodName,
  targetAccount,
  paymentMethodName,
  totalPrice,
  whatsappMessage,
  whatsappUrl,
  operationalStatus,
}) => {
  const [copied, setCopied] = useState(false);

  if (!isOpen) return null;

  const handleCopyMessage = async () => {
    try {
      await navigator.clipboard.writeText(whatsappMessage);
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    } catch {
      // fallback ignore
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/65 backdrop-blur-xs animate-fadeIn">
      <div className="bg-white rounded-2xl max-w-lg w-full border border-slate-200 shadow-2xl overflow-hidden flex flex-col max-h-[92vh]">
        {/* Top Banner */}
        <div className="px-6 py-4 bg-gradient-to-r from-[#312E81] via-[#3730A3] to-[#0284C7] text-white flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-white/15 flex items-center justify-center">
              <Sparkles className="w-5 h-5 text-sky-200" />
            </div>
            <div>
              <h3 className="font-heading font-bold text-base">
                Pesanan Siap Dikirim ke WhatsApp
              </h3>
              <p className="text-xs text-sky-100 font-mono-num">
                No. Invoice: #{invoiceId}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition"
            aria-label="Tutup modal"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-5 sm:p-6 overflow-y-auto space-y-4">
          {/* Operational status notice */}
          <div
            className={`p-3.5 rounded-xl border flex items-start gap-3 ${
              operationalStatus.isOnline
                ? 'bg-emerald-50/90 border-emerald-200 text-emerald-900'
                : 'bg-amber-50/90 border-amber-200 text-amber-900'
            }`}
          >
            <Clock
              className={`w-4 h-4 shrink-0 mt-0.5 ${
                operationalStatus.isOnline ? 'text-emerald-600' : 'text-amber-600'
              }`}
            />
            <div className="text-xs leading-relaxed">
              <p className="font-bold">
                {operationalStatus.isOnline
                  ? `🟢 Lvysky Store Lagi Buka (${operationalStatus.timeStringWIB})`
                  : `🌙 Di Luar Jam Operasional (${operationalStatus.timeStringWIB})`}
              </p>
              <p className="mt-0.5 opacity-90">
                {operationalStatus.isOnline
                  ? 'Jam operasional 07.00 – 23.00 WIB. Kirim chat sekarang, pesananmu langsung kami proses.'
                  : 'Toko buka pukul 07.00 – 23.00 WIB. Kamu tetap bisa kirim chat sekarang, nanti jadi antrean pertama jam 07.00 pagi.'}
              </p>
            </div>
          </div>

          {/* Order Summary Table */}
          <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-4 space-y-2.5 text-xs sm:text-sm">
            <div className="flex justify-between items-center pb-2 border-b border-slate-200/80">
              <span className="text-slate-500">Produk / Nominal</span>
              <span className="font-bold text-slate-900 text-right">{orderTitle}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-slate-500">Metode Layanan</span>
              <span className="font-semibold text-[#312E81] text-right">{methodName}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-slate-500">Target / Username</span>
              <span className="font-mono-num font-bold text-slate-800 bg-white px-2 py-0.5 rounded border border-slate-200">
                {targetAccount}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-slate-500">Metode Pembayaran</span>
              <span className="font-semibold text-slate-800">{paymentMethodName}</span>
            </div>
            <div className="flex justify-between items-center pt-2 border-t border-slate-200">
              <span className="font-semibold text-slate-700">Total Pembayaran</span>
              <span className="text-base sm:text-lg font-extrabold font-mono-num text-[#312E81]">
                {formatRupiah(totalPrice)}
              </span>
            </div>
          </div>

          {/* WhatsApp Message Preview */}
          <div>
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-xs font-semibold text-slate-600">
                Pratinjau pesan yang akan dikirim ke WhatsApp:
              </span>
              <button
                type="button"
                onClick={handleCopyMessage}
                className="inline-flex items-center gap-1 text-xs font-semibold text-[#0284C7] hover:text-[#312E81] transition"
              >
                {copied ? (
                  <>
                    <Check className="w-3.5 h-3.5 text-emerald-600" />
                    <span className="text-emerald-600">Tersalin!</span>
                  </>
                ) : (
                  <>
                    <Copy className="w-3.5 h-3.5" />
                    <span>Salin Teks</span>
                  </>
                )}
              </button>
            </div>
            <pre className="p-3.5 rounded-xl bg-[#ECFDF5]/60 border border-emerald-200/80 text-xs text-slate-800 whitespace-pre-wrap font-sans leading-relaxed max-h-40 overflow-y-auto">
              {whatsappMessage}
            </pre>
          </div>

          <div className="flex items-center gap-2 text-[11px] text-slate-500">
            <ShieldCheck className="w-4 h-4 text-emerald-600 shrink-0" />
            <span>
              Pesanan ini juga otomatis tersimpan di tab <strong>Menu Akun → Riwayat Pesanan</strong>.
            </span>
          </div>
        </div>

        {/* Footer CTA */}
        <div className="p-4 sm:px-6 bg-slate-50 border-t border-slate-200 flex flex-col sm:flex-row items-center gap-2.5">
          <a
            href={whatsappUrl}
            target="_blank"
            rel="noopener noreferrer"
            onClick={onClose}
            className="w-full sm:flex-1 py-3 px-5 rounded-xl bg-[#25D366] hover:bg-[#1EBE5D] text-white font-heading font-bold text-sm shadow-lg shadow-emerald-500/20 flex items-center justify-center gap-2 transition cursor-pointer"
          >
            <MessageCircle className="w-5 h-5 fill-white" />
            <span>Lanjut Chat ke WhatsApp Sekarang</span>
            <ExternalLink className="w-4 h-4 opacity-80" />
          </a>
          <button
            type="button"
            onClick={onClose}
            className="w-full sm:w-auto px-4 py-3 rounded-xl border border-slate-300 bg-white hover:bg-slate-100 text-slate-600 text-xs font-semibold transition"
          >
            Kembali
          </button>
        </div>
      </div>
    </div>
  );
};
