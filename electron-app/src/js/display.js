/* ═══════════════════════════════════════════════════
   BISL Display — Display Controller  (BIG SCREEN)
   ═══════════════════════════════════════════════════ */
'use strict';

// ─── Constants ────────────────────────────────────────────────────────────────
const SCHOOL_NAME  = 'The British International School of Lubumbashi';
const SCHOOL_SHORT = 'BIS Lubumbashi';
const SCHOOL_MOTTO = 'Aiming for Excellence';
const WEBSITE      = 'www.britishinternationalschool.org';

// Per-slide animation classes (cycled via CSS var — includes new glitch & warp)
const SLIDE_ANIMS = ['sl-zoom','sl-left','sl-rise','sl-glitch','sl-burst','sl-warp','sl-right','sl-rise','sl-zoom','sl-glitch','sl-burst','sl-warp'];

// Vivid gradient palettes per slide
const GRADIENTS = [
  ['#0A0020','#2D1B69','#6C63FF'],
  ['#00091A','#003366','#0077CC'],
  ['#0A001A','#3A0068','#8E24AA'],
  ['#001A0D','#004D2B','#00C853'],
  ['#1A0A00','#BF360C','#FF8F00'],
  ['#000520','#1A237E','#304FFE'],
  ['#1A002B','#880E4F','#FF2E93'],
  ['#000A12','#01579B','#00E5FF'],
  ['#0D0D0D','#1B1B2F','#6C63FF'],
  ['#080020','#1B0040','#7C4DFF'],
  ['#001018','#004D40','#1DE9B6'],
  ['#100008','#4A0028','#FF2E93'],
];

// ─── State ────────────────────────────────────────────────────────────────────
let state = {
  now: new Date(),
  upcomingEvents: [], todayEvents: [], periods: [],
  slides: [], currentSlide: 0,
  slideSeconds: 12,
  musicEnabled: true,
};

let _clockInterval = null;
let _slideInterval = null;
let _lastDay       = -1;
let _tickerBuilt   = false;

// ─── DOM refs ─────────────────────────────────────────────────────────────────
const $timeStr     = document.getElementById('time-str');
const $secStr      = document.getElementById('sec-str');
const $dateStr     = document.getElementById('date-str');
const $viewport    = document.getElementById('slide-viewport');
const $navDots     = document.getElementById('nav-dots');
const $settingsBtn = document.getElementById('settings-btn');
const $bgMusic     = document.getElementById('bg-music');
const $app         = document.getElementById('app');

// ─── Utilities ────────────────────────────────────────────────────────────────
const pad = (n) => String(n).padStart(2, '0');
const esc = (s) => { const d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; };

function formatDate(d) {
  const days   = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  const months = ['January','February','March','April','May','June',
                  'July','August','September','October','November','December'];
  return days[d.getDay()] + ', ' + d.getDate() + ' ' + months[d.getMonth()] + ' ' + d.getFullYear();
}
function formatShortDate(isoStr) {
  const d = new Date(isoStr);
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return d.getDate() + ' ' + m[d.getMonth()] + ' ' + d.getFullYear();
}

// Countdown to event's start time on its date
function countdownToEvent(isoStr, timeStr) {
  const date = new Date(isoStr);
  const parts = (timeStr || '08:00').split(':');
  const hour = parseInt(parts[0], 10) || 8;
  const min  = parseInt(parts[1], 10) || 0;
  const target = new Date(date.getFullYear(), date.getMonth(), date.getDate(), hour, min, 0, 0);
  const ms = target - Date.now();
  if (ms <= 0) return { d: 0, h: 0, m: 0, s: 0 };
  return {
    d: Math.floor(ms / 86400000),
    h: Math.floor((ms % 86400000) / 3600000),
    m: Math.floor((ms % 3600000) / 60000),
    s: Math.floor((ms % 60000) / 1000),
  };
}

// ─── Particle System (enhanced — vivid, many colours) ────────────────────────
(function initParticles() {
  const canvas = document.getElementById('particle-canvas');
  const ctx    = canvas.getContext('2d');
  const COLORS = ['rgba(108,99,255,','rgba(0,229,255,','rgba(255,46,147,',
                  'rgba(255,214,0,','rgba(0,230,118,','rgba(179,136,255,',
                  'rgba(255,138,101,','rgba(64,196,255,'];
  let pts = [];

  function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
  function createPts() {
    pts = [];
    const count = Math.min(120, Math.max(80, Math.round(canvas.width * canvas.height / 16000)));
    for (let i = 0; i < count; i++) pts.push({
      x: Math.random() * canvas.width, y: Math.random() * canvas.height,
      r: Math.random() * 4.5 + 0.8,
      vx: (Math.random() - 0.5) * 0.5, vy: (Math.random() - 0.5) * 0.5,
      a: Math.random(), da: (Math.random() * 0.012 + 0.004) * (Math.random() < .5 ? 1 : -1),
      col: COLORS[Math.floor(Math.random() * COLORS.length)],
    });
  }
  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    for (const p of pts) {
      p.x += p.vx; p.y += p.vy; p.a += p.da;
      if (p.a > 1 || p.a < 0) p.da *= -1;
      if (p.x < 0) p.x = canvas.width; if (p.x > canvas.width) p.x = 0;
      if (p.y < 0) p.y = canvas.height; if (p.y > canvas.height) p.y = 0;
      ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = p.col + (p.a * 0.9).toFixed(2) + ')'; ctx.fill();
    }
    for (let i = 0; i < pts.length; i++) {
      for (let j = i + 1; j < pts.length; j++) {
        const dx = pts[i].x - pts[j].x, dy = pts[i].y - pts[j].y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 200) {
          ctx.beginPath(); ctx.moveTo(pts[i].x, pts[i].y); ctx.lineTo(pts[j].x, pts[j].y);
          ctx.strokeStyle = 'rgba(255,255,255,' + (0.12 * (1 - dist / 200)).toFixed(3) + ')';
          ctx.lineWidth = 0.9; ctx.stroke();
        }
      }
    }
    requestAnimationFrame(draw);
  }
  resize(); createPts(); draw();
  window.addEventListener('resize', function() { resize(); createPts(); });
})();

// ─── Clock master update (HEADER ONLY — no slide re-render) ───────────────────
function updateClock() {
  state.now = new Date();
  const h = pad(state.now.getHours()), m = pad(state.now.getMinutes()), s = pad(state.now.getSeconds());
  $timeStr.textContent = h + ':' + m;
  $secStr.textContent  = ':' + s;
  $dateStr.textContent = formatDate(state.now);

  if (state.now.getDate() !== _lastDay) {
    _lastDay = state.now.getDate();
    refreshTodayData();
  }

  // Live-patch clock slide elements (avoids full re-render blink)
  if (state.slides[state.currentSlide] === 'clock') {
    const hhmmEl = document.querySelector('.clock-hhmm');
    const ssEl   = document.querySelector('.clock-ss');
    const dateEl = document.querySelector('.clock-date');
    if (hhmmEl) hhmmEl.textContent = h + ':' + m;
    if (ssEl)   ssEl.textContent   = ':' + s;
    if (dateEl) dateEl.textContent = formatDate(state.now);
    const pi = getPeriodInfo();
    const periodEl = document.querySelector('.period-badge');
    if (periodEl && pi.label) {
      const sp = periodEl.querySelector('span:last-child');
      if (sp) sp.textContent = pi.label;
      const pf = document.querySelector('.period-progress-fill');
      if (pf && pi.progress !== null) pf.style.width = (pi.progress * 100).toFixed(1) + '%';
    }
  }

  // Live-patch countdown (nextEvent slide) — counts to event's start time
  if (state.slides[state.currentSlide] === 'nextEvent') {
    const ev = state.upcomingEvents[0];
    if (ev) {
      const cd = countdownToEvent(ev.event_date, ev.event_time);
      const nums = document.querySelectorAll('.countdown-num');
      if (nums.length >= 4) {
        nums[0].textContent = cd.d;
        nums[1].textContent = pad(cd.h);
        nums[2].textContent = pad(cd.m);
        nums[3].textContent = pad(cd.s);
      }
    }
  }
}

// ─── Period info ──────────────────────────────────────────────────────────────
function getPeriodInfo() {
  const now = state.now;
  const nowMin = now.getHours() * 60 + now.getMinutes();
  const prds = state.periods;
  if (!prds.length) return { label: '', color: '#FFD600', icon: '🌅', progress: null };

  for (const p of prds) {
    const s = p.start_hour * 60 + p.start_minute;
    const e = p.end_hour   * 60 + p.end_minute;
    if (nowMin >= s && nowMin < e) {
      const prog = (nowMin - s + now.getSeconds() / 60) / (e - s);
      const rs = (e * 60) - (now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds());
      return { label: p.name + ' \u2022 ' + pad(Math.floor(rs/60)) + ':' + pad(rs%60) + ' remaining', color: '#00E5FF', icon: '📚', progress: Math.min(1, prog) };
    }
  }
  const firstStart = prds[0].start_hour * 60 + prds[0].start_minute;
  const lastEnd    = prds[prds.length - 1].end_hour * 60 + prds[prds.length - 1].end_minute;
  if (nowMin < firstStart) return { label: 'School starts at ' + pad(prds[0].start_hour) + ':' + pad(prds[0].start_minute), color: '#FFD600', icon: '🌅', progress: null };
  if (nowMin >= lastEnd) return { label: 'End of School Day', color: '#FF6B6B', icon: '🌙', progress: null };
  for (let i = 0; i < prds.length - 1; i++) {
    const ej = prds[i].end_hour * 60 + prds[i].end_minute;
    const ns = prds[i+1].start_hour * 60 + prds[i+1].start_minute;
    if (nowMin >= ej && nowMin < ns) return { label: 'Break \u2022 ' + prds[i+1].name + ' in ' + (ns - nowMin) + ' min', color: '#00E676', icon: '\u2615', progress: null };
  }
  return { label: '', color: '#FFD600', icon: '📅', progress: null };
}

// ─── Gradient ─────────────────────────────────────────────────────────────────
function applyGradient(slideIdx) {
  const g = GRADIENTS[slideIdx % GRADIENTS.length];
  $app.style.background = 'linear-gradient(135deg,' + g[0] + ' 0%,' + g[1] + ' 50%,' + g[2] + ' 100%)';
}

// ─── Slide management ─────────────────────────────────────────────────────────
function buildActiveSlides() {
  const s = ['welcome', 'clock', 'vision', 'stats', 'admissions', 'highlights', 'achievements', 'pride', 'contact'];
  if (state.upcomingEvents.length > 0) s.push('nextEvent');
  if (state.upcomingEvents.length > 1) s.push('upcomingEvents');
  state.slides = s;
}

function renderNavDots() {
  $navDots.innerHTML = '';
  for (let i = 0; i < state.slides.length; i++) {
    const dot = document.createElement('div');
    dot.className = 'dot' + (i === state.currentSlide ? ' active' : '');
    $navDots.appendChild(dot);
  }
}

function renderCurrentSlide() {
  const type = state.slides[state.currentSlide] || 'clock';
  applyGradient(state.currentSlide);

  // Pick animation class (varies per slide so each transition looks different)
  const animClass = SLIDE_ANIMS[state.currentSlide % SLIDE_ANIMS.length];

  let html = '';
  switch (type) {
    case 'welcome':        html = buildWelcomeSlide(animClass);       break;
    case 'clock':          html = buildClockSlide(animClass);         break;
    case 'stats':          html = buildStatsSlide(animClass);         break;
    case 'admissions':     html = buildAdmissionsSlide(animClass);    break;
    case 'highlights':     html = buildHighlightsSlide(animClass);    break;
    case 'achievements':   html = buildAchievementsSlide(animClass);  break;
    case 'vision':         html = buildVisionSlide(animClass);        break;
    case 'pride':          html = buildPrideSlide(animClass);         break;
    case 'contact':        html = buildContactSlide(animClass);       break;
    case 'nextEvent':      html = buildNextEventSlide(animClass);     break;
    case 'upcomingEvents': html = buildUpcomingSlide(animClass);      break;
    default:               html = buildClockSlide(animClass);
  }

  $viewport.innerHTML = html;
  renderNavDots();
  if (type === 'stats') animateCounters();
}

// ══════════════════════════════════════════════════
//   WELCOME / HERO SLIDE
// ══════════════════════════════════════════════════
function buildWelcomeSlide(ac) {
  return '<div class="welcome-slide ' + ac + '">' +
    '<img class="welcome-logo" src="../../assets/images/BIS Logo.png" alt="BIS Logo" onerror="this.style.display=\'none\'" />' +
    '<div class="welcome-school">' + esc(SCHOOL_NAME.toUpperCase()) + '</div>' +
    '<div class="welcome-tagline">\u201C' + esc(SCHOOL_MOTTO) + '\u201D</div>' +
    '<div class="welcome-established">EST. 2020 \u2022 LUBUMBASHI, DRC</div>' +
  '</div>';
}

// ══════════════════════════════════════════════════
//   CLOCK SLIDE
// ══════════════════════════════════════════════════
function buildClockSlide(ac) {
  const now  = state.now;
  const hhmm = pad(now.getHours()) + ':' + pad(now.getMinutes());
  const ss   = pad(now.getSeconds());
  const date = formatDate(now);
  const pi   = getPeriodInfo();

  let progressBar = '';
  if (pi.progress !== null) {
    const pColor = pi.progress < 0.7 ? 'var(--emerald)' : pi.progress < 0.9 ? 'var(--gold)' : 'var(--coral)';
    progressBar = '<div class="period-progress" style="margin-top:8px"><div class="period-progress-fill" style="width:' + (pi.progress*100).toFixed(1) + '%;background:' + pColor + ';box-shadow:0 0 12px ' + pColor + '"></div></div>';
  }

  let todayHtml = '';
  if (state.todayEvents.length) {
    todayHtml = '<div class="events-glass"><div class="events-label">\uD83C\uDF89 TODAY\'S EVENTS</div>';
    for (const e of state.todayEvents) todayHtml += '<div class="event-item">' + esc(e.title) + '</div>';
    todayHtml += '</div>';
  }

  let upcomingHtml = '';
  for (const e of state.upcomingEvents.slice(0, 4)) {
    upcomingHtml += '<div class="upcoming-item"><div class="upcoming-title">' + esc(e.title) + '</div><div class="upcoming-date">' + formatShortDate(e.event_date) + '</div></div>';
  }

  const periodHtml = pi.label ? '<div class="period-badge" style="color:' + pi.color + ';border-color:' + pi.color + '55;background:' + pi.color + '14;margin-top:18px"><span class="period-icon">' + pi.icon + '</span><span>' + esc(pi.label) + '</span></div>' + progressBar : '';

  return '<div class="clock-slide ' + ac + '">' +
    '<div class="clock-left">' +
      '<div class="clock-school-name">' + esc(SCHOOL_SHORT.toUpperCase()) + '</div>' +
      '<div class="clock-motto">' + esc(SCHOOL_MOTTO) + '</div>' +
      '<div class="clock-time-row" style="margin-top:16px"><div class="clock-hhmm">' + esc(hhmm) + '</div><div class="clock-ss">:' + esc(ss) + '</div></div>' +
      '<div class="clock-date" style="margin-top:8px">' + esc(date) + '</div>' +
      periodHtml +
    '</div>' +
    '<div class="clock-right">' + todayHtml +
      '<div class="upcoming-glass"><div class="upcoming-label">\uD83D\uDCC5 UPCOMING EVENTS</div>' +
        (upcomingHtml || '<div style="color:var(--white50);font-size:1.3vw">No upcoming events</div>') +
      '</div>' +
    '</div>' +
  '</div>';
}

// ══════════════════════════════════════════════════
//   SCHOOL STATISTICS — 5 counters with light beams
// ══════════════════════════════════════════════════
function buildStatsSlide(ac) {
  const stats = [
    { icon: '\uD83D\uDC68\u200D\uD83C\uDF93', number: 1200, suffix: '+', label: 'STUDENTS',           color: 'var(--cyan)',     border: 'rgba(0,229,255,.55)' },
    { icon: '\uD83C\uDF0D',                   number: 50,   suffix: '+', label: 'NATIONALITIES',       color: 'var(--neon-pink)',border: 'rgba(255,46,147,.55)' },
    { icon: '\uD83C\uDFC6',                   number: 6,    suffix: '+', label: 'YEARS',               color: 'var(--gold)',     border: 'rgba(255,214,0,.55)' },
  ];

  let html = '<div class="stats-slide ' + ac + '">' +
    '<div class="slide-school-banner">BY THE NUMBERS</div>' +
    '<div class="stats-grid stats-grid-3">';
  stats.forEach(function(s, i) {
    html += '<div class="stat-card holo-shimmer" style="color:' + s.color + ';border-color:' + s.border + ';animation-delay:' + (i * 0.12) + 's">' +
      '<div class="stat-spotlight"></div>' +
      '<div class="stat-icon">' + s.icon + '</div>' +
      '<div class="stat-number" data-target="' + s.number + '" data-suffix="' + s.suffix + '">0' + s.suffix + '</div>' +
      '<div class="stat-label">' + s.label + '</div></div>';
  });
  html += '</div></div>';
  return html;
}

function animateCounters() {
  document.querySelectorAll('.stat-number[data-target]').forEach(function(el) {
    const target = parseInt(el.dataset.target);
    const suffix = el.dataset.suffix || '';
    const duration = 2400;
    const start = performance.now();
    (function tick(now) {
      const p = Math.min((now - start) / duration, 1);
      el.textContent = Math.round((1 - Math.pow(1 - p, 3)) * target) + suffix;
      if (p < 1) requestAnimationFrame(tick);
    })(start);
  });
}

// ══════════════════════════════════════════════════
//   ACHIEVEMENTS / ACCREDITATIONS
// ══════════════════════════════════════════════════
function buildAchievementsSlide(ac) {
  const accolades = [
    { icon: '\uD83C\uDFC5', color: 'rgba(255,214,0,.25)',  border: 'rgba(255,214,0,.5)',  glow: 'rgba(255,214,0,.2)',
      headline: 'COBIS & IB-DP Accredited' },
    { icon: '\uD83C\uDF93', color: 'rgba(108,99,255,.2)',  border: 'rgba(108,99,255,.5)', glow: 'rgba(108,99,255,.2)',
      headline: 'IB & British Curriculum' },
    { icon: '\uD83E\uDD16', color: 'rgba(0,229,255,.2)',   border: 'rgba(0,229,255,.5)',  glow: 'rgba(0,229,255,.2)',
      headline: 'First AI Lab in Africa' },
  ];

  let html = '<div class="achievements-slide ' + ac + '">' +
    '<div class="slide-school-banner">ACHIEVEMENTS &amp; ACCREDITATIONS</div>' +
    '<div class="accolades-grid">';
  accolades.forEach(function(a) {
    html += '<div class="accolade-card holo-shimmer" style="background:' + a.color + ';border-color:' + a.border + ';box-shadow:0 0 40px ' + a.glow + ';--glow-color:' + a.glow + '">' +
      '<div class="accolade-icon">' + a.icon + '</div>' +
      '<div class="accolade-text"><div class="accolade-headline">' + a.headline + '</div></div></div>';
  });
  html += '</div></div>';
  return html;
}

// ══════════════════════════════════════════════════
//   ADMISSIONS — marketing-focused, positive
// ══════════════════════════════════════════════════
function buildAdmissionsSlide(ac) {
  return '<div class="admissions-slide ' + ac + '">' +
    '<div class="slide-school-banner">' + esc(SCHOOL_SHORT.toUpperCase()) + '</div>' +
    '<div class="glass-card admissions-card holo-shimmer" style="border-color:rgba(255,214,0,.5);box-shadow:0 0 50px rgba(255,214,0,.22)">' +
      '<div class="admissions-sparkles">' +
        '<span class="sparkle-dot" style="top:10%;left:8%;animation-delay:0s"></span>' +
        '<span class="sparkle-dot" style="top:20%;right:10%;animation-delay:.4s"></span>' +
        '<span class="sparkle-dot" style="bottom:15%;left:15%;animation-delay:.8s"></span>' +
        '<span class="sparkle-dot" style="bottom:20%;right:8%;animation-delay:1.2s"></span>' +
        '<span class="sparkle-dot" style="top:50%;left:4%;animation-delay:1.6s"></span>' +
        '<span class="sparkle-dot" style="top:45%;right:4%;animation-delay:2s"></span>' +
      '</div>' +
      '<div class="admissions-badge" style="background:rgba(255,214,0,.15);border:3px solid rgba(255,214,0,.5);color:var(--gold)">' +
        '\uD83C\uDF93 ADMISSIONS 2026\u201327' +
      '</div>' +
      '<div class="admissions-headline" style="font-size:6vw;margin-bottom:24px">' +
        'Join Our Global Family' +
      '</div>' +
      '<div class="admissions-date-box" style="background:rgba(29,233,182,.15);border:3px solid rgba(29,233,182,.5)">' +
        '<div class="admissions-date-label" style="color:var(--teal)">Registration Opens</div>' +
        '<div class="admissions-date-value" style="color:var(--teal)">1st June 2026</div>' +
      '</div>' +
      '<div class="admissions-note" style="color:var(--coral);margin-top:22px">' +
        '\u26A0 LIMITED SEATS \u2014 SECURE YOUR PLACE!' +
      '</div>' +
    '</div></div>';
}

// ══════════════════════════════════════════════════
//   SCHOOL HIGHLIGHTS — 3×2 grid
// ══════════════════════════════════════════════════
function buildHighlightsSlide(ac) {
  const items = [
    { icon: '\uD83C\uDFDF\uFE0F', title: 'Auditorium' },
    { icon: '\uD83C\uDFCA',       title: 'Swimming Pool' },
    { icon: '\uD83D\uDD2C',       title: 'Science Labs' },
  ];
  const colors  = ['rgba(0,229,255,.25)','rgba(108,99,255,.25)','rgba(0,230,118,.25)'];
  const borders = ['rgba(0,229,255,.5)', 'rgba(108,99,255,.5)', 'rgba(0,230,118,.5)'];

  let html = '<div class="highlights-slide ' + ac + '">' +
    '<div class="slide-school-banner">WORLD-CLASS INFRASTRUCTURE</div>' +
    '<div class="highlights-grid">';
  items.forEach(function(it, i) {
    html += '<div class="highlight-item holo-shimmer" style="background:' + colors[i] + ';border-color:' + borders[i] + '">' +
      '<div class="highlight-icon">' + it.icon + '</div>' +
      '<div class="highlight-title">' + it.title + '</div></div>';
  });
  html += '</div></div>';
  return html;
}

// ══════════════════════════════════════════════════
//   NEXT EVENT — countdown to event's scheduled time
// ══════════════════════════════════════════════════
function buildNextEventSlide(ac) {
  const ev = state.upcomingEvents[0];
  if (!ev) return '';
  const evTime = ev.event_time || '08:00';
  const cd = countdownToEvent(ev.event_date, evTime);
  const accentC = 'var(--teal)';
  return '<div class="next-event-slide ' + ac + '">' +
    '<div class="slide-school-banner">NEXT EVENT</div>' +
    '<div class="glass-card next-event-card holo-shimmer" style="border-color:rgba(29,233,182,.5);box-shadow:0 0 50px rgba(29,233,182,.25)">' +
      '<div class="fact-label text-teal" style="letter-spacing:6px;margin-bottom:14px;font-size:3.5vw">COUNTDOWN</div>' +
      '<div class="next-event-title" style="font-size:6vw;margin-bottom:14px">' + esc(ev.title) + '</div>' +
      '<div style="font-family:var(--f-clock);font-size:3vw;color:var(--white70);margin-bottom:28px">\uD83D\uDCC5 ' + formatShortDate(ev.event_date) + '</div>' +
      '<div class="countdown-row">' +
        '<div class="countdown-block"><div class="countdown-num" style="color:' + accentC + '">' + cd.d + '</div><div class="countdown-label">DAYS</div></div>' +
        '<div style="font-family:var(--f-clock);font-size:4vw;color:var(--white30);align-self:center">:</div>' +
        '<div class="countdown-block"><div class="countdown-num" style="color:' + accentC + '">' + pad(cd.h) + '</div><div class="countdown-label">HRS</div></div>' +
        '<div style="font-family:var(--f-clock);font-size:4vw;color:var(--white30);align-self:center">:</div>' +
        '<div class="countdown-block"><div class="countdown-num" style="color:' + accentC + '">' + pad(cd.m) + '</div><div class="countdown-label">MIN</div></div>' +
        '<div style="font-family:var(--f-clock);font-size:4vw;color:var(--white30);align-self:center">:</div>' +
        '<div class="countdown-block"><div class="countdown-num" style="color:' + accentC + '">' + pad(cd.s) + '</div><div class="countdown-label">SEC</div></div>' +
      '</div>' +
    '</div></div>';
}

// ══════════════════════════════════════════════════
//   UPCOMING EVENTS LIST
// ══════════════════════════════════════════════════
function buildUpcomingSlide(ac) {
  const evs = state.upcomingEvents.slice(0, 3);
  let html = '<div class="upcoming-slide ' + ac + '">' +
    '<div class="slide-school-banner">UPCOMING EVENTS</div>' +
    '<div class="glass-card upcoming-list-card holo-shimmer" style="border-color:rgba(255,46,147,.4);box-shadow:0 0 40px rgba(255,46,147,.2);width:100%">';
  evs.forEach(function(e) {
    html += '<div class="upcoming-list-item"><div class="upcoming-list-dot"></div><div class="upcoming-list-title">' + esc(e.title) + '</div><div class="upcoming-list-date">' + formatShortDate(e.event_date) + '</div></div>';
  });
  html += '</div></div>';
  return html;
}

// ══════════════════════════════════════════════════
//   VISION SLIDE — bold inspirational messaging
// ══════════════════════════════════════════════════
function buildVisionSlide(ac) {
  return '<div class="vision-slide ' + ac + '">' +
    '<div class="vision-icon">\uD83C\uDF1F</div>' +
    '<div class="vision-title">OUR VISION</div>' +
    '<div class="vision-quote">\u201CShaping Tomorrow\u2019s Leaders Through World-Class Education\u201D</div>' +
    '<div class="vision-sub">COBIS \u2022 IB DIPLOMA \u2022 BRITISH CURRICULUM \u2022 AI INNOVATION</div>' +
  '</div>';
}

// ══════════════════════════════════════════════════
//   PRIDE SLIDE — core values / pillars
// ══════════════════════════════════════════════════
function buildPrideSlide(ac) {
  const values = [
    { icon: '\uD83C\uDFAF', title: 'EXCELLENCE', color: 'var(--gold)',     border: 'rgba(255,214,0,.5)' },
    { icon: '\uD83C\uDF0D', title: 'DIVERSITY',  color: 'var(--cyan)',     border: 'rgba(0,229,255,.5)' },
    { icon: '\uD83D\uDCA1', title: 'INNOVATION', color: 'var(--neon-pink)',border: 'rgba(255,46,147,.5)' },
  ];
  let html = '<div class="pride-slide ' + ac + '">' +
    '<div class="pride-title">OUR CORE VALUES</div>' +
    '<div class="pride-grid">';
  values.forEach(function(v, i) {
    html += '<div class="pride-card holo-shimmer" style="color:' + v.color + ';border-color:' + v.border + ';animation-delay:' + (i * 0.12) + 's">' +
      '<div class="pride-card-icon">' + v.icon + '</div>' +
      '<div class="pride-card-title">' + v.title + '</div></div>';
  });
  html += '</div></div>';
  return html;
}

// ══════════════════════════════════════════════════
//   CONTACT / CALL-TO-ACTION SLIDE
// ══════════════════════════════════════════════════
function buildContactSlide(ac) {
  return '<div class="contact-slide ' + ac + '">' +
    '<div class="contact-title">GET IN TOUCH</div>' +
    '<div class="contact-cta">Enrol Your Child Today</div>' +
    '<div class="contact-info">' +
      '<div class="contact-item">' +
        '<div class="contact-icon">\uD83C\uDF10</div>' +
        '<div class="contact-text" style="color:var(--cyan)">' + esc(WEBSITE) + '</div>' +
        '<div class="contact-label">WEBSITE</div>' +
      '</div>' +
      '<div class="contact-item">' +
        '<div class="contact-icon">\uD83D\uDCCD</div>' +
        '<div class="contact-text" style="color:var(--gold)">LUBUMBASHI, DRC</div>' +
        '<div class="contact-label">LOCATION</div>' +
      '</div>' +
    '</div>' +
    '<div class="contact-website">' + esc(WEBSITE) + '</div>' +
  '</div>';
}

// ══════════════════════════════════════════════════
//   NEWS TICKER (bottom bar — slower speed)
// ══════════════════════════════════════════════════
function buildTicker() {
  if (_tickerBuilt) return; _tickerBuilt = true;
  const ticker = document.getElementById('news-ticker');
  if (!ticker) return;
  const items = [
    { text: 'COBIS & IB Diploma Accredited \u2014 Only in Central Africa', color: 'var(--gold)' },
    { text: 'Admissions Open 1st June 2026 \u2014 Limited Seats!', color: 'var(--teal)' },
    { text: 'First AI Laboratory in Africa', color: 'var(--cyan)' },
    { text: '1,200+ Students \u2022 50+ Nationalities', color: 'var(--neon-pink)' },
    { text: 'World-Class Facilities & Smart Campus', color: 'var(--lavender)' },
    { text: 'IB & British Curriculum', color: 'var(--electric)' },
    { text: 'Best Results in Lubumbashi', color: 'var(--gold)' },
    { text: WEBSITE, color: 'var(--sky-blue)' },
  ];
  const allItems = items.concat(items);
  const content = document.createElement('div');
  content.className = 'ticker-content';
  content.innerHTML = allItems.map(function(i) {
    return '<span class="ticker-item" style="color:' + i.color + '"><span class="ticker-dot" style="background:' + i.color + '"></span>' + esc(i.text) + '</span>';
  }).join('');
  ticker.appendChild(content);
}

// ─── Slide Rotation ───────────────────────────────────────────────────────────
function nextSlide() {
  if (!state.slides.length) return;
  state.currentSlide = (state.currentSlide + 1) % state.slides.length;
  renderCurrentSlide();
}
function goToSlide(i) {
  state.currentSlide = ((i % state.slides.length) + state.slides.length) % state.slides.length;
  clearInterval(_slideInterval);
  _slideInterval = setInterval(nextSlide, state.slideSeconds * 1000);
  renderCurrentSlide();
}

// ─── Data loading ─────────────────────────────────────────────────────────────
async function loadAllContent() {
  [state.upcomingEvents, state.periods] = await Promise.all([
    window.api.getUpcomingSchoolEvents(),
    window.api.getPeriods(),
  ]);
  const today = new Date();
  const todayStr = today.getFullYear() + '-' + pad(today.getMonth()+1) + '-' + pad(today.getDate());
  state.todayEvents = state.upcomingEvents.filter(function(e) { return e.event_date.slice(0,10) === todayStr; });
  buildActiveSlides();
}
async function refreshTodayData() {
  state.upcomingEvents = await window.api.getUpcomingSchoolEvents();
  const today = new Date();
  const todayStr = today.getFullYear() + '-' + pad(today.getMonth()+1) + '-' + pad(today.getDate());
  state.todayEvents = state.upcomingEvents.filter(function(e) { return e.event_date.slice(0,10) === todayStr; });
  buildActiveSlides();
}

// ─── Music Playlist ───────────────────────────────────────────────────────────
let _playlist = [];
let _playIdx  = 0;
let _musicCheckInterval = null;

async function initMusic() {
  const enabled = (await window.api.getSetting('music_enabled', 'true')) === 'true';
  state.musicEnabled = enabled;
  if (!enabled) return;

  await loadPlaylist();

  // Keep checking for new music files every 30 seconds
  _musicCheckInterval = setInterval(async function() {
    if (!state.musicEnabled) return;
    await loadPlaylist();
    // If nothing is playing but we have tracks now, start playing
    if (_playlist.length && $bgMusic.paused) playTrack(_playIdx);
  }, 30000);
}

async function loadPlaylist() {
  var files = [];
  if (window.api.getMusicFiles) {
    files = await window.api.getMusicFiles();
  }
  // Fallback: if getMusicFiles not available or returns empty, try legacy single file
  if (!files || !files.length) {
    var legacyPath = await window.api.getAssetPath('music',
      'Inspiring Background Music  Cinematic Epic Music  ROYALTY FREE Music by MUSIC4VIDEO.mp3');
    if (legacyPath) {
      var uri = legacyPath.startsWith('/') ? 'file://' + legacyPath : 'file:///' + legacyPath.replace(/\\/g, '/');
      files = [uri];
    }
  }
  _playlist = files || [];
}

function playTrack(idx) {
  if (!_playlist.length) return;
  _playIdx = idx % _playlist.length;
  $bgMusic.src = _playlist[_playIdx];
  $bgMusic.volume = 0.25;
  $bgMusic.play().catch(function() {});
}

// When a track ends, play the next one (loops back to first after last)
$bgMusic.addEventListener('ended', function() {
  if (!state.musicEnabled || !_playlist.length) return;
  _playIdx = (_playIdx + 1) % _playlist.length;
  playTrack(_playIdx);
});

// ─── Controls ─────────────────────────────────────────────────────────────────
$settingsBtn.addEventListener('click', function() { window.api.openAdmin(); });
document.addEventListener('keydown', function(e) {
  if (e.key === 'ArrowRight') goToSlide(state.currentSlide + 1);
  if (e.key === 'ArrowLeft')  goToSlide(state.currentSlide - 1);
});
window.api.onReloadContent(function() { loadAllContent().then(function() { renderCurrentSlide(); }); });

// ─── Bootstrap ────────────────────────────────────────────────────────────────
async function main() {
  const s = await window.api.getSetting('slide_seconds', '12');
  state.slideSeconds = Math.max(5, Math.min(60, parseInt(s, 10) || 12));
  await loadAllContent();
  updateClock();
  _clockInterval = setInterval(updateClock, 1000);
  renderCurrentSlide();
  _slideInterval = setInterval(nextSlide, state.slideSeconds * 1000);
  buildTicker();
  await initMusic();
}

main().catch(console.error);
