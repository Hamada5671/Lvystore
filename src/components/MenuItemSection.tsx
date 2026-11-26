import React, { useState, useMemo } from 'react';
import {
  Search,
  Gift,
  Sparkles,
  Clock,
  CheckCircle2,
  MessageCircle,
  ShieldCheck,
  UserCheck,
  Tag,
} from 'lucide-react';
import {
  GAME_ITEMS,
  GameItemProduct,
  PAYMENT_METHODS,
  formatRupiah,
} from '../data/storeData';
import { RobuxIcon } from './BrandIcons';

interface MenuItemSectionProps {
  onOrderItem: (
    item: GameItemProduct,
    robloxUsername: string,
    inGameNote: string,
    paymentMethodName: string
  ) => void;
}

const GAME_FILTERS = [
  'Semua Game',
  'Blox Fruits',
  'Dress To Impress',
  'Blade Ball',
  'King Legacy',
] as const;

export const MenuItemSection: React.FC<MenuItemSectionProps> = ({ onOrderItem }) => {
  const [selectedGame, setSelectedGame] = useState<string>('Semua Game');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [selectedItem, setSelectedItem] = useState<GameItemProduct>(GAME_ITEMS[0]);
  const [robloxUsername, setRobloxUsername] = useState<string>('');
  const [inGameNote, setInGameNote] = useState<string>('');
  const [selectedPaymentId, setSelectedPaymentId] = useState<string>('qris');
  const [errorMsg, setErrorMsg] = useState<string>('');

  const filteredItems = useMemo(() => {
    return GAME_ITEMS.filter((item) => {
      const matchGame = selectedGame === 'Semua Game' || item.game === selectedGame;
      const matchSearch =
        item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.game.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.category.toLowerCase().includes(searchQuery.toLowerCase());
      return matchGame && matchSearch;
    });
  }, [selectedGame, searchQuery]);

  const selectedPayment =
    PAYMENT_METHODS.find((p) => p.id === selectedPaymentId) || PAYMENT_METHODS[0];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!robloxUsername.trim() || robloxUsername.trim().length < 3) {
      setErrorMsg('Mohon isi Username Roblox tujuan gift terlebih dahulu (minimal 3 karakter).');
      return;
    }
    setErrorMsg('');
    onOrderItem(selectedItem, robloxUsername, inGameNote, selectedPayment.name);
  };

  return (
    <div className="space-y-6">
      {/* Banner Intro Menu Item */}
      <div className="bg-white rounded-2xl border border-slate-200 p-5 sm:p-6 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="space-y-1.5">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-sky-50 border border-sky-200 text-[#0284C7] text-xs font-bold">
            <Gift className="w-3.5 h-3.5" />
            <span>Katalog Menu Item & Gamepass In-Game</span>
          </div>
          <h2 className="font-heading font-extrabold text-xl sm:text-2xl text-slate-900">
            Beli Gamepass & Permanent Fruit Tanpa Login
          </h2>
          <p className="text-xs sm:text-sm text-slate-600 max-w-2xl">
            Item dikirim lewat fitur <strong>Gift In-Game</strong>. Kamu cukup isi Username Roblox, nanti kami kabari kalau perlu join server atau item langsung masuk inventory.
          </p>
        </div>

        {/* Search Input */}
        <div className="relative w-full md:w-72 shrink-0">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Cari Perm Buddha, VIP DTI, Blade Ball..."
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-slate-200 bg-slate-50 focus:bg-white text-xs sm:text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#312E81]"
          />
        </div>
      </div>

      {/* Filter Pills */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
        {GAME_FILTERS.map((game) => {
          const active = selectedGame === game;
          return (
            <button
              key={game}
              type="button"
              onClick={() => setSelectedGame(game)}
              className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold whitespace-nowrap transition cursor-pointer ${
                active
                  ? 'bg-[#312E81] text-white shadow-sm'
                  : 'bg-white text-slate-600 border border-slate-200 hover:border-sky-300 hover:text-[#312E81]'
              }`}
            >
              {game}
            </button>
          );
        })}
      </div>

      {/* Two Column Grid: Items + Checkout Sidebar */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left: Item Cards */}
        <div className="lg:col-span-8 grid grid-cols-1 sm:grid-cols-2 gap-3.5">
          {filteredItems.map((item) => {
            const isSelected = selectedItem.id === item.id;
            return (
              <div
                key={item.id}
                onClick={() => {
                  setSelectedItem(item);
                  setErrorMsg('');
                }}
                className={`group relative rounded-2xl p-4 border transition cursor-pointer flex flex-col justify-between ${
                  isSelected
                    ? 'bg-sky-50/70 border-2 border-[#312E81] shadow-md'
                    : 'bg-white border-slate-200 hover:border-sky-300 hover:shadow-xs'
                }`}
              >
                <div>
                  <div className="flex items-center justify-between gap-2 mb-2">
                    <span className="text-[11px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-md bg-indigo-50 text-[#312E81] border border-indigo-100">
                      {item.game}
                    </span>
                    {item.badge ? (
                      <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-amber-50 text-amber-800 border border-amber-200 flex items-center gap-1">
                        <Sparkles className="w-3 h-3 text-amber-500" />
                        {item.badge}
                      </span>
                    ) : (
                      <span className="text-[11px] font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full">
                        {item.stockStatus}
                      </span>
                    )}
                  </div>

                  <h3 className="font-heading font-bold text-slate-900 text-base group-hover:text-[#312E81] transition">
                    {item.name}
                  </h3>
                  <p className="text-xs text-slate-500 mt-1 line-clamp-2 leading-relaxed">
                    {item.description}
                  </p>
                </div>

                <div className="mt-4 pt-3 border-t border-slate-100 flex items-end justify-between">
                  <div>
                    <div className="flex items-center gap-1 text-xs text-slate-400">
                      <RobuxIcon className="w-3.5 h-3.5" variant="sky" />
                      <span>Senilai {item.robuxValue.toLocaleString('id-ID')} R$</span>
                    </div>
                    <div className="font-mono-num font-extrabold text-lg text-[#312E81] mt-0.5">
                      {formatRupiah(item.price)}
                    </div>
                  </div>

                  <div className="flex flex-col items-end">
                    <span className="text-[11px] text-slate-500 flex items-center gap-1">
                      <Clock className="w-3 h-3 text-sky-500" />
                      {item.processTime}
                    </span>
                    <span
                      className={`mt-1 text-xs font-bold px-3 py-1 rounded-lg transition ${
                        isSelected
                          ? 'bg-[#312E81] text-white'
                          : 'bg-slate-100 text-slate-700 group-hover:bg-sky-100 group-hover:text-[#312E81]'
                      }`}
                    >
                      {isSelected ? 'Terpilih ✓' : 'Pilih Item'}
                    </span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Right: Sticky Item Order Box */}
        <div className="lg:col-span-4 lg:sticky lg:top-24">
          <form
            onSubmit={handleSubmit}
            className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-4"
          >
            <div className="pb-3 border-b border-slate-100">
              <span className="text-[11px] font-bold uppercase tracking-wider text-[#0284C7]">
                Form Order Menu Item
              </span>
              <h3 className="font-heading font-bold text-lg text-slate-900 mt-0.5">
                {selectedItem.name}
              </h3>
              <div className="flex items-center gap-2 mt-1 text-xs text-slate-500">
                <Tag className="w-3.5 h-3.5 text-[#312E81]" />
                <span>{selectedItem.game}</span>
                <span>•</span>
                <span className="text-emerald-700 font-semibold">{selectedItem.deliveryMethod}</span>
              </div>
            </div>

            {/* Username Input */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                1. Username Roblox Penerima Gift <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <UserCheck className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                <input
                  type="text"
                  value={robloxUsername}
                  onChange={(e) => {
                    setRobloxUsername(e.target.value);
                    if (errorMsg) setErrorMsg('');
                  }}
                  placeholder="Contoh: budi_roblox99 (Bukan Display Name)"
                  className="w-full pl-9 pr-3.5 py-2.5 rounded-xl border border-slate-300 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                />
              </div>
            </div>

            {/* Optional Note */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                2. Catatan Tambahan (Opsional)
              </label>
              <input
                type="text"
                value={inGameNote}
                onChange={(e) => setInGameNote(e.target.value)}
                placeholder="Contoh: Gift di Sea 2 / Server VIP ya min"
                className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
              />
            </div>

            {/* Payment Selection */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                3. Pilih Metode Pembayaran
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

            {errorMsg && (
              <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium">
                {errorMsg}
              </div>
            )}

            {/* Total Box */}
            <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between">
              <div>
                <span className="text-xs text-slate-500 block">Total Harga Item</span>
                <span className="font-mono-num font-extrabold text-xl text-[#312E81]">
                  {formatRupiah(selectedItem.price)}
                </span>
              </div>
              <div className="text-right">
                <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-full">
                  <CheckCircle2 className="w-3.5 h-3.5" />
                  Ready Stock
                </span>
              </div>
            </div>

            <button
              type="submit"
              className="w-full py-3.5 px-4 rounded-xl bg-gradient-to-r from-[#312E81] to-[#0284C7] hover:from-[#26236B] hover:to-[#0369A1] text-white font-heading font-bold text-sm shadow-md flex items-center justify-center gap-2 transition cursor-pointer"
            >
              <MessageCircle className="w-4 h-4" />
              <span>Order Item via WhatsApp</span>
            </button>

            <div className="flex items-center justify-center gap-1.5 text-[11px] text-slate-500 text-center">
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
              <span>Langsung lanjut ke chat WhatsApp Lvysky Store</span>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
