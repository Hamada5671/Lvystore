import React, { useMemo, useState } from 'react';
import {
  Swords,
  UserCheck,
  MessageCircle,
  Minus,
  Plus,
  ShieldCheck,
  Info,
  Search,
} from 'lucide-react';
import {
  JOKI_CATEGORIES,
  JOKI_SERVICES,
  JokiCategoryId,
  JokiService,
  PAYMENT_METHODS,
  formatRupiahRange,
} from '../data/storeData';

interface MenuJokiSectionProps {
  onOrderJoki: (data: {
    service: JokiService;
    qty: number;
    robloxUsername: string;
    currentProgress: string;
    note: string;
    paymentMethodName: string;
  }) => void;
}

export const MenuJokiSection: React.FC<MenuJokiSectionProps> = ({ onOrderJoki }) => {
  const [categoryId, setCategoryId] = useState<JokiCategoryId | 'all'>('all');
  const [query, setQuery] = useState('');
  const [selected, setSelected] = useState<JokiService>(JOKI_SERVICES[0]);
  const [qty, setQty] = useState(1);
  const [robloxUsername, setRobloxUsername] = useState('');
  const [currentProgress, setCurrentProgress] = useState('');
  const [note, setNote] = useState('');
  const [paymentId, setPaymentId] = useState('qris');
  const [error, setError] = useState('');

  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    return JOKI_SERVICES.filter((s) => {
      const okCat = categoryId === 'all' || s.categoryId === categoryId;
      const okQuery =
        !q ||
        s.name.toLowerCase().includes(q) ||
        (s.requirement ?? '').toLowerCase().includes(q);
      return okCat && okQuery;
    });
  }, [categoryId, query]);

  const activeCategory = JOKI_CATEGORIES.find((c) => c.id === categoryId);
  const payment = PAYMENT_METHODS.find((p) => p.id === paymentId) || PAYMENT_METHODS[0];
  const selectedCategory = JOKI_CATEGORIES.find((c) => c.id === selected.categoryId);

  const effectiveQty = selected.unit ? qty : 1;
  const totalMin = selected.priceMin * effectiveQty;
  const totalMax = selected.priceMax * effectiveQty;
  const maxQty = selected.maxQty ?? 1;

  const pick = (s: JokiService) => {
    setSelected(s);
    setQty(1);
    setError('');
  };

  const changeQty = (next: number) => {
    if (Number.isNaN(next)) return;
    setQty(Math.min(maxQty, Math.max(1, Math.round(next))));
  };

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    if (robloxUsername.trim().length < 3) {
      setError('Username Roblox-nya diisi dulu ya (minimal 3 huruf).');
      return;
    }
    setError('');
    onOrderJoki({
      service: selected,
      qty: effectiveQty,
      robloxUsername,
      currentProgress,
      note,
      paymentMethodName: payment.name,
    });
  };

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-2xl border border-slate-200 p-5 sm:p-6 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="space-y-1.5">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-indigo-50 border border-indigo-200 text-[#312E81] text-xs font-bold">
            <Swords className="w-3.5 h-3.5" />
            <span>Joki Blox Fruits</span>
          </div>
          <h2 className="font-heading font-extrabold text-xl sm:text-2xl text-slate-900">
            Mau naik level tapi gak sempat main?
          </h2>
          <p className="text-xs sm:text-sm text-slate-600 max-w-2xl">
            Serahin aja ke kami. Harga di bawah berupa kisaran, soalnya tergantung kondisi akun dan
            antrean. Harga pas dikonfirmasi lewat WhatsApp sebelum kamu bayar.
          </p>
        </div>

        <div className="relative w-full md:w-72 shrink-0">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Cari CDK, Godhuman, raid..."
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-slate-200 bg-slate-50 focus:bg-white text-xs sm:text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#312E81]"
          />
        </div>
      </div>

      <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
        <button
          type="button"
          onClick={() => setCategoryId('all')}
          className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold whitespace-nowrap transition cursor-pointer ${
            categoryId === 'all'
              ? 'bg-[#312E81] text-white shadow-sm'
              : 'bg-white text-slate-600 border border-slate-200 hover:border-sky-300 hover:text-[#312E81]'
          }`}
        >
          Semua
        </button>
        {JOKI_CATEGORIES.map((c) => (
          <button
            key={c.id}
            type="button"
            onClick={() => setCategoryId(c.id)}
            className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold whitespace-nowrap transition cursor-pointer ${
              categoryId === c.id
                ? 'bg-[#312E81] text-white shadow-sm'
                : 'bg-white text-slate-600 border border-slate-200 hover:border-sky-300 hover:text-[#312E81]'
            }`}
          >
            {c.shortLabel}
          </button>
        ))}
      </div>

      {activeCategory && (
        <p className="text-xs sm:text-sm text-slate-500 -mt-2">{activeCategory.intro}</p>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        <div className="lg:col-span-8 space-y-6">
          {visible.length === 0 && (
            <div className="bg-white rounded-2xl border border-dashed border-slate-300 p-8 text-center text-sm text-slate-500">
              Belum ada layanan yang cocok. Coba kata kunci lain, atau tanya langsung lewat WhatsApp.
            </div>
          )}

          {JOKI_CATEGORIES.map((cat) => {
            const items = visible.filter((s) => s.categoryId === cat.id);
            if (items.length === 0) return null;
            return (
              <section key={cat.id} className="space-y-2.5">
                <h3 className="font-heading font-bold text-sm text-slate-800">{cat.label}</h3>
                <div className="bg-white rounded-2xl border border-slate-200 divide-y divide-slate-100 overflow-hidden">
                  {items.map((s) => {
                    const isSel = selected.id === s.id;
                    return (
                      <button
                        key={s.id}
                        type="button"
                        onClick={() => pick(s)}
                        className={`w-full text-left px-4 py-3.5 flex items-center justify-between gap-4 transition cursor-pointer ${
                          isSel ? 'bg-sky-50/70' : 'hover:bg-slate-50'
                        }`}
                      >
                        <div className="min-w-0">
                          <div
                            className={`text-sm font-semibold ${
                              isSel ? 'text-[#312E81]' : 'text-slate-900'
                            }`}
                          >
                            {s.name}
                          </div>
                          {s.requirement && (
                            <div className="text-xs text-slate-500 mt-0.5">
                              Syarat: {s.requirement}
                            </div>
                          )}
                        </div>
                        <div className="text-right shrink-0">
                          <div className="font-mono-num font-bold text-sm text-[#312E81]">
                            {formatRupiahRange(s.priceMin, s.priceMax)}
                          </div>
                          {s.unit && (
                            <div className="text-[11px] text-slate-500">{s.unit}</div>
                          )}
                        </div>
                      </button>
                    );
                  })}
                </div>
              </section>
            );
          })}
        </div>

        <div className="lg:col-span-4 lg:sticky lg:top-24">
          <form
            onSubmit={submit}
            className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-4"
          >
            <div className="pb-3 border-b border-slate-100">
              <span className="text-[11px] font-bold uppercase tracking-wider text-[#0284C7]">
                Form Order Joki
              </span>
              <h3 className="font-heading font-bold text-lg text-slate-900 mt-0.5">
                {selected.name}
              </h3>
              {selectedCategory && (
                <p className="text-xs text-slate-500 mt-0.5">{selectedCategory.label}</p>
              )}
              {selected.requirement && (
                <p className="text-xs text-amber-800 bg-amber-50 border border-amber-200 rounded-lg px-2.5 py-1.5 mt-2">
                  Syarat: {selected.requirement}
                </p>
              )}
            </div>

            {selected.unit && (
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  Jumlah ({selected.unit})
                </label>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => changeQty(qty - 1)}
                    className="w-9 h-9 rounded-lg border border-slate-300 flex items-center justify-center text-slate-600 hover:bg-slate-50 cursor-pointer"
                    aria-label="Kurangi"
                  >
                    <Minus className="w-4 h-4" />
                  </button>
                  <input
                    type="number"
                    min={1}
                    max={maxQty}
                    value={qty}
                    onChange={(e) => changeQty(Number(e.target.value))}
                    className="w-20 text-center py-2 rounded-lg border border-slate-300 text-sm font-mono-num focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                  />
                  <button
                    type="button"
                    onClick={() => changeQty(qty + 1)}
                    className="w-9 h-9 rounded-lg border border-slate-300 flex items-center justify-center text-slate-600 hover:bg-slate-50 cursor-pointer"
                    aria-label="Tambah"
                  >
                    <Plus className="w-4 h-4" />
                  </button>
                  <span className="text-[11px] text-slate-400">maks. {maxQty}</span>
                </div>
              </div>
            )}

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Username Roblox <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <UserCheck className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                <input
                  type="text"
                  value={robloxUsername}
                  onChange={(e) => {
                    setRobloxUsername(e.target.value);
                    if (error) setError('');
                  }}
                  placeholder="Username, bukan display name"
                  className="w-full pl-9 pr-3.5 py-2.5 rounded-xl border border-slate-300 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Progress akun sekarang
              </label>
              <input
                type="text"
                value={currentProgress}
                onChange={(e) => setCurrentProgress(e.target.value)}
                placeholder="Mis. Lv 1500, Sea 2, race V2"
                className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Catatan (boleh dikosongin)
              </label>
              <textarea
                value={note}
                onChange={(e) => setNote(e.target.value)}
                rows={2}
                placeholder="Target, jam yang gak boleh dipakai main, dll."
                className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81] resize-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Bayar pakai
              </label>
              <div className="grid grid-cols-2 gap-2">
                {PAYMENT_METHODS.slice(0, 6).map((pm) => (
                  <button
                    key={pm.id}
                    type="button"
                    onClick={() => setPaymentId(pm.id)}
                    className={`p-2 rounded-xl border text-left transition cursor-pointer ${
                      paymentId === pm.id
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

            {error && (
              <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium">
                {error}
              </div>
            )}

            <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
              <span className="text-xs text-slate-500 block">Estimasi harga</span>
              <span className="font-mono-num font-extrabold text-lg text-[#312E81]">
                {formatRupiahRange(totalMin, totalMax)}
              </span>
              <p className="text-[11px] text-slate-500 mt-1 flex items-start gap-1">
                <Info className="w-3 h-3 mt-0.5 shrink-0" />
                <span>Harga final dikonfirmasi admin dulu, kamu belum perlu bayar apa-apa.</span>
              </p>
            </div>

            <button
              type="submit"
              className="w-full py-3.5 px-4 rounded-xl bg-[#312E81] hover:bg-[#26236B] text-white font-heading font-bold text-sm flex items-center justify-center gap-2 transition cursor-pointer"
            >
              <MessageCircle className="w-4 h-4" />
              <span>Tanya & Order via WhatsApp</span>
            </button>

            <div className="flex items-start gap-1.5 text-[11px] text-slate-500">
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-600 shrink-0 mt-0.5" />
              <span>
                Jangan kirim password lewat form ini. Soal login dibahas langsung di chat setelah
                harga cocok.
              </span>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
