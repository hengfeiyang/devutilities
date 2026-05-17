/* DevUtilities — editorial homepage JS */
(function () {
  'use strict';

  // ── Tool data (mirrors design's tools-data.js) ───────────────────────────
  const TOOLS = [
    { n: '01', cat: 'AI',       slug: 'ai-chat',           name: 'AI Chat',
      href: 'ai-chat.html',
      blurb: 'Markdown rendering, syntax-highlighted code, one-click copy. Works with OpenAI, DeepSeek, and any compatible model.',
      tag: 'Updated · 2.12' },
    { n: '02', cat: 'AI',       slug: 'ai-translate',      name: 'AI Translate',
      href: 'ai-translate.html',
      blurb: 'Three modes, nineteen languages, real-time TTS streaming. Word mode adds phonetics, meanings, examples, etymology.',
      tag: 'Updated · 2.12' },

    { n: '03', cat: 'Convert',  slug: 'timestamp',         name: 'Timestamp Converter',
      href: 'timestamp-converter.html',
      blurb: 'Unix ↔ human, with timezone awareness and a half-dozen format presets.', tag: 'Updated · 2.1' },
    { n: '04', cat: 'Convert',  slug: 'unit',              name: 'Unit Converter',
      href: 'unit-converter.html',
      blurb: 'Seven categories — data, time, length, weight, temperature, area, volume.', tag: '' },
    { n: '05', cat: 'Convert',  slug: 'base',              name: 'Base Converter',
      href: 'base-converter.html',
      blurb: 'Bin, oct, dec, hex, base62. Real-time validation; clear errors when bytes drift.', tag: 'Updated · 2.8' },
    { n: '06', cat: 'Convert',  slug: 'hex',               name: 'Hex String Converter',
      href: 'hex-converter.html',
      blurb: 'Bidirectional hex ↔ string with UTF-8/16 and ASCII handling.', tag: 'New · 2.2' },
    { n: '07', cat: 'Convert',  slug: 'currency',          name: 'Currency Converter',
      href: 'currency-converter.html',
      blurb: '38 fiat currencies with 24-hour caching, 30-day history, trend arrows.', tag: 'New · 2.10' },
    { n: '08', cat: 'Convert',  slug: 'color',             name: 'Color Picker',
      href: 'color-picker.html',
      blurb: 'HEX, RGB(A), HSL(A), HSB, CMYK — round-trip with history and the system color panel.', tag: 'New · 2.8' },

    { n: '09', cat: 'Format',   slug: 'json',              name: 'JSON Formatter',
      href: 'json-formatter.html',
      blurb: 'Format, validate, diff. Side-by-side compare powered by CodeMirror.', tag: 'Updated · 2.11' },
    { n: '10', cat: 'Format',   slug: 'sql',               name: 'SQL Formatter',
      href: 'sql-formatter.html',
      blurb: 'Minimal and beautify modes. Side-by-side query diff for code review.', tag: 'Updated · 2.11' },
    { n: '11', cat: 'Format',   slug: 'html',              name: 'HTML Formatter',
      href: 'html-formatter.html',
      blurb: 'Indent, minify, validate. Diff mode for spotting markup drift.', tag: 'Updated · 2.11' },
    { n: '12', cat: 'Format',   slug: 'base64',            name: 'Base64',
      href: 'base64-encoder.html',
      blurb: 'Encode and decode with URL-safe variants and automatic detection.', tag: '' },
    { n: '13', cat: 'Format',   slug: 'jwt',               name: 'JWT',
      href: 'jwt-encoder.html',
      blurb: 'Encode and decode JSON Web Tokens. HMAC and RSA via CryptoKit.', tag: '' },

    { n: '14', cat: 'Generate', slug: 'uuid',              name: 'UUID Generator',
      href: 'uuid-generator.html',
      blurb: 'v1, v4, v5, v7. Bulk generation; pull a timestamp out of a v1 or v7.', tag: '' },
    { n: '15', cat: 'Generate', slug: 'random-string',     name: 'Random String',
      href: 'random-string-generator.html',
      blurb: 'Cryptographically secure. Five presets: passwords, API keys, tokens, IDs, slugs.', tag: 'New · 2.9' },
    { n: '16', cat: 'Generate', slug: 'qr',                name: 'QR Code',
      href: 'qr-code.html',
      blurb: 'Generate at multiple sizes and error correction levels. Scan from any image.', tag: '' },

    { n: '17', cat: 'Inspect',  slug: 'text-compare',      name: 'Text Compare',
      href: 'text-compare.html',
      blurb: 'Visual diff with character and line metrics. Built on the CodeMirror diff editor.', tag: 'New · 2.11' },
    { n: '18', cat: 'Inspect',  slug: 'regex',             name: 'Regex Test',
      href: 'regex-tester.html',
      blurb: 'Live pattern matching, capture groups, a library of common templates.', tag: '' },
    { n: '19', cat: 'Inspect',  slug: 'parquet',           name: 'Parquet Viewer',
      href: 'parquet-viewer.html',
      blurb: 'Inspect schema, browse rows, export. Powered by a unified Rust core.', tag: '' },

    { n: '20', cat: 'Network',  slug: 'http',              name: 'HTTP Client',
      href: 'http-request.html',
      blurb: 'Methods, headers, auth. Streaming and a JSON tree view for responses.', tag: '' },
    { n: '21', cat: 'Network',  slug: 'url',               name: 'URL Tools',
      href: 'url-tools.html',
      blurb: 'Encode, decode, parse. Component-by-component breakdown and validation.', tag: '' },
    { n: '22', cat: 'Network',  slug: 'ip',                name: 'IP Query',
      href: 'ip-query.html',
      blurb: 'Your address at a glance. Geolocation lookup for any IPv4 or IPv6.', tag: '' },
    { n: '23', cat: 'Network',  slug: 'crypto',            name: 'Crypto Tools',
      href: 'crypto-tools.html',
      blurb: 'MD5, CRC32, SHA-1/256/384/512. AES-GCM-256 and RSA-2048/4096.', tag: 'New · 1.12' },

    { n: '24', cat: 'Convert', slug: 'struct',            name: 'Struct Converter',
      href: 'struct-converter.html',
      blurb: 'Turn JSON, TOML, YAML, or SQL DDL into typed code — TypeScript, Python, Go, Java, Rust, Swift, PHP.', tag: 'New · 2.13' },
  ];

  const CATEGORIES = ['All', 'AI', 'Convert', 'Format', 'Generate', 'Inspect', 'Network'];

  // ── Hero rotator ─────────────────────────────────────────────────────────
  function initHeroRotator() {
    const el = document.querySelector('.rot-value');
    if (!el) return;
    const items = ['JSON.', 'JWT.', 'Regex.', 'UUIDs.', 'Hex.', 'SQL.', 'Base64.', 'Parquet.'];
    let i = 0;
    setInterval(() => {
      i = (i + 1) % items.length;
      el.textContent = items[i];
      el.style.animation = 'none';
      // force reflow to restart animation
      void el.offsetWidth;
      el.style.animation = '';
    }, 2400);
  }

  // ── Scroll progress hairline ─────────────────────────────────────────────
  function initScrollProgress() {
    const bar = document.querySelector('.nav-progress');
    if (!bar) return;
    const onScroll = () => {
      const h = document.documentElement;
      const max = h.scrollHeight - h.clientHeight;
      const p = max > 0 ? Math.min(1, h.scrollTop / max) : 0;
      bar.style.transform = `scaleX(${p})`;
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // ── Reveal on scroll ─────────────────────────────────────────────────────
  function initReveal() {
    const els = document.querySelectorAll('.reveal');
    if (!els.length) return;
    if (!('IntersectionObserver' in window)) {
      els.forEach((el) => el.classList.add('in'));
      return;
    }
    const io = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add('in');
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -8% 0px' });
    els.forEach((el) => io.observe(el));
  }

  // ── Smooth in-page anchor scroll ─────────────────────────────────────────
  function initSmoothAnchors() {
    document.addEventListener('click', (e) => {
      const a = e.target.closest('a[href^="#"]');
      if (!a) return;
      const id = a.getAttribute('href').slice(1);
      if (!id) return;
      const el = document.getElementById(id);
      if (!el) return;
      e.preventDefault();
      const y = el.getBoundingClientRect().top + window.scrollY - 64;
      window.scrollTo({ top: y, behavior: 'smooth' });
    });
  }

  // ── Tool index (search + categories) ─────────────────────────────────────
  function initToolIndex() {
    const grid = document.getElementById('tools-grid');
    const cats = document.getElementById('tools-cats');
    const input = document.getElementById('tools-search');
    const clear = document.getElementById('tools-search-clear');
    if (!grid) return;

    let q = '';
    let cat = 'All';

    function renderCats() {
      if (!cats) return;
      cats.innerHTML = CATEGORIES.map((c) => {
        const count = c === 'All' ? TOOLS.length : TOOLS.filter((t) => t.cat === c).length;
        return `<button type="button" class="cat ${cat === c ? 'on' : ''}" data-cat="${c}">
          ${c}<span class="cat-n">${count}</span>
        </button>`;
      }).join('');
      cats.querySelectorAll('.cat').forEach((b) => {
        b.addEventListener('click', () => {
          cat = b.dataset.cat;
          renderCats();
          render();
        });
      });
    }

    function render() {
      const filtered = TOOLS.filter((t) => {
        if (cat !== 'All' && t.cat !== cat) return false;
        if (q) {
          const hay = `${t.name} ${t.blurb} ${t.cat}`.toLowerCase();
          if (!hay.includes(q.toLowerCase())) return false;
        }
        return true;
      });
      if (!filtered.length) {
        grid.innerHTML = `<div class="tools-empty">
          <p>No tool matches that search. Try a different word, or browse all 24.</p>
          <button type="button" class="btn-ghost" id="tools-reset">Reset</button>
        </div>`;
        const btn = document.getElementById('tools-reset');
        if (btn) btn.addEventListener('click', () => {
          q = ''; cat = 'All';
          if (input) input.value = '';
          renderCats(); render();
        });
        return;
      }
      grid.innerHTML = filtered.map((t, i) => {
        const tag = t.tag ? `<span class="tool-tag">${t.tag}</span>` : '<span></span>';
        const href = t.href || `#${t.slug}`;
        return `<a class="tool" href="${href}" style="--i:${i}">
          <div class="tool-head">
            <span class="tool-n">${t.n}</span>
            <span class="tool-cat">${t.cat}</span>
          </div>
          <h3 class="tool-name">${t.name}</h3>
          <p class="tool-blurb">${t.blurb}</p>
          <div class="tool-foot">
            ${tag}
            <span class="tool-arrow" aria-hidden="true">
              <svg viewBox="0 0 16 16" width="12" height="12">
                <path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" stroke-width="1.4" fill="none" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
            </span>
          </div>
        </a>`;
      }).join('');
    }

    if (input) {
      input.addEventListener('input', () => {
        q = input.value;
        if (clear) clear.style.display = q ? '' : 'none';
        render();
      });
    }
    if (clear) {
      clear.style.display = 'none';
      clear.addEventListener('click', () => {
        q = '';
        if (input) input.value = '';
        clear.style.display = 'none';
        render();
      });
    }
    renderCats();
    render();
  }

  document.addEventListener('DOMContentLoaded', () => {
    initHeroRotator();
    initScrollProgress();
    initReveal();
    initSmoothAnchors();
    initToolIndex();
  });
})();
