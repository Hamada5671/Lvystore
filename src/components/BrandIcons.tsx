import React from 'react';

interface LogoProps {
  className?: string;
  size?: 'sm' | 'md' | 'lg';
  showTagline?: boolean;
}

export const LvyskyLogo: React.FC<LogoProps> = ({
  className = '',
  size = 'md',
  showTagline = true,
}) => {
  const dimensions = {
    sm: { box: 36, title: 'text-lg', sub: 'text-[9px] tracking-[0.22em]' },
    md: { box: 44, title: 'text-xl sm:text-2xl', sub: 'text-[10px] sm:text-[11px] tracking-[0.24em]' },
    lg: { box: 56, title: 'text-2xl sm:text-3xl', sub: 'text-xs tracking-[0.26em]' },
  }[size];

  return (
    <div className={`inline-flex items-center gap-2.5 select-none ${className}`}>
      {/* Emblem SVG matching uploaded Lvysky Store logo */}
      <svg
        width={dimensions.box}
        height={dimensions.box}
        viewBox="0 0 120 120"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="shrink-0"
      >
        {/* Sky blue sparkle rays at top-left */}
        <rect
          x="6"
          y="30"
          width="17"
          height="4.5"
          rx="2.25"
          fill="#59ADEB"
        />
        <rect
          x="42"
          y="6"
          width="4.5"
          height="17"
          rx="2.25"
          transform="rotate(14 42 6)"
          fill="#59ADEB"
        />

        {/* 4-point indigo star at top-left corner */}
        <path
          d="M31 15C31 22.2 25.2 28 18 28C25.2 28 31 33.8 31 41C31 33.8 36.8 28 44 28C36.8 28 31 22.2 31 15Z"
          fill="#33248B"
        />

        {/* Rounded squircle border with opening at top-left for the star */}
        <path
          d="M44 31H84C97.2548 31 108 41.7452 108 55V86C108 99.2548 97.2548 110 84 110H46C32.7452 110 22 99.2548 22 86V45"
          stroke="#33248B"
          strokeWidth="7.5"
          strokeLinecap="round"
        />

        {/* Stylized segmented 'L' inside the squircle */}
        {/* Vertical stem */}
        <path
          d="M44 50C44 46.134 47.134 43 51 43H53C55.2091 43 57 44.7909 57 47V75L44 85V50Z"
          fill="#33248B"
        />
        {/* Bottom horizontal foot */}
        <path
          d="M44 88.5L57 78.5V82H77C80.866 82 84 85.134 84 89V91C84 93.2091 82.2091 95 80 95H51C47.134 95 44 92.0899 44 88.5Z"
          fill="#33248B"
        />
      </svg>

      {/* Wordmark */}
      <div className="flex flex-col leading-none">
        <div className={`font-heading font-extrabold tracking-tight ${dimensions.title}`}>
          <span className="text-[#33248B]">Lv</span>
          <span className="text-[#59ADEB]">ys</span>
          <span className="text-[#33248B]">ky Store</span>
        </div>
        {showTagline && (
          <span
            className={`font-medium text-[#59ADEB] mt-1 pl-0.5 ${dimensions.sub}`}
          >
            Top Up Robux
          </span>
        )}
      </div>
    </div>
  );
};

export const RobuxIcon: React.FC<{ className?: string; variant?: 'indigo' | 'gold' | 'sky' }> = ({
  className = 'w-6 h-6',
  variant = 'indigo',
}) => {
  const colors = {
    indigo: {
      outer: '#33248B',
      inner: '#59ADEB',
      bg: '#EEF2FF',
    },
    gold: {
      outer: '#D97706',
      inner: '#F59E0B',
      bg: '#FEF3C7',
    },
    sky: {
      outer: '#0284C7',
      inner: '#38BDF8',
      bg: '#E0F2FE',
    },
  }[variant];

  return (
    <svg
      viewBox="0 0 36 36"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      {/* Outer rounded hexagon */}
      <path
        d="M16.2 2.8C17.31 2.16 18.69 2.16 19.8 2.8L30.8 9.15C31.91 9.79 32.6 10.98 32.6 12.26V23.74C32.6 25.02 31.91 26.21 30.8 26.85L19.8 33.2C18.69 33.84 17.31 33.84 16.2 33.2L5.2 26.85C4.09 26.21 3.4 25.02 3.4 23.74V12.26C3.4 10.98 4.09 9.79 5.2 9.15L16.2 2.8Z"
        fill={colors.bg}
        stroke={colors.outer}
        strokeWidth="2.4"
      />
      {/* Inner hexagon border */}
      <path
        d="M17.1 7.5C17.66 7.18 18.34 7.18 18.9 7.5L26.7 12C27.26 12.32 27.6 12.92 27.6 13.56V22.44C27.6 23.08 27.26 23.68 26.7 24L18.9 28.5C18.34 28.82 17.66 28.82 17.1 28.5L9.3 24C8.74 23.68 8.4 23.08 8.4 22.44V13.56C8.4 12.92 8.74 12.32 9.3 12L17.1 7.5Z"
        fill={colors.outer}
      />
      {/* Center cut square */}
      <rect
        x="14.2"
        y="14.2"
        width="7.6"
        height="7.6"
        rx="1.5"
        fill="white"
      />
      <rect
        x="16.1"
        y="16.1"
        width="3.8"
        height="3.8"
        rx="0.7"
        fill={colors.inner}
      />
    </svg>
  );
};
