// Flutter web configuration for Integrity Tools
window.flutterWebRenderer = "html";
window.flutterConfiguration = {
  "buildMode": "release",
  "renderer": "html",
  "serviceWorkerVersion": null,
  "serviceWorkerUrl": "./service-worker.js",
  "enableOfflineMode": true
};

// Check if the app is installed
window.addEventListener('DOMContentLoaded', () => {
  // Check if the app is running in standalone mode (installed PWA)
  const isInStandaloneMode = window.matchMedia('(display-mode: standalone)').matches || 
                            window.navigator.standalone || 
                            document.referrer.includes('android-app://');
  
  // Store the installation status
  window.isAppInstalled = isInStandaloneMode;
  
  // Log installation status
  console.log('App is installed:', isInStandaloneMode);
  
  // Check for service worker support
  if ('serviceWorker' in navigator) {
    // Register service worker
    navigator.serviceWorker.register('./service-worker.js')
      .then(registration => {
        console.log('Service Worker registered with scope:', registration.scope);
        
        // Check for updates
        registration.onupdatefound = () => {
          const installingWorker = registration.installing;
          installingWorker.onstatechange = () => {
            if (installingWorker.state === 'installed') {
              if (navigator.serviceWorker.controller) {
                console.log('New content is available; please refresh.');
              } else {
                console.log('Content is cached for offline use.');
              }
            }
          };
        };
      })
      .catch(error => {
        console.error('Service Worker registration failed:', error);
      });
  }
});
