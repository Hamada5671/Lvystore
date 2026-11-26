import React, { useState } from 'react';
import { X, Calculator, CheckCircle2, AlertTriangle, HelpCircle, ArrowRight } from 'lucide-react';
import { calculateGamepassPrice, formatRupiah } from '../data/storeData';

interface GamepassGuideModalProps {
  isOpen: boolean;
  onClose: () => void;
  initialRobux?: number;
  onApplyRobux?: (robux: number) => void;
}

export const GamepassGuideModal: React.FC<GamepassGuideModalProps> = ({
  isOpen,
  onClose,
  initialRobux = 500,
  onApplyRobux,
}) => {
  const [calcRobux, setCalcRobux] = useState<number>(initialRobux || 500);

  if (!isOpen) return null;

  const { gamepassPrice, robloxTax, netReceived } = calculateGamepassPrice(calcRobux);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs animate-fadeIn">
      <div className="bg-white rounded-2xl max-w-xl w-full border border-slate-200 shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="px-6 py-4 bg-gradient-to-r from-[#312E81] to-[#0284C7] text-white flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-white/15 flex items-center justify-center">
              <Calculator className="w-5 h-5 text-sky-200" />
            </div>
            <div>
              <h3 className="font-heading font-bold text-base sm:text-lg">
                Panduan & Kalkulator Gamepass (Robux 5 Hari)
              </h3>
              <p className="text-xs text-sky-100">
                Pajak 30% Roblox ditanggung Lvysky Store — kamu terima utuh!
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition"
            aria-label="Tutup panduan"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 overflow-y-auto space-y-5 text-sm text-slate-700">
          {/* Interactive Calculator Box */}
          <div className="p-4 rounded-xl bg-sky-50/80 border border-sky-200">
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#312E81] mb-2">
              Hitung Harga Gamepass yang Harus Kamu Buat:
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 items-center">
              <div>
                <span className="text-xs text-slate-500 block mb-1">Jumlah Robux yang Ingin Diterima:</span>
                <div className="relative">
                  <input
                    type="number"
                    min={1}
                    max={50000}
                    value={calcRobux || ''}
                    onChange={(e) => setCalcRobux(Math.max(0, parseInt(e.target.value, 10) || 0))}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 bg-white font-mono-num font-bold text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                  />
                  <span className="absolute right-3 top-2.5 text-xs font-bold text-slate-400">R$</span>
                </div>
              </div>

              <div className="p-3 rounded-xl bg-white border border-sky-200 flex flex-col justify-center">
                <span className="text-xs text-slate-500">Wajib Set Harga Gamepass:</span>
                <div className="flex items-baseline gap-1.5 mt-0.5">
                  <span className="text-xl font-extrabold font-mono-num text-[#312E81]">
                    {gamepassPrice.toLocaleString('id-ID')} R$
                  </span>
                  <span className="text-[11px] text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full font-semibold">
                    Terima Bersih {netReceived.toLocaleString('id-ID')} R$
                  </span>
                </div>
                <span className="text-[11px] text-slate-400 mt-0.5">
                  (Sudah termasuk potongan pajak Roblox 30% = {robloxTax.toLocaleString('id-ID')} R$)
                </span>
              </div>
            </div>

            {/* Quick preset buttons */}
            <div className="flex flex-wrap items-center gap-2 mt-3 pt-3 border-t border-sky-200/70">
              <span className="text-xs text-slate-500">Contoh Paket:</span>
              {[
                { r: 100, gp: 143, p: 16500 },
                { r: 500, gp: 715, p: 65000 },
                { r: 1000, gp: 1429, p: 155000 },
              ].map((item) => (
                <button
                  key={item.r}
                  type="button"
                  onClick={() => setCalcRobux(item.r)}
                  className={`text-xs px-2.5 py-1 rounded-lg border font-medium transition ${
                    calcRobux === item.r
                      ? 'bg-[#312E81] text-white border-[#312E81]'
                      : 'bg-white text-slate-700 border-slate-200 hover:border-sky-400'
                  }`}
                >
                  {item.r} R$ → Set {item.gp} R$ ({formatRupiah(item.p)})
                </button>
              ))}
            </div>
          </div>

          {/* Step-by-step instructions */}
          <div>
            <h4 className="font-heading font-bold text-slate-900 mb-3 flex items-center gap-2">
              <HelpCircle className="w-4 h-4 text-[#312E81]" />
              Cara Membuat Gamepass di Roblox (Cuma 1 Menit):
            </h4>
            <ol className="space-y-2.5">
              {[
                {
                  step: '1',
                  title: 'Buka Roblox Creator Dashboard',
                  desc: 'Masuk ke create.roblox.com lewat browser HP/PC, lalu pilih map default milikmu (biasanya bernama "[Username]\'s Place").',
                },
                {
                  step: '2',
                  title: 'Masuk ke Menu Passes (Gamepass)',
                  desc: 'Klik menu garis tiga di kiri atas → Monetization → Passes → klik tombol "Create a Pass".',
                },
                {
                  step: '3',
                  title: 'Matikan Fitur Regional Pricing (PENTING!)',
                  desc: 'Masuk ke bagian "Sales", aktifkan "Item for Sale", lalu PASTIKAN centang "Regional Pricing" DIMATIKAN (OFF) agar harga Robux tidak berubah.',
                },
                {
                  step: '4',
                  title: `Isi Harga Sebesar ${gamepassPrice.toLocaleString('id-ID')} Robux`,
                  desc: `Di kolom Price, ketik ${gamepassPrice} Robux. Di bawahnya akan tertulis "Creator Earnings (70%): ${netReceived} Robux". Klik Save Changes!`,
                },
              ].map((item) => (
                <li
                  key={item.step}
                  className="flex items-start gap-3 p-3 rounded-xl bg-slate-50 border border-slate-200/80"
                >
                  <span className="w-6 h-6 rounded-full bg-[#312E81] text-white font-bold text-xs flex items-center justify-center shrink-0 mt-0.5">
                    {item.step}
                  </span>
                  <div>
                    <p className="font-semibold text-slate-900 text-xs sm:text-sm">{item.title}</p>
                    <p className="text-xs text-slate-600 mt-0.5 leading-relaxed">{item.desc}</p>
                  </div>
                </li>
              ))}
            </ol>
          </div>

          {/* Important reminder */}
          <div className="p-3.5 rounded-xl bg-amber-50 border border-amber-200 flex items-start gap-2.5 text-xs text-amber-900">
            <AlertTriangle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
            <div>
              <span className="font-bold">Info Penting Pending 5 Hari:</span> Setelah Gamepass kamu dibeli oleh Admin Lvysky Store, Robux akan langsung terlihat di menu <strong>Pending Robux</strong> dan otomatis cair ke saldo utama setelah 5x24 jam sesuai kebijakan resmi Roblox.
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-3.5 bg-slate-50 border-t border-slate-200 flex items-center justify-between gap-3">
          <div className="flex items-center gap-1.5 text-xs text-emerald-700 font-medium">
            <CheckCircle2 className="w-4 h-4" />
            <span>Jika bingung, Admin siap pandu langsung di WhatsApp!</span>
          </div>
          <div className="flex items-center gap-2">
            {onApplyRobux && (
              <button
                type="button"
                onClick={() => {
                  onApplyRobux(calcRobux);
                  onClose();
                }}
                className="px-4 py-2 rounded-xl bg-[#312E81] hover:bg-[#252268] text-white text-xs font-semibold flex items-center gap-1.5 transition"
              >
                <span>Gunakan {calcRobux} R$</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            )}
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-xl border border-slate-300 bg-white hover:bg-slate-100 text-slate-700 text-xs font-semibold transition"
            >
              Mengerti
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
