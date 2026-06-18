// ============================================================
// PolarNote — Service Worker
// Caches the app shell so the UI loads instantly and works offline.
// Supabase API/auth calls (cross-origin) are NEVER cached — they pass
// straight to the network; offline writes are queued in the page instead.
// ============================================================
const CACHE = 'polarnote-v1';
const SHELL = ['./', './index.html', './supabase-config.js'];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;                 // only cache reads
  const url = new URL(req.url);
  if (url.origin !== location.origin) return;       // let CDN / Supabase hit network directly

  // Same-origin shell: network-first (so updates ship), fall back to cache offline.
  e.respondWith(
    fetch(req)
      .then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(req, copy));
        return res;
      })
      .catch(() => caches.match(req).then(r => r || caches.match('./index.html')))
  );
});
