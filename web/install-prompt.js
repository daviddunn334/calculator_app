// PWA Install Prompt Handler for NDT Tool-Kit
// Captures beforeinstallprompt event and shows custom install UI

let deferredPrompt;
let installButton;

// Track visit count for showing install prompt
function incrementVisitCount() {
  const visits = parseInt(localStorage.getItem('pwa_visit_count') || '0');
  localStorage.setItem('pwa_visit_count', (visits + 1).toString());
  return visits + 1;
}

function hasUserDismissedInstall() {
  return localStorage.getItem('pwa_install_dismissed') === 'true';
}

function hasUserInstalledApp() {
  return localStorage.getItem('pwa_installed') === 'true';
}

function markInstallDismissed() {
  localStorage.setItem('pwa_install_dismissed', 'true');
}

function markAppInstalled() {
  localStorage.setItem('pwa_installed', 'true');
}

// Create and show install banner
function showInstallBanner() {
  // Don't show if already dismissed or installed
  if (hasUserDismissedInstall() || hasUserInstalledApp()) {
    return;
  }

  // Create banner element
  const banner = document.createElement('div');
  banner.id = 'pwa-install-banner';
  banner.style.cssText = `
    position: fixed;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    background: linear-gradient(135deg, #1b325b 0%, #2a4a7f 100%);
    color: white;
    padding: 16px 24px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    z-index: 10000;
    max-width: 90%;
    width: 400px;
    font-family: 'Noto Sans', sans-serif;
    animation: slideUp 0.3s ease-out;
  `;

  banner.innerHTML = `
    <style>
      @keyframes slideUp {
        from {
          transform: translateX(-50%) translateY(100px);
          opacity: 0;
        }
        to {
          transform: translateX(-50%) translateY(0);
          opacity: 1;
        }
      }
      #pwa-install-banner button {
        border: none;
        padding: 10px 20px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        font-family: 'Noto Sans', sans-serif;
      }
      #pwa-install-banner button:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
      }
      #pwa-install-banner .install-btn {
        background: #fbcd0f;
        color: #1b325b;
        margin-right: 8px;
      }
      #pwa-install-banner .dismiss-btn {
        background: transparent;
        color: white;
        border: 1px solid rgba(255, 255, 255, 0.3);
      }
    </style>
    <div style="display: flex; align-items: center; gap: 16px;">
      <div style="flex: 1;">
        <div style="font-size: 16px; font-weight: 600; margin-bottom: 4px;">
          📱 Install NDT Tool-Kit
        </div>
        <div style="font-size: 13px; opacity: 0.9;">
          Fast access, offline support, native experience
        </div>
      </div>
      <div style="display: flex; gap: 8px; flex-wrap: wrap; justify-content: flex-end;">
        <button class="install-btn" id="pwa-install-btn">Install</button>
        <button class="dismiss-btn" id="pwa-dismiss-btn">Not now</button>
      </div>
    </div>
  `;

  document.body.appendChild(banner);

  // Add event listeners
  installButton = document.getElementById('pwa-install-btn');
  const dismissButton = document.getElementById('pwa-dismiss-btn');

  installButton.addEventListener('click', async () => {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      
      // Log analytics event
      if (window.firebase && window.firebase.analytics) {
        window.firebase.analytics.logEvent('pwa_install_prompt_action', {
          action: 'accepted',
          outcome: outcome
        });
      }

      if (outcome === 'accepted') {
        console.log('User accepted the install prompt');
        markAppInstalled();
      } else {
        console.log('User dismissed the install prompt');
      }
      
      deferredPrompt = null;
      banner.remove();
    }
  });

  dismissButton.addEventListener('click', () => {
    markInstallDismissed();
    banner.remove();
    
    // Log analytics event
    if (window.firebase && window.firebase.analytics) {
      window.firebase.analytics.logEvent('pwa_install_prompt_action', {
        action: 'dismissed'
      });
    }
  });

  // Log analytics event for banner shown
  if (window.firebase && window.firebase.analytics) {
    window.firebase.analytics.logEvent('pwa_install_prompt_shown', {
      visit_count: incrementVisitCount()
    });
  }
}

// Listen for beforeinstallprompt event
window.addEventListener('beforeinstallprompt', (e) => {
  console.log('beforeinstallprompt event fired');
  
  // Prevent the default install prompt
  e.preventDefault();
  
  // Stash the event for later use
  deferredPrompt = e;
  
  // Check if we should show the install banner
  const visitCount = incrementVisitCount();
  console.log('Visit count:', visitCount);
  
  // Show install banner on first visit
  if (visitCount >= 1) {
    // Wait a bit for the page to load before showing
    setTimeout(showInstallBanner, 2000);
  }
});

// Listen for successful app installation
window.addEventListener('appinstalled', (e) => {
  console.log('PWA was installed successfully');
  markAppInstalled();
  
  // Remove banner if it exists
  const banner = document.getElementById('pwa-install-banner');
  if (banner) {
    banner.remove();
  }
  
  // Log analytics event
  if (window.firebase && window.firebase.analytics) {
    window.firebase.analytics.logEvent('pwa_installed', {
      platform: navigator.platform,
      user_agent: navigator.userAgent
    });
  }
  
  deferredPrompt = null;
});

// Check if app is already installed (running in standalone mode)
if (window.matchMedia('(display-mode: standalone)').matches || 
    window.navigator.standalone === true) {
  console.log('App is running in standalone mode');
  markAppInstalled();
  
  // Log analytics event on app launch
  if (window.firebase && window.firebase.analytics) {
    window.firebase.analytics.logEvent('pwa_launched', {
      display_mode: 'standalone'
    });
  }
}

console.log('Install prompt handler loaded');
