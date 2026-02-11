// Enhanced Service Worker for Integrity Tools PWA
// Version: 1.0.1 - Advanced caching with update notifications

const CACHE_VERSION = 'v1.0.1';
const CACHE_NAME = `integrity-tools-${CACHE_VERSION}`;
const DATA_CACHE_NAME = `integrity-tools-data-${CACHE_VERSION}`;

// Assets to precache on install
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './main.dart.js',
  './flutter.js',
  './manifest.json',
  './favicon.png',
  './install-prompt.js',
  './icons/app_icon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
  './icons/icon-192-maskable.png',
  './icons/icon-512-maskable.png',
  './icons/logo_main.png',
];

// Firebase and external URLs to bypass
const EXTERNAL_PATTERNS = [
  'firestore.googleapis.com',
  'firebasestorage.googleapis.com',
  'identitytoolkit.googleapis.com',
  'securetoken.googleapis.com',
  'firebase-auth',
  'fonts.googleapis.com',
  'fonts.gstatic.com',
  'www.gstatic.com'
];

// Check if URL should be cached
function shouldCache(url) {
  // Don't cache external resources
  if (EXTERNAL_PATTERNS.some(pattern => url.includes(pattern))) {
    return false;
  }
  
  // Don't cache cross-origin requests
  if (!url.startsWith(self.location.origin)) {
    return false;
  }
  
  return true;
}

// Install event - precache critical assets
self.addEventListener('install', (event) => {
  console.log('[ServiceWorker] Installing version:', CACHE_VERSION);
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[ServiceWorker] Precaching app shell');
        return cache.addAll(PRECACHE_ASSETS.map(url => new Request(url, {cache: 'reload'})));
      })
      .then(() => {
        console.log('[ServiceWorker] Skip waiting');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('[ServiceWorker] Precache failed:', error);
      })
  );
});

// Activate event - clean up old caches and claim clients
self.addEventListener('activate', (event) => {
  console.log('[ServiceWorker] Activating version:', CACHE_VERSION);
  
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME && cacheName !== DATA_CACHE_NAME) {
              console.log('[ServiceWorker] Removing old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('[ServiceWorker] Claiming clients');
        return self.clients.claim();
      })
      .then(() => {
        // Notify all clients that a new version is available
        return self.clients.matchAll().then(clients => {
          clients.forEach(client => {
            client.postMessage({
              type: 'UPDATE_AVAILABLE',
              version: CACHE_VERSION
            });
          });
        });
      })
  );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = request.url;
  
  // Skip cross-origin and Firebase requests
  if (!shouldCache(url)) {
    event.respondWith(fetch(request));
    return;
  }
  
  // Handle different types of requests with appropriate strategies
  if (request.method !== 'GET') {
    // Only cache GET requests
    event.respondWith(fetch(request));
    return;
  }
  
  // Determine caching strategy based on request type
  if (url.includes('/api/') || url.includes('firestore')) {
    // Network-first for API calls
    event.respondWith(networkFirst(request));
  } else if (url.match(/\.(js|css|woff|woff2|ttf|otf|eot)$/)) {
    // Cache-first for static assets
    event.respondWith(cacheFirst(request));
  } else if (url.includes('.png') || url.includes('.jpg') || url.includes('.svg') || url.includes('.ico')) {
    // Cache-first for images
    event.respondWith(cacheFirst(request));
  } else {
    // Stale-while-revalidate for HTML and other content
    event.respondWith(staleWhileRevalidate(request));
  }
});

// Cache-first strategy: Check cache first, fallback to network
async function cacheFirst(request) {
  try {
    const cache = await caches.open(CACHE_NAME);
    const cached = await cache.match(request);
    
    if (cached) {
      console.log('[ServiceWorker] Serving from cache:', request.url);
      return cached;
    }
    
    console.log('[ServiceWorker] Fetching from network:', request.url);
    const response = await fetch(request);
    
    if (response && response.status === 200) {
      cache.put(request, response.clone());
    }
    
    return response;
  } catch (error) {
    console.error('[ServiceWorker] Cache-first failed:', error);
    
    // Try to return cached version as fallback
    const cache = await caches.open(CACHE_NAME);
    const cached = await cache.match(request);
    if (cached) {
      return cached;
    }
    
    // Return offline page for HTML requests
    if (request.headers.get('accept').includes('text/html')) {
      const offlineResponse = await cache.match('./index.html');
      return offlineResponse || new Response('Offline', { status: 503 });
    }
    
    return new Response('Network error', { status: 503 });
  }
}

// Network-first strategy: Try network first, fallback to cache
async function networkFirst(request) {
  try {
    console.log('[ServiceWorker] Network-first for:', request.url);
    const response = await fetch(request);
    
    if (response && response.status === 200) {
      const cache = await caches.open(DATA_CACHE_NAME);
      cache.put(request, response.clone());
    }
    
    return response;
  } catch (error) {
    console.log('[ServiceWorker] Network failed, trying cache:', request.url);
    const cache = await caches.open(DATA_CACHE_NAME);
    const cached = await cache.match(request);
    
    if (cached) {
      return cached;
    }
    
    return new Response('Offline - No cached data', { 
      status: 503,
      statusText: 'Service Unavailable'
    });
  }
}

// Stale-while-revalidate: Return cache immediately, update in background
async function staleWhileRevalidate(request) {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);
  
  // Fetch updated version in background
  const fetchPromise = fetch(request).then((response) => {
    if (response && response.status === 200) {
      cache.put(request, response.clone());
    }
    return response;
  }).catch(() => {
    console.log('[ServiceWorker] Background fetch failed for:', request.url);
  });
  
  // Return cached version immediately if available
  if (cached) {
    console.log('[ServiceWorker] Serving stale content:', request.url);
    return cached;
  }
  
  // Otherwise wait for network
  console.log('[ServiceWorker] Waiting for network:', request.url);
  return fetchPromise;
}

// Handle messages from clients
self.addEventListener('message', (event) => {
  console.log('[ServiceWorker] Message received:', event.data);
  
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'CLAIM_CLIENTS') {
    self.clients.claim();
  }
  
  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_VERSION });
  }
  
  if (event.data && event.data.type === 'CLEAR_CACHE') {
    event.waitUntil(
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => caches.delete(cacheName))
        );
      }).then(() => {
        event.ports[0].postMessage({ success: true });
      })
    );
  }
});

// Push notification support (future enhancement)
self.addEventListener('push', (event) => {
  console.log('[ServiceWorker] Push notification received');
  
  const options = {
    body: event.data ? event.data.text() : 'New update available',
    icon: './icons/Icon-192.png',
    badge: './icons/icon-192-maskable.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    }
  };
  
  event.waitUntil(
    self.registration.showNotification('Integrity Tools', options)
  );
});

console.log('[ServiceWorker] Service Worker loaded - Version:', CACHE_VERSION);
