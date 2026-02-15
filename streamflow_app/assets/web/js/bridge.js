/**
 * StreamFlow Flutter-WebView Bridge
 * Handles communication between Flutter and WebView
 * Optimized for Android and Linux platforms
 */

const StreamFlow = {
    // Platform detection
    platform: 'unknown',
    isAndroid: false,
    isLinux: false,
    isMobile: false,

    // Initialize bridge
    init: function () {
        this.detectPlatform();
        this.setupEventListeners();
        this.optimizeForPlatform();
        console.log('[StreamFlow] Bridge initialized for:', this.platform);
    },

    // Detect platform from Flutter
    detectPlatform: function () {
        const ua = navigator.userAgent.toLowerCase();
        this.isAndroid = ua.includes('android');
        this.isLinux = ua.includes('linux') && !this.isAndroid;
        this.isMobile = this.isAndroid || window.innerWidth < 768;
        this.platform = this.isAndroid ? 'android' : (this.isLinux ? 'linux' : 'web');
    },

    // Platform-specific optimizations
    optimizeForPlatform: function () {
        const html = document.documentElement;
        html.classList.add('platform-' + this.platform);

        if (this.isAndroid) {
            // Android optimizations
            html.style.setProperty('--blur-amount', '10px'); // Reduced blur for mobile GPU
            html.style.setProperty('--animation-duration', '0.3s'); // Faster animations
            document.body.classList.add('touch-device');
            this.enableTouchOptimizations();
        } else if (this.isLinux) {
            // Linux/Desktop optimizations
            html.style.setProperty('--blur-amount', '20px'); // Full blur
            html.style.setProperty('--animation-duration', '0.5s');
            document.body.classList.add('pointer-device');
            this.enableHoverOptimizations();
        }
    },

    // Touch optimizations for Android
    enableTouchOptimizations: function () {
        // Larger touch targets
        document.querySelectorAll('button, a, .clickable').forEach(el => {
            el.style.minHeight = '44px';
            el.style.minWidth = '44px';
        });

        // Disable hover effects on touch
        document.body.addEventListener('touchstart', () => {
            document.body.classList.add('touch-active');
        }, { passive: true });
    },

    // Hover optimizations for Linux/Desktop
    enableHoverOptimizations: function () {
        // Enable all hover effects
        document.body.classList.add('hover-enabled');
    },

    // Setup event listeners for Flutter communication
    setupEventListeners: function () {
        // Handle navigation clicks
        document.addEventListener('click', (e) => {
            const target = e.target.closest('[data-navigate]');
            if (target) {
                e.preventDefault();
                const route = target.dataset.navigate;
                this.sendToFlutter('navigate', { route: route });
            }
        });

        // Handle play button clicks
        document.addEventListener('click', (e) => {
            const playBtn = e.target.closest('[data-play]');
            if (playBtn) {
                e.preventDefault();
                const animeId = playBtn.dataset.play;
                const episodeId = playBtn.dataset.episode || null;
                this.sendToFlutter('play', { animeId: animeId, episodeId: episodeId });
            }
        });

        // Handle add to list
        document.addEventListener('click', (e) => {
            const addBtn = e.target.closest('[data-add-list]');
            if (addBtn) {
                e.preventDefault();
                const animeId = addBtn.dataset.addList;
                this.sendToFlutter('addToList', { animeId: animeId });
            }
        });
    },

    // Send message to Flutter
    sendToFlutter: function (action, data) {
        const message = JSON.stringify({ action: action, data: data });

        // Try different bridge methods for platform compatibility
        if (window.FlutterBridge) {
            window.FlutterBridge.postMessage(message);
        } else if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.FlutterBridge) {
            window.webkit.messageHandlers.FlutterBridge.postMessage(message);
        } else {
            console.log('[StreamFlow] Bridge message:', message);
        }
    },

    // Receive message from Flutter
    receiveFromFlutter: function (message) {
        try {
            const data = typeof message === 'string' ? JSON.parse(message) : message;
            console.log('[StreamFlow] Received from Flutter:', data);

            switch (data.action) {
                case 'updateAnimeData':
                    this.updateAnimeData(data.payload);
                    break;
                case 'setTheme':
                    this.setTheme(data.payload);
                    break;
                case 'showLoading':
                    this.showLoading(data.payload);
                    break;
                case 'hideLoading':
                    this.hideLoading();
                    break;
            }
        } catch (e) {
            console.error('[StreamFlow] Error parsing message:', e);
        }
    },

    // Update anime data dynamically
    updateAnimeData: function (animeList) {
        const container = document.querySelector('[data-anime-container]');
        if (!container) return;

        // Clear and repopulate
        container.innerHTML = '';
        animeList.forEach(anime => {
            container.appendChild(this.createAnimeCard(anime));
        });
    },

    // Create anime card element
    createAnimeCard: function (anime) {
        const card = document.createElement('div');
        card.className = 'group relative flex-none w-[240px] md:w-[280px]';
        card.innerHTML = `
            <div class="relative aspect-[2/3] rounded-2xl overflow-hidden transition-all duration-500 ease-out group-hover:scale-105 group-hover:-translate-y-4 shadow-ambient-${anime.shadowColor} group-hover:shadow-ambient-${anime.shadowColor}-hover z-10 cursor-pointer" data-play="${anime.id}">
                <div class="absolute inset-0 bg-cover bg-center" style="background-image: url('${anime.image}');"></div>
                <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-60 group-hover:opacity-40 transition-opacity"></div>
            </div>
            <div class="mt-6 opacity-80 group-hover:opacity-100 transition-opacity">
                <h4 class="text-white font-medium text-xl tracking-tight">${anime.title}</h4>
                <div class="flex items-center gap-3 text-xs text-text-secondary mt-2 font-light">
                    ${anime.genres.map(g => `<span>${g}</span>`).join('<span class="size-1 bg-white/30 rounded-full"></span>')}
                </div>
            </div>
        `;
        return card;
    },

    // Set theme
    setTheme: function (theme) {
        document.documentElement.setAttribute('data-theme', theme);
    },

    // Loading states
    showLoading: function (options) {
        let loader = document.getElementById('streamflow-loader');
        if (!loader) {
            loader = document.createElement('div');
            loader.id = 'streamflow-loader';
            loader.className = 'fixed inset-0 bg-black/80 backdrop-blur-sm z-[9999] flex items-center justify-center';
            loader.innerHTML = `
                <div class="w-12 h-12 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
            `;
            document.body.appendChild(loader);
        }
        loader.style.display = 'flex';
    },

    hideLoading: function () {
        const loader = document.getElementById('streamflow-loader');
        if (loader) loader.style.display = 'none';
    },

    // Lazy loading for images
    setupLazyLoading: function () {
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        if (img.dataset.src) {
                            img.style.backgroundImage = `url('${img.dataset.src}')`;
                            img.classList.add('loaded');
                            observer.unobserve(img);
                        }
                    }
                });
            }, { rootMargin: '100px' });

            document.querySelectorAll('[data-src]').forEach(img => {
                imageObserver.observe(img);
            });
        }
    }
};

// Initialize on DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => StreamFlow.init());
} else {
    StreamFlow.init();
}

// Expose to Flutter
window.StreamFlow = StreamFlow;
