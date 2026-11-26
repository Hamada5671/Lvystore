import React, { useState } from 'react';
import {
  ShieldCheck,
  UserCheck,
  CheckCircle2,
  MessageCircle,
  History,
  Trash2,
  ExternalLink,
  Sparkles,
  KeyRound,
  BadgeCheck,
  SlidersHorizontal,
} from 'lucide-react';
import {
  ROBLOX_ACCOUNTS,
  RobloxAccountProduct,
  PAYMENT_METHODS,
  SavedOrder,
  formatRupiah,
} from '../data/storeData';

interface MenuAccountSectionProps {
  onOrderAccount: (
    account: RobloxAccountProduct,
    buyerNote: string,
    paymentMethodName: string
  ) => void;
  savedOrders: SavedOrder[];
  onClearOrders: () => void;
  adminWaNumber: string;
  onUpdateAdminWa: (newNumber: string) => void;
}

export const MenuAccountSection: React.FC<MenuAccountSectionProps> = ({
  onOrderAccount,
  savedOrders,
  onClearOrders,
  adminWaNumber,
  onUpdateAdminWa,
}) => {
  const [activeSubTab, setActiveSubTab] = useState<'catalog' | 'history'>('catalog');
  const [selectedAccount, setSelectedAccount] = useState<RobloxAccountProduct>(
    ROBLOX_ACCOUNTS[0]
  );
  const [buyerNote, setBuyerNote] = useState<string>('');
  const [selectedPaymentId, setSelectedPaymentId] = useState<string>('qris');
  const [tempWaInput, setTempWaInput] = useState<string>(adminWaNumber);
  const [waSavedBanner, setWaSavedBanner] = useState<boolean>(false);

  const selectedPayment =
    PAYMENT_METHODS.find((p) => p.id === selectedPaymentId) || PAYMENT_METHODS[0];

  const handleOrderSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onOrderAccount(selectedAccount, buyerNote, selectedPayment.name);
  };

  const handleSaveWa = (e: React.FormEvent) => {
    e.preventDefault();
    if (tempWaInput.trim()) {
      onUpdateAdminWa(tempWaInput.trim());
      setWaSavedBanner(true);
      setTimeout(() => setWaSavedBanner(false), 3000);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Banner + Sub-navigation */}
      <div className="bg-white rounded-2xl border border-slate-200 p-5 sm:p-6 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-indigo-50 border border-indigo-200 text-[#312E81] text-xs font-bold">
            <KeyRound className="w-3.5 h-3.5" />
            <span>Menu Akun & Riwayat Transaksi</span>
          </div>
          <h2 className="font-heading font-extrabold text-xl sm:text-2xl text-slate-900 mt-1.5">
            Stok Akun Roblox Aman & Riwayat Pesananmu
          </h2>
          <p className="text-xs sm:text-sm text-slate-600 max-w-2xl mt-0.5">
            Pilih akun Roblox polosan/sultan siap pakai bergaransi anti-hackback, atau cek kembali daftar invoice pesanan yang pernah kamu buat di perangkat ini.
          </p>
        </div>

        {/* Switcher between Stok Akun & Riwayat Pesanan */}
        <div className="inline-flex p-1 rounded-xl bg-slate-100 border border-slate-200 self-start md:self-center shrink-0">
          <button
            type="button"
            onClick={() => setActiveSubTab('catalog')}
            className={`px-3.5 py-2 rounded-lg text-xs font-bold flex items-center gap-1.5 transition cursor-pointer ${
              activeSubTab === 'catalog'
                ? 'bg-[#312E81] text-white shadow-xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <UserCheck className="w-3.5 h-3.5" />
            <span>Katalog Akun ({ROBLOX_ACCOUNTS.length})</span>
          </button>
          <button
            type="button"
            onClick={() => setActiveSubTab('history')}
            className={`px-3.5 py-2 rounded-lg text-xs font-bold flex items-center gap-1.5 transition cursor-pointer ${
              activeSubTab === 'history'
                ? 'bg-[#312E81] text-white shadow-xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <History className="w-3.5 h-3.5" />
            <span>Pesanan Saya ({savedOrders.length})</span>
          </button>
        </div>
      </div>

      {activeSubTab === 'catalog' ? (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          {/* Account Cards */}
          <div className="lg:col-span-8 space-y-4">
            {ROBLOX_ACCOUNTS.map((acc) => {
              const isSelected = selectedAccount.id === acc.id;
              return (
                <div
                  key={acc.id}
                  onClick={() => setSelectedAccount(acc)}
                  className={`rounded-2xl p-5 border transition cursor-pointer ${
                    isSelected
                      ? 'bg-sky-50/70 border-2 border-[#312E81] shadow-md'
                      : 'bg-white border-slate-200 hover:border-sky-300'
                  }`}
                >
                  <div className="flex flex-wrap items-center justify-between gap-2 mb-2.5">
                    <div className="flex items-center gap-2">
                      <span className="font-mono-num text-xs font-bold px-2.5 py-1 rounded-md bg-[#312E81] text-white">
                        #{acc.code}
                      </span>
                      <span className="text-xs font-semibold px-2.5 py-1 rounded-md bg-sky-100 text-[#0284C7]">
                        {acc.gameFocus}
                      </span>
                      <span className="text-xs font-medium px-2.5 py-1 rounded-md bg-emerald-50 text-emerald-700 border border-emerald-200">
                        {acc.ageStatus}
                      </span>
                    </div>

                    {acc.badge && (
                      <span className="text-xs font-bold px-2.5 py-0.5 rounded-full bg-amber-50 text-amber-800 border border-amber-200 flex items-center gap-1">
                        <Sparkles className="w-3 h-3 text-amber-500" />
                        {acc.badge}
                      </span>
                    )}
                  </div>

                  <h3 className="font-heading font-bold text-base sm:text-lg text-slate-900">
                    {acc.title}
                  </h3>

                  <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2 mt-3">
                    {acc.specs.map((spec, idx) => (
                      <li
                        key={idx}
                        className="flex items-start gap-2 text-xs text-slate-600 bg-white/80 p-2 rounded-lg border border-slate-100"
                      >
                        <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 shrink-0 mt-0.5" />
                        <span>{spec}</span>
                      </li>
                    ))}
                  </ul>

                  <div className="mt-4 pt-3 border-t border-slate-200/70 flex flex-wrap items-center justify-between gap-3">
                    <div className="flex items-center gap-3">
                      <div>
                        <span className="text-[11px] text-slate-400 block">Harga Akun</span>
                        <span className="font-mono-num font-extrabold text-xl text-[#312E81]">
                          {formatRupiah(acc.price)}
                        </span>
                      </div>
                      <div className="h-7 w-px bg-slate-200 hidden sm:block" />
                      <div className="text-xs text-slate-600">
                        <span className="flex items-center gap-1 font-medium text-emerald-700">
                          <BadgeCheck className="w-3.5 h-3.5" />
                          {acc.emailStatus}
                        </span>
                        <span className="text-[11px] text-slate-400">
                          Sisa stok: {acc.stock} akun ready
                        </span>
                      </div>
                    </div>

                    <button
                      type="button"
                      onClick={() => setSelectedAccount(acc)}
                      className={`px-4 py-2 rounded-xl text-xs font-bold transition ${
                        isSelected
                          ? 'bg-[#312E81] text-white'
                          : 'bg-slate-100 text-slate-700 hover:bg-sky-100 hover:text-[#312E81]'
                      }`}
                    >
                      {isSelected ? 'Akun Terpilih ✓' : 'Pilih Akun Ini'}
                    </button>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Right Checkout Box for Account */}
          <div className="lg:col-span-4 lg:sticky lg:top-24">
            <form
              onSubmit={handleOrderSubmit}
              className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-4"
            >
              <div className="pb-3 border-b border-slate-100">
                <span className="text-[11px] font-bold uppercase tracking-wider text-[#0284C7]">
                  Checkout Pembelian Akun
                </span>
                <div className="flex items-center gap-2 mt-1">
                  <span className="font-mono-num text-xs font-bold px-2 py-0.5 rounded bg-indigo-50 text-[#312E81]">
                    #{selectedAccount.code}
                  </span>
                  <span className="text-xs text-emerald-700 font-semibold">
                    Stok: {selectedAccount.stock} Ready
                  </span>
                </div>
                <h3 className="font-heading font-bold text-sm sm:text-base text-slate-900 mt-1.5 leading-snug">
                  {selectedAccount.title}
                </h3>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  1. Pilih Metode Pembayaran
                </label>
                <div className="grid grid-cols-2 gap-2">
                  {PAYMENT_METHODS.slice(0, 6).map((pm) => (
                    <button
                      key={pm.id}
                      type="button"
                      onClick={() => setSelectedPaymentId(pm.id)}
                      className={`p-2 rounded-xl border text-left transition cursor-pointer ${
                        selectedPaymentId === pm.id
                          ? 'bg-sky-50 border-[#312E81] text-[#312E81] font-bold'
                          : 'bg-slate-50/70 border-slate-200 text-slate-700 hover:bg-white'
                      }`}
                    >
                      <div className="text-xs font-semibold truncate">{pm.name}</div>
                      <div className="text-[10px] text-slate-500 truncate">{pm.feeText}</div>
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  2. Catatan ke Admin (Opsional)
                </label>
                <input
                  type="text"
                  value={buyerNote}
                  onChange={(e) => setBuyerNote(e.target.value)}
                  placeholder="Contoh: Minta screenshot inventory dulu ya min"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                />
              </div>

              <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between">
                <div>
                  <span className="text-xs text-slate-500 block">Harga Akun</span>
                  <span className="font-mono-num font-extrabold text-xl text-[#312E81]">
                    {formatRupiah(selectedAccount.price)}
                  </span>
                </div>
                <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-full">
                  Garansi Data Aman
                </span>
              </div>

              <button
                type="submit"
                className="w-full py-3.5 px-4 rounded-xl bg-gradient-to-r from-[#312E81] to-[#0284C7] hover:from-[#252268] hover:to-[#0369A1] text-white font-heading font-bold text-sm shadow-md flex items-center justify-center gap-2 transition cursor-pointer"
              >
                <MessageCircle className="w-4 h-4" />
                <span>Beli Akun via WhatsApp</span>
              </button>

              <div className="flex items-center justify-center gap-1.5 text-[11px] text-slate-500 text-center">
                <ShieldCheck className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
                <span>Data Username & Password dikirim pribadi via WA</span>
              </div>
            </form>
          </div>
        </div>
      ) : (
        /* Order History & Store WhatsApp Config */
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          <div className="lg:col-span-8 bg-white rounded-2xl border border-slate-200 p-5 sm:p-6 shadow-xs">
            <div className="flex items-center justify-between pb-4 mb-4 border-b border-slate-100">
              <div>
                <h3 className="font-heading font-bold text-base sm:text-lg text-slate-900">
                  Riwayat Pesanan Saya di Perangkat Ini
                </h3>
                <p className="text-xs text-slate-500">
                  Jika kamu belum sempat kirim chat ke WhatsApp, klik tombol &ldquo;Lanjut Chat WA&rdquo; di bawah.
                </p>
              </div>
              {savedOrders.length > 0 && (
                <button
                  type="button"
                  onClick={onClearOrders}
                  className="inline-flex items-center gap-1 text-xs text-rose-600 hover:text-rose-700 font-semibold px-3 py-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 transition"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                  <span>Hapus Riwayat</span>
                </button>
              )}
            </div>

            {savedOrders.length === 0 ? (
              <div className="text-center py-12 px-4">
                <div className="w-12 h-12 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
                  <History className="w-6 h-6" />
                </div>
                <p className="font-heading font-bold text-slate-700 text-sm">
                  Belum Ada Riwayat Pesanan
                </p>
                <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
                  Setiap kali kamu melakukan order Top Up Robux, Item, atau Akun, struk pesananmu akan tersimpan otomatis di sini.
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {savedOrders.map((ord) => (
                  <div
                    key={ord.invoiceId}
                    className="p-4 rounded-xl border border-slate-200 bg-slate-50/60 flex flex-col sm:flex-row sm:items-center justify-between gap-3"
                  >
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="font-mono-num text-xs font-bold px-2 py-0.5 rounded bg-indigo-50 text-[#312E81] border border-indigo-200">
                          #{ord.invoiceId}
                        </span>
                        <span className="text-[11px] text-slate-400">{ord.createdAt}</span>
                      </div>
                      <p className="font-heading font-bold text-slate-900 text-sm">
                        {ord.title} — <span className="text-[#312E81]">{formatRupiah(ord.totalPrice)}</span>
                      </p>
                      <p className="text-xs text-slate-600">
                        Metode: {ord.methodLabel} • Target: <strong>{ord.targetAccount}</strong> • Bayar: {ord.paymentMethod}
                      </p>
                    </div>

                    <a
                      href={ord.whatsappUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center justify-center gap-1.5 px-4 py-2.5 rounded-xl bg-[#25D366] hover:bg-[#1EBE5D] text-white text-xs font-bold shrink-0 transition"
                    >
                      <MessageCircle className="w-4 h-4" />
                      <span>Lanjut Chat WA</span>
                      <ExternalLink className="w-3.5 h-3.5" />
                    </a>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Right Panel: Quick Admin WhatsApp Number Customizer */}
          <div className="lg:col-span-4 bg-white rounded-2xl border border-slate-200 p-5 shadow-xs space-y-4">
            <div className="flex items-center gap-2 text-[#312E81]">
              <SlidersHorizontal className="w-4 h-4" />
              <h4 className="font-heading font-bold text-sm">
                Pengaturan Nomor WhatsApp Toko
              </h4>
            </div>
            <p className="text-xs text-slate-600 leading-relaxed">
              Seluruh tombol order di website <strong>Lvysky Store</strong> diarahkan ke nomor WhatsApp Admin di bawah ini. Pemilik toko dapat menyesuaikan nomor tujuan kapan saja:
            </p>
            <form onSubmit={handleSaveWa} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Nomor WhatsApp Admin (Awali 628 / 08):
                </label>
                <input
                  type="text"
                  value={tempWaInput}
                  onChange={(e) => setTempWaInput(e.target.value)}
                  placeholder="6281234567890"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-300 font-mono-num text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                />
              </div>
              <button
                type="submit"
                className="w-full py-2.5 px-4 rounded-xl bg-[#312E81] hover:bg-[#242166] text-white text-xs font-bold transition cursor-pointer"
              >
                Simpan Nomor WhatsApp Admin
              </button>
              {waSavedBanner && (
                <p className="text-xs text-emerald-700 bg-emerald-50 border border-emerald-200 p-2 rounded-lg text-center font-semibold">
                  ✓ Nomor WhatsApp tujuan berhasil diperbarui!
                </p>
              )}
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
