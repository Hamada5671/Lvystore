import React, { useState, useEffect } from 'react';
import {
  Clock,
  ShieldCheck,
  Zap,
  MessageCircle,
  CheckCircle2,
  AlertCircle,
  Calculator,
  HelpCircle,
  Sparkles,
  UserCheck,
  Gift,
  KeyRound,
  ChevronRight,
  Star,
  Table2,
  Lock,
  ExternalLink,
  Info,
  CreditCard,
  Sliders,
} from 'lucide-react';
import { LvyskyLogo, RobuxIcon } from './components/BrandIcons';
import {
  ROBUX_METHODS,
  ROBUX_PACKAGES,
  PAYMENT_METHODS,
  BUYER_TESTIMONIALS,
  DEFAULT_ADMIN_WA,
  RobuxMethodId,
  RobuxPackage,
  GameItemProduct,
  RobloxAccountProduct,
  SavedOrder,
  formatRupiah,
  calculateGamepassPrice,
} from './data/storeData';
import { useOperationalStatus, StatusOverride } from './utils/operationalClock';
import {
  generateInvoiceId,
  buildRobuxWhatsAppMessage,
  buildItemWhatsAppMessage,
  buildAccountWhatsAppMessage,
  buildWhatsAppUrl,
} from './utils/whatsappBuilder';
import { GamepassGuideModal } from './components/GamepassGuideModal';
import { WhatsAppOrderModal } from './components/WhatsAppOrderModal';
import { MenuItemSection } from './components/MenuItemSection';
import { MenuAccountSection } from './components/MenuAccountSection';

type MainTab = 'robux' | 'item' | 'account';

export function App() {
  // Navigation state
  const [activeTab, setActiveTab] = useState<MainTab>('robux');

  // Operational clock state (07.00 - 23.00 WIB)
  const [statusOverride, setStatusOverride] = useState<StatusOverride>('auto');
  const [showSchedulePopover, setShowSchedulePopover] = useState<boolean>(false);
  const operationalStatus = useOperationalStatus(statusOverride);

  // Admin WhatsApp number (stored in localStorage so store owner can customize)
  const [adminWaNumber, setAdminWaNumber] = useState<string>(() => {
    return localStorage.getItem('lvysky_admin_wa') || DEFAULT_ADMIN_WA;
  });

  // Saved Orders History
  const [savedOrders, setSavedOrders] = useState<SavedOrder[]>(() => {
    try {
      const raw = localStorage.getItem('lvysky_orders');
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  });

  // Robux Order State
  const [selectedMethodId, setSelectedMethodId] = useState<RobuxMethodId>('5hari');
  const [selectedPackageId, setSelectedPackageId] = useState<string>('5h-500');
  const [customEceranRobux, setCustomEceranRobux] = useState<number>(50);
  // For 500 R$ Via Login which has range Rp77.500 - Rp81.000
  const [login500Option, setLogin500Option] = useState<'reguler' | 'prioritas'>('reguler');

  // Form inputs for Robux checkout
  const [robloxUsername, setRobloxUsername] = useState<string>('');
  const [gamepassLinkOrMap, setGamepassLinkOrMap] = useState<string>('');
  const [confirmGamepassReady, setConfirmGamepassReady] = useState<boolean>(true);
  const [confirmAge18And2FA, setConfirmAge18And2FA] = useState<boolean>(true);
  const [loginPasswordOrNote, setLoginPasswordOrNote] = useState<string>('');
  const [backupCode2FA, setBackupCode2FA] = useState<string>('');
  const [buyerWhatsapp, setBuyerWhatsapp] = useState<string>('');
  const [selectedPaymentId, setSelectedPaymentId] = useState<string>('qris');
  const [formError, setFormError] = useState<string>('');

  // Modals
  const [isGuideModalOpen, setIsGuideModalOpen] = useState<boolean>(false);
  const [showFullPriceTable, setShowFullPriceTable] = useState<boolean>(false);
  const [waModalData, setWaModalData] = useState<{
    isOpen: boolean;
    invoiceId: string;
    orderTitle: string;
    methodName: string;
    targetAccount: string;
    paymentMethodName: string;
    totalPrice: number;
    whatsappMessage: string;
    whatsappUrl: string;
  }>({
    isOpen: false,
    invoiceId: '',
    orderTitle: '',
    methodName: '',
    targetAccount: '',
    paymentMethodName: '',
    totalPrice: 0,
    whatsappMessage: '',
    whatsappUrl: '',
  });

  // Sync method change with default package of that method
  const handleSelectMethod = (methodId: RobuxMethodId) => {
    setSelectedMethodId(methodId);
    setFormError('');
    const firstPopularOrDefault =
      ROBUX_PACKAGES.find((p) => p.methodId === methodId && p.isPopular) ||
      ROBUX_PACKAGES.find((p) => p.methodId === methodId);
    if (firstPopularOrDefault) {
      setSelectedPackageId(firstPopularOrDefault.id);
    }
  };

  // Current Method & Package objects
  const currentMethod =
    ROBUX_METHODS.find((m) => m.id === selectedMethodId) || ROBUX_METHODS[0];
  const packagesForMethod = ROBUX_PACKAGES.filter((p) => p.methodId === selectedMethodId);
  const currentPackage: RobuxPackage =
    packagesForMethod.find((p) => p.id === selectedPackageId) || packagesForMethod[0];

  // Computed Robux amount & total price
  const activeRobuxAmount = currentPackage?.isCustomEceran
    ? Math.max(1, customEceranRobux)
    : currentPackage?.robux || 100;

  const activeTotalPrice = (() => {
    if (!currentPackage) return 0;
    if (currentPackage.isCustomEceran) {
      return Math.max(1, customEceranRobux) * 155;
    }
    if (currentPackage.id === 'login-500') {
      return login500Option === 'prioritas' ? 81000 : 77500;
    }
    return currentPackage.price;
  })();

  const selectedPayment =
    PAYMENT_METHODS.find((p) => p.id === selectedPaymentId) || PAYMENT_METHODS[0];

  const gamepassCalc = calculateGamepassPrice(activeRobuxAmount);

  // Save order helper
  const saveOrderToHistory = (order: SavedOrder) => {
    const updated = [order, ...savedOrders].slice(0, 20);
    setSavedOrders(updated);
    try {
      localStorage.setItem('lvysky_orders', JSON.stringify(updated));
    } catch {
      // ignore storage quota errors
    }
  };

  const handleUpdateAdminWa = (newNumber: string) => {
    setAdminWaNumber(newNumber);
    try {
      localStorage.setItem('lvysky_admin_wa', newNumber);
    } catch {
      // ignore
    }
  };

  const handleClearOrders = () => {
    setSavedOrders([]);
    try {
      localStorage.removeItem('lvysky_orders');
    } catch {
      // ignore
    }
  };

  // Handle Robux Order Submit
  const handleRobuxOrderSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!robloxUsername.trim() || robloxUsername.trim().length < 3) {
      setFormError('Mohon masukkan Username Roblox kamu dengan benar (minimal 3 karakter).');
      return;
    }

    if (selectedMethodId === '5hari' && !confirmGamepassReady) {
      setFormError(
        `Mohon centang konfirmasi bahwa kamu siap mengatur harga Gamepass sebesar ${gamepassCalc.gamepassPrice} R$.`
      );
      return;
    }

    if (selectedMethodId === 'username' && !confirmAge18And2FA) {
      setFormError(
        'Metode Via Username (Instan) mewajibkan akun Roblox sudah 18+ dan Verifikasi 2 Langkah (2FA) aktif.'
      );
      return;
    }

    setFormError('');
    const invoiceId = generateInvoiceId();
    const variantLabel =
      currentPackage.id === 'login-500'
        ? login500Option === 'prioritas'
          ? 'Prioritas Pack Rp81.000'
          : 'Reguler Rp77.500'
        : currentPackage.isCustomEceran
        ? 'Eceran Custom Rp155/R$'
        : undefined;

    const message = buildRobuxWhatsAppMessage({
      invoiceId,
      methodId: selectedMethodId,
      methodTitle: currentMethod.shortTitle,
      robuxAmount: activeRobuxAmount,
      totalPrice: activeTotalPrice,
      variantLabel,
      robloxUsername,
      gamepassLinkOrMap,
      loginPasswordOrNote,
      backupCode2FA,
      paymentMethodName: selectedPayment.name,
      buyerWhatsapp,
    });

    const whatsappUrl = buildWhatsAppUrl(adminWaNumber, message);
    const orderTitle = `${activeRobuxAmount.toLocaleString('id-ID')} Robux`;

    // Save to local history
    saveOrderToHistory({
      invoiceId,
      createdAt: new Date().toLocaleString('id-ID', {
        day: '2-digit',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
      }),
      orderType: 'robux',
      title: orderTitle,
      methodLabel: currentMethod.shortTitle,
      targetAccount: robloxUsername.trim(),
      paymentMethod: selectedPayment.name,
      totalPrice: activeTotalPrice,
      whatsappUrl,
    });

    // Open WhatsApp confirmation modal & redirect
    setWaModalData({
      isOpen: true,
      invoiceId,
      orderTitle,
      methodName: currentMethod.shortTitle,
      targetAccount: robloxUsername.trim(),
      paymentMethodName: selectedPayment.name,
      totalPrice: activeTotalPrice,
      whatsappMessage: message,
      whatsappUrl,
    });

    // Direct redirect to WhatsApp in new tab
    window.open(whatsappUrl, '_blank', 'noopener,noreferrer');
  };

  // Handle Menu Item Order
  const handleOrderItem = (
    item: GameItemProduct,
    username: string,
    note: string,
    paymentMethodName: string
  ) => {
    const invoiceId = generateInvoiceId();
    const message = buildItemWhatsAppMessage({
      invoiceId,
      gameName: item.game,
      itemName: item.name,
      category: item.category,
      price: item.price,
      robloxUsername: username,
      inGameNote: note,
      paymentMethodName,
    });
    const whatsappUrl = buildWhatsAppUrl(adminWaNumber, message);

    saveOrderToHistory({
      invoiceId,
      createdAt: new Date().toLocaleString('id-ID', {
        day: '2-digit',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
      }),
      orderType: 'item',
      title: `${item.name} (${item.game})`,
      methodLabel: item.deliveryMethod,
      targetAccount: username.trim(),
      paymentMethod: paymentMethodName,
      totalPrice: item.price,
      whatsappUrl,
    });

    setWaModalData({
      isOpen: true,
      invoiceId,
      orderTitle: `${item.name} (${item.game})`,
      methodName: 'Menu Item • Gift In-Game',
      targetAccount: username.trim(),
      paymentMethodName,
      totalPrice: item.price,
      whatsappMessage: message,
      whatsappUrl,
    });

    window.open(whatsappUrl, '_blank', 'noopener,noreferrer');
  };

  // Handle Menu Account Order
  const handleOrderAccount = (
    account: RobloxAccountProduct,
    buyerNote: string,
    paymentMethodName: string
  ) => {
    const invoiceId = generateInvoiceId();
    const message = buildAccountWhatsAppMessage({
      invoiceId,
      accountCode: account.code,
      accountTitle: account.title,
      price: account.price,
      buyerNote,
      paymentMethodName,
    });
    const whatsappUrl = buildWhatsAppUrl(adminWaNumber, message);

    saveOrderToHistory({
      invoiceId,
      createdAt: new Date().toLocaleString('id-ID', {
        day: '2-digit',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
      }),
      orderType: 'account',
      title: `Akun #${account.code} (${account.gameFocus})`,
      methodLabel: 'Menu Akun Siap Pakai',
      targetAccount: account.code,
      paymentMethod: paymentMethodName,
      totalPrice: account.price,
      whatsappUrl,
    });

    setWaModalData({
      isOpen: true,
      invoiceId,
      orderTitle: `Akun #${account.code} — ${account.gameFocus}`,
      methodName: 'Beli Akun Roblox',
      targetAccount: `#${account.code}`,
      paymentMethodName,
      totalPrice: account.price,
      whatsappMessage: message,
      whatsappUrl,
    });

    window.open(whatsappUrl, '_blank', 'noopener,noreferrer');
  };

  // Quick select from comparison table
  const handleQuickSelectPackage = (pkg: RobuxPackage) => {
    setSelectedMethodId(pkg.methodId);
    setSelectedPackageId(pkg.id);
    setActiveTab('robux');
    setShowFullPriceTable(false);
    const el = document.getElementById('order-section');
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    }
  };

  useEffect(() => {
    // Close popover when clicking outside
    const handleClick = () => setShowSchedulePopover(false);
    if (showSchedulePopover) {
      window.addEventListener('click', handleClick);
    }
    return () => window.removeEventListener('click', handleClick);
  }, [showSchedulePopover]);

  return (
    <div className="min-h-screen flex flex-col bg-[#F8FAFC] text-[#0F172A]">
      {/* Top Info Strip */}
      <div className="bg-[#312E81] text-white text-xs py-2 px-4">
        <div className="max-w-6xl mx-auto flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <span className="px-2 py-0.5 rounded bg-sky-400/20 text-sky-200 font-semibold text-[11px]">
              LVYSKY STORE OFFICIAL
            </span>
            <span className="text-indigo-100 hidden sm:inline">
              Top Up Robux 5 Hari, Via Username Instan & Via Login — Proses Langsung oleh Admin Manusia di WhatsApp!
            </span>
          </div>
          <div className="flex items-center gap-3 ml-auto">
            <span className="text-sky-200 font-mono-num text-[11px]">
              Jam Operasional: 07.00 – 23.00 WIB
            </span>
          </div>
        </div>
      </div>

      {/* Sticky Main Header */}
      <header className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-slate-200/90 shadow-2xs">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 h-18 flex items-center justify-between gap-3">
          {/* Brand Logo */}
          <button
            type="button"
            onClick={() => setActiveTab('robux')}
            className="text-left focus:outline-none cursor-pointer"
          >
            <LvyskyLogo size="md" />
          </button>

          {/* Desktop Navigation Tabs: Top Up Robux | Menu Item | Menu Akun */}
          <nav className="hidden md:flex items-center gap-1.5 p-1.5 rounded-2xl bg-slate-100/90 border border-slate-200/80">
            <button
              type="button"
              onClick={() => setActiveTab('robux')}
              className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-heading font-bold flex items-center gap-2 transition cursor-pointer ${
                activeTab === 'robux'
                  ? 'bg-[#312E81] text-white shadow-xs'
                  : 'text-slate-600 hover:text-[#312E81] hover:bg-white/60'
              }`}
            >
              <RobuxIcon
                className="w-4 h-4"
                variant={activeTab === 'robux' ? 'sky' : 'indigo'}
              />
              <span>Top Up Robux</span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('item')}
              className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-heading font-bold flex items-center gap-2 transition cursor-pointer ${
                activeTab === 'item'
                  ? 'bg-[#312E81] text-white shadow-xs'
                  : 'text-slate-600 hover:text-[#312E81] hover:bg-white/60'
              }`}
            >
              <Gift className="w-4 h-4" />
              <span>Menu Item</span>
              <span
                className={`text-[10px] px-1.5 py-0.5 rounded-full font-bold ${
                  activeTab === 'item'
                    ? 'bg-sky-400/25 text-sky-100'
                    : 'bg-sky-100 text-[#0284C7]'
                }`}
              >
                Gift
              </span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('account')}
              className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-heading font-bold flex items-center gap-2 transition cursor-pointer ${
                activeTab === 'account'
                  ? 'bg-[#312E81] text-white shadow-xs'
                  : 'text-slate-600 hover:text-[#312E81] hover:bg-white/60'
              }`}
            >
              <KeyRound className="w-4 h-4" />
              <span>Menu Akun</span>
              {savedOrders.length > 0 && (
                <span
                  className={`text-[10px] px-1.5 py-0.5 rounded-full font-mono-num font-bold ${
                    activeTab === 'account'
                      ? 'bg-emerald-400/30 text-emerald-100'
                      : 'bg-emerald-100 text-emerald-800'
                  }`}
                >
                  {savedOrders.length}
                </span>
              )}
            </button>
          </nav>

          {/* Right Live Operational Status Badge (07.00 - 23.00 WIB) */}
          <div className="relative" onClick={(e) => e.stopPropagation()}>
            <button
              type="button"
              onClick={() => setShowSchedulePopover((prev) => !prev)}
              className={`px-3 sm:px-3.5 py-2 rounded-xl border text-left flex items-center gap-2.5 transition cursor-pointer ${
                operationalStatus.isOnline
                  ? 'bg-emerald-50/90 border-emerald-200 hover:bg-emerald-100/70'
                  : 'bg-amber-50/90 border-amber-200 hover:bg-amber-100/70'
              }`}
              title="Klik untuk info jam operasional 07.00 - 23.00 WIB"
            >
              <span
                className={`w-2.5 h-2.5 rounded-full shrink-0 ${
                  operationalStatus.isOnline
                    ? 'bg-emerald-500 status-dot-online'
                    : 'bg-amber-500'
                }`}
              />
              <div className="leading-tight">
                <div className="flex items-center gap-1.5">
                  <span
                    className={`text-xs font-heading font-bold ${
                      operationalStatus.isOnline ? 'text-emerald-900' : 'text-amber-900'
                    }`}
                  >
                    {operationalStatus.statusLabel}
                  </span>
                  <span className="hidden sm:inline-block text-[10px] font-mono-num px-1.5 py-0.2 rounded bg-white/80 text-slate-600 border border-slate-200/60">
                    {operationalStatus.timeStringWIB}
                  </span>
                </div>
                <span
                  className={`block text-[10px] font-medium ${
                    operationalStatus.isOnline ? 'text-emerald-700' : 'text-amber-700'
                  }`}
                >
                  Online 07.00 – 23.00 WIB
                </span>
              </div>
            </button>

            {/* Schedule & Status Simulator Popover */}
            {showSchedulePopover && (
              <div className="absolute right-0 mt-2 w-80 bg-white rounded-2xl border border-slate-200 shadow-xl p-4 z-50 space-y-3 text-xs">
                <div className="flex items-center justify-between pb-2 border-b border-slate-100">
                  <span className="font-heading font-bold text-slate-900 flex items-center gap-1.5">
                    <Clock className="w-4 h-4 text-[#312E81]" />
                    Jam Operasional Lvysky Store
                  </span>
                  <span className="font-mono-num text-[11px] font-semibold text-[#0284C7]">
                    {operationalStatus.timeStringWIB}
                  </span>
                </div>

                <div className="space-y-1.5 text-slate-600">
                  <div className="flex justify-between">
                    <span>Senin – Minggu:</span>
                    <span className="font-bold text-emerald-700">07.00 – 23.00 WIB</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Istirahat Malam:</span>
                    <span className="font-medium text-slate-500">23.01 – 06.59 WIB</span>
                  </div>
                </div>

                <p className="p-2.5 rounded-xl bg-slate-50 border border-slate-200/80 text-[11px] text-slate-600 leading-relaxed">
                  {operationalStatus.subLabel}
                </p>

                {/* Simulator toggle so owner can preview both states */}
                <div className="pt-2 border-t border-slate-100">
                  <span className="text-[10px] font-semibold uppercase tracking-wider text-slate-400 flex items-center gap-1 mb-1.5">
                    <Sliders className="w-3 h-3" />
                    Mode Indikator Status:
                  </span>
                  <div className="grid grid-cols-3 gap-1">
                    {[
                      { id: 'auto', label: 'Otomatis WIB' },
                      { id: 'force_online', label: 'Tes Online' },
                      { id: 'force_offline', label: 'Tes Istirahat' },
                    ].map((opt) => (
                      <button
                        key={opt.id}
                        type="button"
                        onClick={() => setStatusOverride(opt.id as StatusOverride)}
                        className={`py-1 px-2 rounded-lg text-[11px] font-semibold border transition cursor-pointer ${
                          statusOverride === opt.id
                            ? 'bg-[#312E81] text-white border-[#312E81]'
                            : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'
                        }`}
                      >
                        {opt.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Mobile Navigation Bar (Top Up Robux | Menu Item | Menu Akun) */}
        <div className="md:hidden border-t border-slate-200/80 bg-slate-50/90 px-3 py-1.5 grid grid-cols-3 gap-1.5">
          <button
            type="button"
            onClick={() => setActiveTab('robux')}
            className={`py-2 px-2 rounded-xl text-xs font-heading font-bold flex items-center justify-center gap-1.5 transition ${
              activeTab === 'robux'
                ? 'bg-[#312E81] text-white shadow-2xs'
                : 'bg-white text-slate-600 border border-slate-200/70'
            }`}
          >
            <RobuxIcon
              className="w-3.5 h-3.5"
              variant={activeTab === 'robux' ? 'sky' : 'indigo'}
            />
            <span>Top Up Robux</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('item')}
            className={`py-2 px-2 rounded-xl text-xs font-heading font-bold flex items-center justify-center gap-1.5 transition ${
              activeTab === 'item'
                ? 'bg-[#312E81] text-white shadow-2xs'
                : 'bg-white text-slate-600 border border-slate-200/70'
            }`}
          >
            <Gift className="w-3.5 h-3.5" />
            <span>Menu Item</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('account')}
            className={`py-2 px-2 rounded-xl text-xs font-heading font-bold flex items-center justify-center gap-1.5 transition ${
              activeTab === 'account'
                ? 'bg-[#312E81] text-white shadow-2xs'
                : 'bg-white text-slate-600 border border-slate-200/70'
            }`}
          >
            <KeyRound className="w-3.5 h-3.5" />
            <span>Menu Akun</span>
            {savedOrders.length > 0 && (
              <span className="text-[10px] px-1.5 rounded-full bg-emerald-500 text-white">
                {savedOrders.length}
              </span>
            )}
          </button>
        </div>
      </header>

      {/* Main Content Container */}
      <main className="flex-1 max-w-6xl w-full mx-auto px-4 sm:px-6 py-6 sm:py-8 space-y-8">
        {activeTab === 'robux' && (
          <>
            {/* Compact Natural Storefront Hero Banner */}
            <section className="relative rounded-3xl bg-white border border-slate-200/90 p-5 sm:p-7 shadow-xs overflow-hidden">
              <div className="absolute -right-16 -top-16 w-64 h-64 rounded-full bg-sky-100/60 blur-2xl pointer-events-none" />
              <div className="absolute -left-16 -bottom-16 w-64 h-64 rounded-full bg-indigo-100/50 blur-2xl pointer-events-none" />

              <div className="relative grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
                <div className="lg:col-span-7 space-y-3">
                  <div className="inline-flex flex-wrap items-center gap-2">
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-indigo-50 border border-indigo-200/80 text-[#312E81] text-xs font-bold">
                      <Sparkles className="w-3.5 h-3.5 text-[#59ADEB]" />
                      <span>Lvysky Store • Top Up Robux & Item Roblox</span>
                    </span>
                    <span
                      className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold border ${
                        operationalStatus.isOnline
                          ? 'bg-emerald-50 border-emerald-200 text-emerald-800'
                          : 'bg-amber-50 border-amber-200 text-amber-800'
                      }`}
                    >
                      <span
                        className={`w-2 h-2 rounded-full ${
                          operationalStatus.isOnline ? 'bg-emerald-500' : 'bg-amber-500'
                        }`}
                      />
                      <span>
                        {operationalStatus.isOnline
                          ? 'Buka Sekarang (07.00 – 23.00 WIB)'
                          : 'Jam Buka: 07.00 – 23.00 WIB'}
                      </span>
                    </span>
                  </div>

                  <h1 className="font-heading font-extrabold text-2xl sm:text-3xl lg:text-[34px] text-slate-900 leading-tight">
                    Top Up Robux Murah, Rapi &{' '}
                    <span className="text-[#312E81] underline decoration-[#59ADEB] decoration-4 underline-offset-4">
                      Langsung Diproses Admin
                    </span>
                  </h1>

                  <p className="text-slate-600 text-xs sm:text-sm leading-relaxed max-w-xl">
                    Pilih metode sesuai kebutuhanmu: <strong>Robux 5 Hari (Gamepass)</strong> mulai Rp130/R$, <strong>Via Username Instan</strong> 5–10 menit tanpa password, atau <strong>Via Login</strong> langsung cair. Setelah pilih nominal, pesananmu langsung diarahkan ke WhatsApp Admin Lvysky Store!
                  </p>

                  {/* Trust Highlights */}
                  <div className="pt-1 flex flex-wrap items-center gap-3 text-xs text-slate-700">
                    <div className="flex items-center gap-1.5 bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200/80">
                      <ShieldCheck className="w-4 h-4 text-emerald-600" />
                      <span className="font-semibold">Admin Manusia Asli (Bukan Bot)</span>
                    </div>
                    <div className="flex items-center gap-1.5 bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200/80">
                      <Zap className="w-4 h-4 text-amber-500" />
                      <span className="font-semibold">Pajak 30% Gamepass Ditanggung Toko</span>
                    </div>
                    <button
                      type="button"
                      onClick={() => setShowFullPriceTable((prev) => !prev)}
                      className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-sky-50 hover:bg-sky-100 text-[#0284C7] border border-sky-200 font-bold transition cursor-pointer"
                    >
                      <Table2 className="w-4 h-4" />
                      <span>
                        {showFullPriceTable ? 'Tutup Tabel Harga' : 'Lihat Daftar Harga Lengkap'}
                      </span>
                    </button>
                  </div>
                </div>

                {/* Right Summary Cards of the 3 Methods */}
                <div className="lg:col-span-5 grid grid-cols-1 gap-2.5">
                  <div
                    onClick={() => handleSelectMethod('5hari')}
                    className={`p-3.5 rounded-2xl border transition cursor-pointer flex items-center justify-between gap-3 ${
                      selectedMethodId === '5hari'
                        ? 'bg-indigo-50/70 border-[#312E81] shadow-2xs'
                        : 'bg-slate-50/80 border-slate-200 hover:bg-white'
                    }`}
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-heading font-extrabold text-[#312E81]">
                          1. Robux 5 Hari (5H / Gamepass)
                        </span>
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                          Termurah
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-600 mt-0.5">
                        1 R$ ~Rp155 • 100 R$ Rp16.500 • 500 R$ Rp65.000 • 1.000 R$ Rp155.000
                      </p>
                    </div>
                    <ChevronRight className="w-4 h-4 text-slate-400 shrink-0" />
                  </div>

                  <div
                    onClick={() => handleSelectMethod('username')}
                    className={`p-3.5 rounded-2xl border transition cursor-pointer flex items-center justify-between gap-3 ${
                      selectedMethodId === 'username'
                        ? 'bg-sky-50/80 border-[#0284C7] shadow-2xs'
                        : 'bg-slate-50/80 border-slate-200 hover:bg-white'
                    }`}
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-heading font-extrabold text-[#0284C7]">
                          2. Robux Via Username (Instan 5–10 Menit)
                        </span>
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-sky-100 text-[#0284C7]">
                          Tanpa Password
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-600 mt-0.5">
                        65 R$ Rp10.075 • 100 R$ Rp16.000 • 1.000 R$ Rp160.000 • Wajib 18+ & 2FA
                      </p>
                    </div>
                    <ChevronRight className="w-4 h-4 text-slate-400 shrink-0" />
                  </div>

                  <div
                    onClick={() => handleSelectMethod('login')}
                    className={`p-3.5 rounded-2xl border transition cursor-pointer flex items-center justify-between gap-3 ${
                      selectedMethodId === 'login'
                        ? 'bg-indigo-50/70 border-[#312E81] shadow-2xs'
                        : 'bg-slate-50/80 border-slate-200 hover:bg-white'
                    }`}
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-heading font-extrabold text-slate-900">
                          3. Robux Via Login (In-App Resmi)
                        </span>
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-indigo-100 text-[#312E81]">
                          Langsung Cair
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-600 mt-0.5">
                        80 R$ Rp16.500 • 160 R$ Rp31.000 • 500 R$ Rp77.500 • 1.000 R$ Rp162.000
                      </p>
                    </div>
                    <ChevronRight className="w-4 h-4 text-slate-400 shrink-0" />
                  </div>
                </div>
              </div>

              {/* Collapsible Full Side-by-Side Price List Table */}
              {showFullPriceTable && (
                <div className="mt-6 pt-6 border-t border-slate-200 animate-fadeIn">
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <h3 className="font-heading font-bold text-sm sm:text-base text-slate-900">
                        Tabel Perbandingan Harga Resmi Lvysky Store
                      </h3>
                      <p className="text-xs text-slate-500">
                        Klik salah satu baris paket di bawah untuk langsung memilih dan order ke WhatsApp.
                      </p>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {/* Column 1: 5 Hari */}
                    <div className="rounded-2xl border border-slate-200 bg-slate-50/60 p-4">
                      <div className="pb-2.5 mb-2.5 border-b border-slate-200">
                        <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded">
                          METODE 1 • PALING TERJANGKAU
                        </span>
                        <h4 className="font-heading font-bold text-sm text-slate-900 mt-1">
                          Robux 5 Hari (5H / Gamepass)
                        </h4>
                        <p className="text-[11px] text-slate-500">
                          ~Rp130–Rp155/R$ • Masuk setelah 5 hari kerja
                        </p>
                      </div>
                      <div className="space-y-1.5">
                        {ROBUX_PACKAGES.filter((p) => p.methodId === '5hari').map((pkg) => (
                          <button
                            key={pkg.id}
                            type="button"
                            onClick={() => handleQuickSelectPackage(pkg)}
                            className="w-full p-2 rounded-xl bg-white hover:bg-sky-50 border border-slate-200/80 flex items-center justify-between text-xs transition cursor-pointer"
                          >
                            <span className="font-semibold text-slate-800">
                              {pkg.isCustomEceran ? '1 Robux (Eceran)' : `${pkg.robux.toLocaleString('id-ID')} Robux`}
                            </span>
                            <span className="font-mono-num font-bold text-[#312E81]">
                              {pkg.isCustomEceran ? '~Rp155' : formatRupiah(pkg.price)}
                            </span>
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Column 2: Via Username */}
                    <div className="rounded-2xl border border-slate-200 bg-slate-50/60 p-4">
                      <div className="pb-2.5 mb-2.5 border-b border-slate-200">
                        <span className="text-[11px] font-bold text-[#0284C7] bg-sky-50 px-2 py-0.5 rounded">
                          METODE 2 • TANPA PASSWORD
                        </span>
                        <h4 className="font-heading font-bold text-sm text-slate-900 mt-1">
                          Robux Via Username (Instan)
                        </h4>
                        <p className="text-[11px] text-slate-500">
                          Proses 5–10 menit • Wajib Akun 18+ & 2FA Aktif
                        </p>
                      </div>
                      <div className="space-y-1.5">
                        {ROBUX_PACKAGES.filter((p) => p.methodId === 'username').map((pkg) => (
                          <button
                            key={pkg.id}
                            type="button"
                            onClick={() => handleQuickSelectPackage(pkg)}
                            className="w-full p-2 rounded-xl bg-white hover:bg-sky-50 border border-slate-200/80 flex items-center justify-between text-xs transition cursor-pointer"
                          >
                            <span className="font-semibold text-slate-800">
                              {pkg.robux.toLocaleString('id-ID')} Robux
                            </span>
                            <span className="font-mono-num font-bold text-[#0284C7]">
                              ~{formatRupiah(pkg.price)}
                            </span>
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Column 3: Via Login */}
                    <div className="rounded-2xl border border-slate-200 bg-slate-50/60 p-4">
                      <div className="pb-2.5 mb-2.5 border-b border-slate-200">
                        <span className="text-[11px] font-bold text-[#312E81] bg-indigo-50 px-2 py-0.5 rounded">
                          METODE 3 • LANGSUNG MASUK
                        </span>
                        <h4 className="font-heading font-bold text-sm text-slate-900 mt-1">
                          Robux Via Login
                        </h4>
                        <p className="text-[11px] text-slate-500">
                          Proses cepat oleh Admin • Saldo langsung cair
                        </p>
                      </div>
                      <div className="space-y-1.5">
                        {ROBUX_PACKAGES.filter((p) => p.methodId === 'login').map((pkg) => (
                          <button
                            key={pkg.id}
                            type="button"
                            onClick={() => handleQuickSelectPackage(pkg)}
                            className="w-full p-2 rounded-xl bg-white hover:bg-sky-50 border border-slate-200/80 flex items-center justify-between text-xs transition cursor-pointer"
                          >
                            <span className="font-semibold text-slate-800">
                              {pkg.robux.toLocaleString('id-ID')} Robux
                            </span>
                            <span className="font-mono-num font-bold text-[#312E81]">
                              {pkg.priceRangeLabel || `~${formatRupiah(pkg.price)}`}
                            </span>
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </section>

            {/* MAIN ORDER WORKSPACE: Left 8 Cols Steps + Right 4 Cols Sticky Summary */}
            <section id="order-section" className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
              {/* Left Column: Steps 1, 2, 3, 4 */}
              <div className="lg:col-span-8 space-y-6">
                {/* STEP 1: PILIH METODE TOP UP ROBUX */}
                <div className="bg-white rounded-2xl border border-slate-200/90 p-5 sm:p-6 shadow-xs space-y-4">
                  <div className="flex items-center justify-between gap-2">
                    <div className="flex items-center gap-2.5">
                      <span className="w-7 h-7 rounded-xl bg-[#312E81] text-white font-heading font-extrabold text-xs flex items-center justify-center">
                        1
                      </span>
                      <div>
                        <h2 className="font-heading font-bold text-base sm:text-lg text-slate-900">
                          Pilih Metode Top Up Robux
                        </h2>
                        <p className="text-xs text-slate-500">
                          Sesuaikan dengan kecepatan proses dan jenis akun Roblox kamu
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* 3 Method Cards */}
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    {ROBUX_METHODS.map((method) => {
                      const active = selectedMethodId === method.id;
                      return (
                        <button
                          key={method.id}
                          type="button"
                          onClick={() => handleSelectMethod(method.id)}
                          className={`text-left p-4 rounded-2xl border transition flex flex-col justify-between cursor-pointer ${
                            active
                              ? 'bg-sky-50/80 border-2 border-[#312E81] shadow-sm'
                              : 'bg-slate-50/60 border-slate-200 hover:bg-white hover:border-sky-300'
                          }`}
                        >
                          <div>
                            <div className="flex items-center justify-between gap-1 mb-2">
                              <span
                                className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${
                                  method.badgeColor === 'emerald'
                                    ? 'bg-emerald-100 text-emerald-800'
                                    : method.badgeColor === 'sky'
                                    ? 'bg-sky-100 text-[#0284C7]'
                                    : 'bg-indigo-100 text-[#312E81]'
                                }`}
                              >
                                {method.badgeText}
                              </span>
                              {active && (
                                <CheckCircle2 className="w-4 h-4 text-[#312E81] shrink-0" />
                              )}
                            </div>

                            <h3 className="font-heading font-extrabold text-sm text-slate-900 leading-snug">
                              {method.shortTitle}
                            </h3>
                            <p className="text-[11px] text-slate-500 mt-1 leading-relaxed">
                              {method.subtitle}
                            </p>
                          </div>

                          <div className="mt-3 pt-2.5 border-t border-slate-200/70 flex items-center justify-between text-[11px]">
                            <span className="font-mono-num font-bold text-[#312E81]">
                              {method.rateSummary}
                            </span>
                          </div>
                        </button>
                      );
                    })}
                  </div>

                  {/* Method specific info callout */}
                  <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/90 space-y-2">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <div className="flex items-center gap-2">
                        <Info className="w-4 h-4 text-[#312E81]" />
                        <span className="font-heading font-bold text-xs sm:text-sm text-slate-900">
                          Ketentuan {currentMethod.title}:
                        </span>
                      </div>
                      <span className="text-[11px] font-semibold text-[#0284C7] bg-sky-50 px-2.5 py-0.5 rounded-full border border-sky-200">
                        ⏱️ {currentMethod.processTime}
                      </span>
                    </div>

                    <ul className="grid grid-cols-1 sm:grid-cols-2 gap-1.5 pt-1">
                      {currentMethod.requirements.map((req, i) => (
                        <li key={i} className="flex items-start gap-2 text-xs text-slate-600">
                          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 shrink-0 mt-0.5" />
                          <span>{req}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>

                {/* STEP 2: PILIH NOMINAL ROBUX */}
                <div className="bg-white rounded-2xl border border-slate-200/90 p-5 sm:p-6 shadow-xs space-y-4">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div className="flex items-center gap-2.5">
                      <span className="w-7 h-7 rounded-xl bg-[#312E81] text-white font-heading font-extrabold text-xs flex items-center justify-center">
                        2
                      </span>
                      <div>
                        <h2 className="font-heading font-bold text-base sm:text-lg text-slate-900">
                          Pilih Nominal {currentMethod.shortTitle}
                        </h2>
                        <p className="text-xs text-slate-500">
                          {currentMethod.referenceNote}
                        </p>
                      </div>
                    </div>

                    {selectedMethodId === '5hari' && (
                      <button
                        type="button"
                        onClick={() => setIsGuideModalOpen(true)}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-indigo-50 hover:bg-indigo-100 text-[#312E81] text-xs font-bold transition cursor-pointer"
                      >
                        <Calculator className="w-3.5 h-3.5" />
                        <span>Panduan & Kalkulator Gamepass</span>
                      </button>
                    )}
                  </div>

                  {/* Nominal Cards Grid */}
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                    {packagesForMethod.map((pkg) => {
                      const isSelected = currentPackage?.id === pkg.id;
                      return (
                        <div
                          key={pkg.id}
                          onClick={() => {
                            setSelectedPackageId(pkg.id);
                            setFormError('');
                          }}
                          className={`relative rounded-2xl p-3.5 sm:p-4 border transition cursor-pointer flex flex-col justify-between ${
                            isSelected
                              ? 'bg-sky-50/90 border-2 border-[#312E81] shadow-sm'
                              : 'bg-white border-slate-200 hover:border-sky-300 hover:bg-slate-50/40'
                          }`}
                        >
                          {pkg.badge && (
                            <span
                              className={`self-start text-[10px] font-bold px-2 py-0.5 rounded-full mb-2 ${
                                pkg.isPopular
                                  ? 'bg-amber-100 text-amber-900 border border-amber-300'
                                  : 'bg-indigo-50 text-[#312E81] border border-indigo-200'
                              }`}
                            >
                              {pkg.badge}
                            </span>
                          )}

                          <div>
                            <div className="flex items-center gap-2">
                              <RobuxIcon
                                className="w-5 h-5 shrink-0"
                                variant={isSelected ? 'indigo' : 'sky'}
                              />
                              <span className="font-heading font-extrabold text-base sm:text-lg text-slate-900">
                                {pkg.isCustomEceran
                                  ? '1 Robux (Eceran)'
                                  : `${pkg.robux.toLocaleString('id-ID')} R$`}
                              </span>
                            </div>

                            <div className="mt-2 font-mono-num font-extrabold text-sm sm:text-base text-[#312E81]">
                              {pkg.priceRangeLabel
                                ? pkg.priceRangeLabel
                                : pkg.isCustomEceran
                                ? '~Rp155 / R$'
                                : formatRupiah(pkg.price)}
                            </div>

                            <div className="text-[11px] text-slate-500 mt-0.5">
                              {pkg.perRobuxLabel}
                            </div>
                          </div>

                          {pkg.note && (
                            <div className="mt-2.5 pt-2 border-t border-slate-200/60 text-[10px] text-slate-500 font-medium">
                              {pkg.note}
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>

                  {/* Special Interactive Control if 1 Robux (Eceran) is selected in 5 Hari */}
                  {selectedMethodId === '5hari' && currentPackage?.isCustomEceran && (
                    <div className="p-4 rounded-2xl bg-indigo-50/70 border border-indigo-200 space-y-3 animate-fadeIn">
                      <div className="flex flex-wrap items-center justify-between gap-2">
                        <label className="text-xs font-heading font-bold text-[#312E81]">
                          Atur Jumlah Robux Eceran (Rate Rp155 / 1 Robux):
                        </label>
                        <span className="font-mono-num text-xs font-bold text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200">
                          Total: {formatRupiah(activeTotalPrice)}
                        </span>
                      </div>

                      <div className="flex flex-wrap items-center gap-2">
                        <div className="relative flex-1 min-w-[160px]">
                          <input
                            type="number"
                            min={1}
                            max={10000}
                            value={customEceranRobux || ''}
                            onChange={(e) =>
                              setCustomEceranRobux(
                                Math.max(1, parseInt(e.target.value, 10) || 1)
                              )
                            }
                            className="w-full px-3.5 py-2 rounded-xl border border-indigo-300 bg-white font-mono-num font-bold text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                          />
                          <span className="absolute right-3.5 top-2.5 text-xs font-bold text-slate-400">
                            Robux
                          </span>
                        </div>

                        {[10, 25, 50, 150, 250, 350].map((val) => (
                          <button
                            key={val}
                            type="button"
                            onClick={() => setCustomEceranRobux(val)}
                            className={`px-3 py-2 rounded-xl text-xs font-mono-num font-bold border transition cursor-pointer ${
                              customEceranRobux === val
                                ? 'bg-[#312E81] text-white border-[#312E81]'
                                : 'bg-white text-slate-700 border-slate-200 hover:border-indigo-300'
                            }`}
                          >
                            {val} R$
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Special Option if 500 Robux Via Login is selected (Rp77.500 - Rp81.000) */}
                  {selectedMethodId === 'login' && currentPackage?.id === 'login-500' && (
                    <div className="p-4 rounded-2xl bg-indigo-50/70 border border-indigo-200 space-y-2.5 animate-fadeIn">
                      <span className="text-xs font-heading font-bold text-[#312E81] block">
                        Pilih Opsi Paket 500 Robux Via Login (Rp77.500 – Rp81.000):
                      </span>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                        <button
                          type="button"
                          onClick={() => setLogin500Option('reguler')}
                          className={`p-3 rounded-xl border text-left transition cursor-pointer ${
                            login500Option === 'reguler'
                              ? 'bg-white border-2 border-[#312E81] shadow-2xs'
                              : 'bg-white/60 border-slate-200'
                          }`}
                        >
                          <div className="flex justify-between items-center">
                            <span className="text-xs font-bold text-slate-900">
                              Reguler 500 R$
                            </span>
                            <span className="font-mono-num font-extrabold text-sm text-[#312E81]">
                              Rp77.500
                            </span>
                          </div>
                          <p className="text-[11px] text-slate-500 mt-0.5">
                            Diproses sesuai urutan antrean normal (10–25 menit)
                          </p>
                        </button>

                        <button
                          type="button"
                          onClick={() => setLogin500Option('prioritas')}
                          className={`p-3 rounded-xl border text-left transition cursor-pointer ${
                            login500Option === 'prioritas'
                              ? 'bg-white border-2 border-[#312E81] shadow-2xs'
                              : 'bg-white/60 border-slate-200'
                          }`}
                        >
                          <div className="flex justify-between items-center">
                            <span className="text-xs font-bold text-slate-900">
                              Prioritas Express 500 R$
                            </span>
                            <span className="font-mono-num font-extrabold text-sm text-[#312E81]">
                              Rp81.000
                            </span>
                          </div>
                          <p className="text-[11px] text-slate-500 mt-0.5">
                            Antrean prioritas langsung dikerjakan pertama
                          </p>
                        </button>
                      </div>
                    </div>
                  )}

                  {/* Automatic Gamepass Tax Calculator Bar for Robux 5 Hari */}
                  {selectedMethodId === '5hari' && (
                    <div className="p-4 rounded-2xl bg-gradient-to-r from-[#312E81]/5 via-sky-50 to-emerald-50/70 border border-sky-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                      <div className="space-y-0.5">
                        <div className="flex items-center gap-1.5 text-xs font-bold text-[#312E81]">
                          <Calculator className="w-4 h-4 text-[#0284C7]" />
                          <span>Kalkulator Gamepass Otomatis (Pajak 30% Roblox):</span>
                        </div>
                        <p className="text-xs text-slate-600">
                          Agar kamu menerima bersih{' '}
                          <strong className="text-slate-900">
                            {activeRobuxAmount.toLocaleString('id-ID')} R$
                          </strong>
                          , silakan atur harga Gamepass kamu sebesar:
                        </p>
                      </div>

                      <div className="flex items-center gap-3 self-start sm:self-center shrink-0">
                        <div className="px-3.5 py-2 rounded-xl bg-white border-2 border-[#312E81] text-center">
                          <span className="text-[10px] text-slate-500 block uppercase font-bold">
                            Set Harga Gamepass
                          </span>
                          <span className="font-mono-num font-extrabold text-base sm:text-lg text-[#312E81]">
                            {gamepassCalc.gamepassPrice.toLocaleString('id-ID')} R$
                          </span>
                        </div>
                        <button
                          type="button"
                          onClick={() => setIsGuideModalOpen(true)}
                          className="p-2.5 rounded-xl bg-white hover:bg-sky-50 text-[#0284C7] border border-sky-200 transition cursor-pointer"
                          title="Lihat cara buat Gamepass"
                        >
                          <HelpCircle className="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  )}
                </div>

                {/* STEP 3: DATA AKUN ROBLOX & PERSYARATAN */}
                <div className="bg-white rounded-2xl border border-slate-200/90 p-5 sm:p-6 shadow-xs space-y-4">
                  <div className="flex items-center gap-2.5">
                    <span className="w-7 h-7 rounded-xl bg-[#312E81] text-white font-heading font-extrabold text-xs flex items-center justify-center">
                      3
                    </span>
                    <div>
                      <h2 className="font-heading font-bold text-base sm:text-lg text-slate-900">
                        Masukkan Data Akun Roblox
                      </h2>
                      <p className="text-xs text-slate-500">
                        Pastikan Username diketik dengan benar (bukan Display Name / nama panggilan)
                      </p>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {/* Username Input */}
                    <div className="sm:col-span-1">
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
                            if (formError) setFormError('');
                          }}
                          placeholder="Contoh: lvysky_player01"
                          className="w-full pl-9 pr-3.5 py-2.5 rounded-xl border border-slate-300 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                        />
                      </div>
                    </div>

                    {/* Buyer WhatsApp Optional */}
                    <div className="sm:col-span-1">
                      <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                        Nomor WhatsApp Kamu (Opsional)
                      </label>
                      <input
                        type="tel"
                        value={buyerWhatsapp}
                        onChange={(e) => setBuyerWhatsapp(e.target.value)}
                        placeholder="Contoh: 0812xxxxxxx"
                        className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                      />
                    </div>
                  </div>

                  {/* Conditional Fields per Method */}
                  {selectedMethodId === '5hari' && (
                    <div className="space-y-3 pt-1">
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                          Link Gamepass atau Nama Map/Place (Opsional — Bisa dikirim menyusul di WA)
                        </label>
                        <input
                          type="text"
                          value={gamepassLinkOrMap}
                          onChange={(e) => setGamepassLinkOrMap(e.target.value)}
                          placeholder="Contoh: Map default / Link pass roblox.com/game-pass/..."
                          className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                        />
                      </div>

                      <label className="flex items-start gap-2.5 p-3.5 rounded-xl bg-emerald-50/70 border border-emerald-200 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={confirmGamepassReady}
                          onChange={(e) => setConfirmGamepassReady(e.target.checked)}
                          className="mt-0.5 w-4 h-4 accent-[#312E81] rounded"
                        />
                        <span className="text-xs text-slate-700 leading-relaxed">
                          Saya mengerti metode <strong>Robux 5 Hari (Gamepass)</strong> membutuhkan pembuatan Gamepass seharga{' '}
                          <strong className="text-[#312E81]">
                            {gamepassCalc.gamepassPrice.toLocaleString('id-ID')} R$
                          </strong>{' '}
                          (Regional Pricing OFF) dan saldo masuk setelah 5 hari kerja.
                        </span>
                      </label>
                    </div>
                  )}

                  {selectedMethodId === 'username' && (
                    <div className="space-y-3 pt-1">
                      <label className="flex items-start gap-2.5 p-3.5 rounded-xl bg-sky-50/80 border border-sky-200 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={confirmAge18And2FA}
                          onChange={(e) => setConfirmAge18And2FA(e.target.checked)}
                          className="mt-0.5 w-4 h-4 accent-[#312E81] rounded"
                        />
                        <div className="text-xs text-slate-700 leading-relaxed">
                          <span className="font-bold text-[#0284C7] block">
                            Konfirmasi Syarat Wajib Via Username (Instan 5–10 Menit):
                          </span>
                          Akun Roblox saya <strong>sudah berusia 18+</strong> dan fitur{' '}
                          <strong>Verifikasi 2 Langkah (2FA) sudah Aktif</strong>. (Tanpa password sama sekali).
                        </div>
                      </label>
                    </div>
                  )}

                  {selectedMethodId === 'login' && (
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                          Password / Catatan Login (Bisa dikirim langsung di WA)
                        </label>
                        <div className="relative">
                          <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                          <input
                            type="text"
                            value={loginPasswordOrNote}
                            onChange={(e) => setLoginPasswordOrNote(e.target.value)}
                            placeholder="Kosongkan jika ingin kirim di chat WA"
                            className="w-full pl-9 pr-3.5 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                          Kode Backup 2FA (Opsional 9 Digit)
                        </label>
                        <input
                          type="text"
                          value={backupCode2FA}
                          onChange={(e) => setBackupCode2FA(e.target.value)}
                          placeholder="Contoh: kode backup / standby kirim OTP"
                          className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-[#312E81]"
                        />
                      </div>
                    </div>
                  )}
                </div>

                {/* STEP 4: PILIH METODE PEMBAYARAN */}
                <div className="bg-white rounded-2xl border border-slate-200/90 p-5 sm:p-6 shadow-xs space-y-4">
                  <div className="flex items-center gap-2.5">
                    <span className="w-7 h-7 rounded-xl bg-[#312E81] text-white font-heading font-extrabold text-xs flex items-center justify-center">
                      4
                    </span>
                    <div>
                      <h2 className="font-heading font-bold text-base sm:text-lg text-slate-900">
                        Pilih Metode Pembayaran
                      </h2>
                      <p className="text-xs text-slate-500">
                        QRIS & nomor rekening/e-wallet resmi akan dikirimkan Admin saat terhubung di WhatsApp
                      </p>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                    {PAYMENT_METHODS.map((pm) => {
                      const active = selectedPaymentId === pm.id;
                      return (
                        <button
                          key={pm.id}
                          type="button"
                          onClick={() => setSelectedPaymentId(pm.id)}
                          className={`p-3 rounded-xl border text-left transition cursor-pointer flex flex-col justify-between ${
                            active
                              ? 'bg-sky-50/90 border-2 border-[#312E81] shadow-2xs'
                              : 'bg-slate-50/60 border-slate-200 hover:bg-white hover:border-sky-300'
                          }`}
                        >
                          <div className="flex items-center justify-between gap-1">
                            <span className="text-[10px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded bg-white text-slate-500 border border-slate-200/80">
                              {pm.category}
                            </span>
                            {active && <CheckCircle2 className="w-3.5 h-3.5 text-[#312E81]" />}
                          </div>
                          <div className="mt-2">
                            <div className="font-heading font-bold text-xs sm:text-sm text-slate-900">
                              {pm.name}
                            </div>
                            <div className="text-[10px] text-emerald-700 font-medium mt-0.5">
                              {pm.feeText}
                            </div>
                          </div>
                        </button>
                      );
                    })}
                  </div>
                </div>
              </div>

              {/* Right Column: Sticky Order Summary & Direct WhatsApp Checkout */}
              <div className="lg:col-span-4 lg:sticky lg:top-24 space-y-4">
                <form
                  onSubmit={handleRobuxOrderSubmit}
                  className="bg-white rounded-2xl border border-slate-200 p-5 sm:p-6 shadow-sm space-y-4"
                >
                  {/* Header */}
                  <div className="flex items-center justify-between pb-3.5 border-b border-slate-100">
                    <div>
                      <span className="text-[11px] font-bold uppercase tracking-wider text-[#0284C7]">
                        Ringkasan Order
                      </span>
                      <h3 className="font-heading font-extrabold text-lg text-slate-900">
                        Lvysky Store Checkout
                      </h3>
                    </div>
                    <RobuxIcon className="w-8 h-8" variant="indigo" />
                  </div>

                  {/* Selected Package Details */}
                  <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 space-y-2.5 text-xs">
                    <div className="flex justify-between items-center">
                      <span className="text-slate-500">Metode:</span>
                      <span className="font-bold text-[#312E81] text-right">
                        {currentMethod.shortTitle}
                      </span>
                    </div>

                    <div className="flex justify-between items-center">
                      <span className="text-slate-500">Jumlah Robux:</span>
                      <span className="font-mono-num font-extrabold text-sm text-slate-900">
                        {activeRobuxAmount.toLocaleString('id-ID')} R$
                      </span>
                    </div>

                    {selectedMethodId === '5hari' && (
                      <div className="flex justify-between items-center text-emerald-800 bg-emerald-50 px-2.5 py-1.5 rounded-lg border border-emerald-200/70">
                        <span>Wajib Set Gamepass:</span>
                        <span className="font-mono-num font-bold">
                          {gamepassCalc.gamepassPrice.toLocaleString('id-ID')} R$
                        </span>
                      </div>
                    )}

                    <div className="flex justify-between items-center">
                      <span className="text-slate-500">Username Roblox:</span>
                      <span className="font-mono-num font-semibold text-slate-800">
                        {robloxUsername.trim() ? robloxUsername.trim() : 'Belum diisi'}
                      </span>
                    </div>

                    <div className="flex justify-between items-center">
                      <span className="text-slate-500">Pembayaran:</span>
                      <span className="font-semibold text-slate-800 flex items-center gap-1">
                        <CreditCard className="w-3.5 h-3.5 text-[#0284C7]" />
                        {selectedPayment.name}
                      </span>
                    </div>

                    <div className="pt-2.5 border-t border-slate-200 flex justify-between items-baseline">
                      <span className="font-bold text-slate-700 text-xs">Total Bayar:</span>
                      <span className="font-mono-num font-extrabold text-xl sm:text-2xl text-[#312E81]">
                        {formatRupiah(activeTotalPrice)}
                      </span>
                    </div>
                  </div>

                  {/* Live Operational Status Notice inside Checkout */}
                  <div
                    className={`p-3 rounded-xl border text-[11px] flex items-center gap-2.5 ${
                      operationalStatus.isOnline
                        ? 'bg-emerald-50/70 border-emerald-200 text-emerald-900'
                        : 'bg-amber-50/70 border-amber-200 text-amber-900'
                    }`}
                  >
                    <span
                      className={`w-2 h-2 rounded-full shrink-0 ${
                        operationalStatus.isOnline ? 'bg-emerald-500' : 'bg-amber-500'
                      }`}
                    />
                    <span>
                      {operationalStatus.isOnline
                        ? `Admin Online (${operationalStatus.timeStringWIB}) • Pesanan langsung diproses di WhatsApp!`
                        : `Jam ${operationalStatus.timeStringWIB} • Admin buka jam 07.00–23.00 WIB (Order sekarang masuk antrean pagi).`}
                    </span>
                  </div>

                  {formError && (
                    <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2 font-medium">
                      <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                      <span>{formError}</span>
                    </div>
                  )}

                  {/* Submit to WhatsApp Button */}
                  <button
                    type="submit"
                    className="w-full py-3.5 px-5 rounded-xl bg-gradient-to-r from-[#312E81] via-[#3730A3] to-[#0284C7] hover:from-[#26236B] hover:to-[#0369A1] text-white font-heading font-bold text-sm shadow-lg shadow-indigo-900/15 flex items-center justify-center gap-2 transition cursor-pointer"
                  >
                    <MessageCircle className="w-5 h-5" />
                    <span>Beli Sekarang via WhatsApp</span>
                    <ExternalLink className="w-3.5 h-3.5 opacity-80" />
                  </button>

                  <p className="text-[11px] text-slate-500 text-center leading-relaxed">
                    Setelah klik tombol di atas, kamu langsung diarahkan ke chat WhatsApp Admin <strong>Lvysky Store</strong> dengan format order yang sudah terisi rapi.
                  </p>
                </form>

                {/* Natural Buyer Reviews Widget */}
                <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="font-heading font-bold text-xs sm:text-sm text-slate-900 flex items-center gap-1.5">
                      <Star className="w-4 h-4 text-amber-400 fill-amber-400" />
                      <span>Ulasan Pembeli Terakhir</span>
                    </span>
                    <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full">
                      100% Amanah
                    </span>
                  </div>

                  <div className="space-y-2.5">
                    {BUYER_TESTIMONIALS.map((item) => (
                      <div
                        key={item.id}
                        className="p-3 rounded-xl bg-slate-50/80 border border-slate-200/70 text-xs space-y-1"
                      >
                        <div className="flex items-center justify-between">
                          <span className="font-mono-num font-bold text-slate-800">
                            {item.user}
                          </span>
                          <span className="text-[10px] text-slate-400">{item.timeAgo}</span>
                        </div>
                        <span className="inline-block text-[10px] font-semibold text-[#0284C7] bg-sky-50 px-2 py-0.2 rounded">
                          {item.method}
                        </span>
                        <p className="text-slate-600 text-[11px] leading-relaxed pt-0.5">
                          &ldquo;{item.comment}&rdquo;
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </section>
          </>
        )}

        {activeTab === 'item' && (
          <MenuItemSection onOrderItem={handleOrderItem} />
        )}

        {activeTab === 'account' && (
          <MenuAccountSection
            onOrderAccount={handleOrderAccount}
            savedOrders={savedOrders}
            onClearOrders={handleClearOrders}
            adminWaNumber={adminWaNumber}
            onUpdateAdminWa={handleUpdateAdminWa}
          />
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-slate-200/90 mt-12">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8 sm:py-10">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-8 pb-8 border-b border-slate-100">
            <div className="md:col-span-5 space-y-3">
              <LvyskyLogo size="md" />
              <p className="text-xs sm:text-sm text-slate-600 leading-relaxed max-w-sm">
                Tempat Top Up Robux 5 Hari (Gamepass), Robux Via Username Instan tanpa password, Robux Via Login, serta Item & Akun Roblox dengan pelayanan ramah langsung via WhatsApp.
              </p>
              <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-100 text-xs font-semibold text-slate-700">
                <Clock className="w-3.5 h-3.5 text-[#312E81]" />
                <span>Jam Operasional: Setiap Hari 07.00 – 23.00 WIB</span>
              </div>
            </div>

            <div className="md:col-span-4 space-y-2.5 text-xs">
              <h4 className="font-heading font-bold text-slate-900 text-sm">
                Layanan Utama Lvysky Store
              </h4>
              <ul className="space-y-2 text-slate-600">
                <li>
                  <button
                    type="button"
                    onClick={() => {
                      setActiveTab('robux');
                      handleSelectMethod('5hari');
                    }}
                    className="hover:text-[#312E81] transition cursor-pointer"
                  >
                    • Robux 5 Hari (5H / Gamepass) — Mulai Rp130/R$
                  </button>
                </li>
                <li>
                  <button
                    type="button"
                    onClick={() => {
                      setActiveTab('robux');
                      handleSelectMethod('username');
                    }}
                    className="hover:text-[#312E81] transition cursor-pointer"
                  >
                    • Robux Via Username Instan (5–10 Menit Tanpa Password)
                  </button>
                </li>
                <li>
                  <button
                    type="button"
                    onClick={() => {
                      setActiveTab('robux');
                      handleSelectMethod('login');
                    }}
                    className="hover:text-[#312E81] transition cursor-pointer"
                  >
                    • Robux Via Login (80 R$ s/d 1.000 R$ Langsung Cair)
                  </button>
                </li>
                <li>
                  <button
                    type="button"
                    onClick={() => setActiveTab('item')}
                    className="hover:text-[#312E81] transition cursor-pointer"
                  >
                    • Menu Item & Gamepass In-Game (Gift Tanpa Login)
                  </button>
                </li>
                <li>
                  <button
                    type="button"
                    onClick={() => setActiveTab('account')}
                    className="hover:text-[#312E81] transition cursor-pointer"
                  >
                    • Menu Akun Roblox Sultan & Riwayat Pesanan
                  </button>
                </li>
              </ul>
            </div>

            <div className="md:col-span-3 space-y-3 text-xs">
              <h4 className="font-heading font-bold text-slate-900 text-sm">
                Butuh Bantuan Admin?
              </h4>
              <p className="text-slate-600 leading-relaxed">
                Bingung cara setting Gamepass atau mau tanya stok sebelum order? Chat langsung Admin kami:
              </p>
              <a
                href={buildWhatsAppUrl(
                  adminWaNumber,
                  'Halo kak Admin Lvysky Store! Saya mau tanya-tanya dulu seputar top up Robux / Item.'
                )}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#25D366] hover:bg-[#1EBE5D] text-white font-heading font-bold text-xs shadow-sm transition"
              >
                <MessageCircle className="w-4 h-4" />
                <span>Chat WhatsApp Admin</span>
              </a>
            </div>
          </div>

          <div className="pt-6 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-slate-400">
            <p>© {new Date().getFullYear()} Lvysky Store — Top Up Robux. All rights reserved.</p>
            <p>Lvysky Store adalah layanan independen dan tidak berafiliasi langsung dengan Roblox Corporation.</p>
          </div>
        </div>
      </footer>

      {/* Gamepass Guide & Tax Calculator Modal */}
      <GamepassGuideModal
        isOpen={isGuideModalOpen}
        onClose={() => setIsGuideModalOpen(false)}
        initialRobux={activeRobuxAmount}
        onApplyRobux={(robuxVal) => {
          setSelectedMethodId('5hari');
          const matchingPreset = ROBUX_PACKAGES.find(
            (p) => p.methodId === '5hari' && !p.isCustomEceran && p.robux === robuxVal
          );
          if (matchingPreset) {
            setSelectedPackageId(matchingPreset.id);
          } else {
            setSelectedPackageId('5h-eceran');
            setCustomEceranRobux(robuxVal);
          }
        }}
      />

      {/* WhatsApp Order Confirmation & Redirect Modal */}
      <WhatsAppOrderModal
        isOpen={waModalData.isOpen}
        onClose={() => setWaModalData((prev) => ({ ...prev, isOpen: false }))}
        invoiceId={waModalData.invoiceId}
        orderTitle={waModalData.orderTitle}
        methodName={waModalData.methodName}
        targetAccount={waModalData.targetAccount}
        paymentMethodName={waModalData.paymentMethodName}
        totalPrice={waModalData.totalPrice}
        whatsappMessage={waModalData.whatsappMessage}
        whatsappUrl={waModalData.whatsappUrl}
        operationalStatus={operationalStatus}
      />
    </div>
  );
}
export default App;
