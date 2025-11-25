// ============================================================================
// TURBODROP ACADEMY - MAIN APPLICATION
// ============================================================================

const TurboDrop = {
    // ========================================================================
    // INITIALIZATION
    // ========================================================================
    
    init() {
        this.initTheme();
        this.initMobileMenu();
        this.setupEventListeners();
    },

    // ========================================================================
    // THEME MANAGEMENT
    // ========================================================================

    initTheme() {
        const savedTheme = localStorage.getItem('theme') || 'light';
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        const theme = savedTheme === 'auto' ? (prefersDark ? 'dark' : 'light') : savedTheme;
        
        this.setTheme(theme);
    },

    setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        this.updateThemeToggleIcon(theme);
    },

    updateThemeToggleIcon(theme) {
        const toggle = document.getElementById('theme-toggle');
        if (!toggle) return;
        
        const icon = toggle.querySelector('.theme-icon');
        if (theme ===  'dark') {
            icon.innerHTML = `
                <circle cx="12" cy="12" r="5" stroke="currentColor" stroke-width="2"/>
                <path d="M12 1V3M12 21V23M23 12H21M3 12H1M20.485 3.515L19.071 4.929M4.929 19.071L3.515 20.485M20.485 20.485L19.071 19.071M4.929 4.929L3.515 3.515" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            `;
        } else {
            icon.innerHTML = `
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
            `;
        }
    },

    // ========================================================================
    // MOBILE MENU MANAGEMENT
    // ========================================================================

    initMobileMenu() {
        this.mobileMenuOpen = false;
    },

    toggleMobileMenu() {
        const toggle = document.getElementById('mobile-menu-toggle');
        const nav = document.querySelector('.header-nav');
        
        if (!toggle || !nav) return;

        this.mobileMenuOpen = !this.mobileMenuOpen;
        toggle.classList.toggle('active', this.mobileMenuOpen);
        nav.classList.toggle('active', this.mobileMenuOpen);
        toggle.setAttribute('aria-expanded', this.mobileMenuOpen);
    },

    closeMobileMenu() {
        const toggle = document.getElementById('mobile-menu-toggle');
        const nav = document.querySelector('.header-nav');
        
        if (!toggle || !nav) return;

        this.mobileMenuOpen = false;
        toggle.classList.remove('active');
        nav.classList.remove('active');
        toggle.setAttribute('aria-expanded', false);
    },

    // ========================================================================
    // EVENT LISTENERS
    // ========================================================================

    setupEventListeners() {
        // Theme toggle
        const themeToggle = document.getElementById('theme-toggle');
        if (themeToggle) {
            themeToggle.addEventListener('click', () => this.handleThemeToggle());
        }

        // Mobile menu toggle
        const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
        if (mobileMenuToggle) {
            mobileMenuToggle.addEventListener('click', () => this.toggleMobileMenu());
        }

        // Close mobile menu when clicking nav links
        const navLinks = document.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', () => this.closeMobileMenu());
        });

        // Close mobile menu when clicking outside
        document.addEventListener('click', (e) => {
            const header = document.querySelector('.header');
            if (header && !header.contains(e.target) && this.mobileMenuOpen) {
                this.closeMobileMenu();
            }
        });

        // Handle system theme preference changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            const savedTheme = localStorage.getItem('theme');
            if (savedTheme === 'auto') {
                this.setTheme(e.matches ? 'dark' : 'light');
            }
        });
    },

    handleThemeToggle() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        this.setTheme(newTheme);
    }
};

// ============================================================================
// PARALLAX SCROLL EFFECT
// ============================================================================

const ParallaxEffect = {
    init() {
        this.heroImage = document.querySelector('.hero-image');
        if (this.heroImage) {
            window.addEventListener('scroll', () => this.updateParallax());
        }
    },

    updateParallax() {
        if (!this.heroImage) return;
        
        const scrollY = window.scrollY;
        const parallaxOffset = scrollY * 0.5;
        this.heroImage.style.transform = `translateY(${parallaxOffset}px)`;
    }
};

// ============================================================================
// PROGRESS BAR ANIMATION
// ============================================================================

const ProgressBar = {
    init() {
        this.progressFill = document.querySelector('.progress-fill');
        if (this.progressFill) {
            window.addEventListener('scroll', () => this.updateProgress());
        }
    },

    updateProgress() {
        if (!this.progressFill) return;

        const howItWorksSection = document.getElementById('how-it-works-your-path-to-dropshipping-success');
        if (!howItWorksSection) return;

        const sectionTop = howItWorksSection.offsetTop;
        const sectionHeight = howItWorksSection.offsetHeight;
        const scrollY = window.scrollY;
        const windowHeight = window.innerHeight;

        // Calculate progress: 0% when section is below viewport, 100% when fully passed
        let progress = 0;
        if (scrollY + windowHeight > sectionTop) {
            progress = Math.min(100, ((scrollY + windowHeight - sectionTop) / (sectionHeight + windowHeight)) * 100);
        }

        this.progressFill.style.width = progress + '%';
    }
};

// ============================================================================
// STORIES CAROUSEL
// ============================================================================

const StoriesCarousel = {
    init() {
        this.carousel = document.querySelector('.stories-carousel');
        if (!this.carousel) return;

        this.cards = this.carousel.querySelectorAll('.story-card');
        this.currentIndex = 0;
        this.touchStartX = 0;
        this.touchEndX = 0;

        // Only enable swipe on mobile
        if (window.innerWidth < 768) {
            this.carousel.addEventListener('touchstart', (e) => this.handleTouchStart(e), false);
            this.carousel.addEventListener('touchend', (e) => this.handleTouchEnd(e), false);
        }

        window.addEventListener('resize', () => this.handleResize());
    },

    handleTouchStart(e) {
        this.touchStartX = e.changedTouches[0].screenX;
    },

    handleTouchEnd(e) {
        this.touchEndX = e.changedTouches[0].screenX;
        this.handleSwipe();
    },

    handleSwipe() {
        const swipeThreshold = 50;
        const diff = this.touchStartX - this.touchEndX;

        if (Math.abs(diff) > swipeThreshold) {
            if (diff > 0) {
                // Swiped left - next card
                this.nextCard();
            } else {
                // Swiped right - previous card
                this.prevCard();
            }
        }
    },

    nextCard() {
        this.currentIndex = (this.currentIndex + 1) % this.cards.length;
        this.updateCarousel();
    },

    prevCard() {
        this.currentIndex = (this.currentIndex - 1 + this.cards.length) % this.cards.length;
        this.updateCarousel();
    },

    updateCarousel() {
        const offset = -this.currentIndex * 100;
        this.carousel.style.transform = `translateX(${offset}%)`;
    },

    handleResize() {
        // Reset carousel on resize to desktop
        if (window.innerWidth >= 768) {
            this.carousel.style.transform = 'translateX(0)';
            this.currentIndex = 0;
        }
    }
};

// ============================================================================
// PRICING BILLING TOGGLE
// ============================================================================

const PricingToggle = {
    init() {
        this.toggle = document.getElementById('billing-toggle');
        if (!this.toggle) return;

        this.toggle.addEventListener('change', () => this.handleToggle());
    },

    handleToggle() {
        const isAnnual = this.toggle.checked;
        const priceAmounts = document.querySelectorAll('.price-amount');

        priceAmounts.forEach(element => {
            const monthlyPrice = parseFloat(element.dataset.monthly);
            const annualPrice = parseFloat(element.dataset.annual);
            const newPrice = isAnnual ? annualPrice : monthlyPrice;
            
            element.textContent = newPrice.toFixed(0);
            
            // Animate price change
            element.style.opacity = '0.5';
            setTimeout(() => {
                element.style.opacity = '1';
            }, 150);
        });

        // Update period text
        const periodTexts = document.querySelectorAll('.price-period');
        periodTexts.forEach(element => {
            element.textContent = isAnnual ? '/year' : '/month';
        });
    }
};

// ============================================================================
// FAQ ACCORDION
// ============================================================================

const FAQAccordion = {
    init() {
        this.questions = document.querySelectorAll('.faq-question');
        if (this.questions.length === 0) return;

        this.questions.forEach(question => {
            question.addEventListener('click', () => this.toggleQuestion(question));
        });
    },

    toggleQuestion(question) {
        const isExpanded = question.getAttribute('aria-expanded') === 'true';
        const answer = question.nextElementSibling;

        if (!answer || !answer.classList.contains('faq-answer')) return;

        // Close all other questions
        this.questions.forEach(q => {
            if (q !== question) {
                q.setAttribute('aria-expanded', 'false');
                const ans = q.nextElementSibling;
                if (ans && ans.classList.contains('faq-answer')) {
                    ans.hidden = true;
                }
            }
        });

        // Toggle current question
        question.setAttribute('aria-expanded', !isExpanded);
        answer.hidden = isExpanded;
    }
};

// ============================================================================
// INITIALIZATION ON DOM READY
// ============================================================================

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        TurboDrop.init();
        ParallaxEffect.init();
        ProgressBar.init();
        StoriesCarousel.init();
        PricingToggle.init();
        FAQAccordion.init();
    });
} else {
    TurboDrop.init();
    ParallaxEffect.init();
    ProgressBar.init();
    StoriesCarousel.init();
    PricingToggle.init();
    FAQAccordion.init();
}
