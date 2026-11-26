import { useState, useEffect } from 'react';

export type StatusOverride = 'auto' | 'force_online' | 'force_offline';

export interface OperationalStatus {
  isOnline: boolean;
  timeStringWIB: string;
  hourWIB: number;
  minuteWIB: number;
  statusLabel: string;
  subLabel: string;
  scheduleText: string;
}

export function getOperationalStatus(override: StatusOverride = 'auto'): OperationalStatus {
  const now = new Date();

  const formatter = new Intl.DateTimeFormat('id-ID', {
    timeZone: 'Asia/Jakarta',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  });

  const parts = formatter.formatToParts(now);
  const hourStr = parts.find((p) => p.type === 'hour')?.value ?? '12';
  const minuteStr = parts.find((p) => p.type === 'minute')?.value ?? '00';

  const hourWIB = parseInt(hourStr, 10);
  const minuteWIB = parseInt(minuteStr, 10);

  // Jam operasional: 07.00 sampai 23.00 WIB
  const totalMinutes = hourWIB * 60 + minuteWIB;
  const openMinutes = 7 * 60; // 07:00
  const closeMinutes = 23 * 60; // 23:00

  let isOnline = totalMinutes >= openMinutes && totalMinutes < closeMinutes;
  if (override === 'force_online') isOnline = true;
  if (override === 'force_offline') isOnline = false;

  const timeStringWIB = `${hourStr.padStart(2, '0')}.${minuteStr.padStart(2, '0')} WIB`;

  if (isOnline) {
    return {
      isOnline: true,
      timeStringWIB,
      hourWIB,
      minuteWIB,
      statusLabel: 'Toko Buka',
      subLabel: 'Siap proses pesananmu lewat WhatsApp',
      scheduleText: '07.00 – 23.00 WIB',
    };
  }

  return {
    isOnline: false,
    timeStringWIB,
    hourWIB,
    minuteWIB,
    statusLabel: 'Toko Istirahat',
    subLabel: 'Tetap bisa order sekarang, diproses antrean pertama jam 07.00 WIB',
    scheduleText: 'Buka 07.00 – 23.00 WIB',
  };
}

export function useOperationalStatus(override: StatusOverride = 'auto') {
  const [status, setStatus] = useState<OperationalStatus>(() => getOperationalStatus(override));

  useEffect(() => {
    setStatus(getOperationalStatus(override));
    const interval = setInterval(() => {
      setStatus(getOperationalStatus(override));
    }, 10000);
    return () => clearInterval(interval);
  }, [override]);

  return status;
}
