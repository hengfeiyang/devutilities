// DevUtilities Website JavaScript
(function() {
    'use strict';
    
    // DOM Elements
    const header = document.querySelector('.header');
    const navToggle = document.querySelector('.nav-toggle');
    const navLinks = document.querySelector('.nav-links');
    const downloadBtn = document.getElementById('downloadBtn');
    const screenshotCards = document.querySelectorAll('.screenshot-card');
    const heroSlider = document.querySelector('.hero-slider');
    
    // Initialize when DOM is loaded
    document.addEventListener('DOMContentLoaded', function() {
        initNavigation();
        initHeroSlider();
        initScrollEffects();
        initImageLazyLoading();
        initScreenshotGallery();
        initDownloadButton();
    });
    
    // Navigation functionality
    function initNavigation() {
        // Mobile nav toggle
        if (navToggle && navLinks) {
            navToggle.addEventListener('click', function() {
                navLinks.classList.toggle('active');
                navToggle.classList.toggle('active');
            });
        }
        
        // Close mobile nav when clicking on links
        const navLinksArray = document.querySelectorAll('.nav-link');
        navLinksArray.forEach(link => {
            link.addEventListener('click', function() {
                if (navLinks) {
                    navLinks.classList.remove('active');
                }
                if (navToggle) {
                    navToggle.classList.remove('active');
                }
            });
        });
        
        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    const headerHeight = header ? header.offsetHeight : 0;
                    const targetPosition = target.offsetTop - headerHeight - 20;
                    
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            });
        });
    }
    
    // Hero Slider functionality
    function initHeroSlider() {
        if (!heroSlider) return;
        
        const slides = heroSlider.querySelectorAll('.slide');
        const indicators = heroSlider.querySelectorAll('.indicator');
        const prevBtn = heroSlider.querySelector('.prev-btn');
        const nextBtn = heroSlider.querySelector('.next-btn');
        const progressBar = heroSlider.querySelector('.progress-bar');
        
        let currentSlide = 0;
        let slideInterval = null;
        let progressInterval = null;
        let isPaused = false;
        let isTransitioning = false;
        
        const slideTimeout = 5000; // 5 seconds per slide
        const progressStep = 100 / (slideTimeout / 100); // Update progress every 100ms
        
        // Show specific slide
        function showSlide(index) {
            if (isTransitioning || index === currentSlide) return;
            
            isTransitioning = true;
            
            // Remove active class from all slides and indicators
            slides.forEach(slide => slide.classList.remove('active'));
            indicators.forEach(indicator => indicator.classList.remove('active'));
            
            // Add active class to current slide and indicator
            slides[index].classList.add('active');
            indicators[index].classList.add('active');
            
            currentSlide = index;
            resetProgress();
            
            // Allow transitions again after animation completes
            setTimeout(() => {
                isTransitioning = false;
            }, 800);
        }
        
        // Next slide
        function nextSlide() {
            const next = (currentSlide + 1) % slides.length;
            showSlide(next);
        }
        
        // Previous slide
        function prevSlide() {
            const prev = (currentSlide - 1 + slides.length) % slides.length;
            showSlide(prev);
        }
        
        // Reset progress bar
        function resetProgress() {
            if (progressBar) {
                progressBar.style.width = '0%';
                clearInterval(progressInterval);
                
                if (!isPaused) {
                    startProgress();
                }
            }
        }
        
        // Start progress animation
        function startProgress() {
            if (isPaused || !progressBar) return;
            
            let progress = 0;
            progressInterval = setInterval(() => {
                if (isPaused) {
                    clearInterval(progressInterval);
                    return;
                }
                
                progress += progressStep;
                progressBar.style.width = Math.min(progress, 100) + '%';
                
                if (progress >= 100) {
                    clearInterval(progressInterval);
                }
            }, 100);
        }
        
        // Auto-play functionality
        function startAutoPlay() {
            if (slideInterval) return; // Prevent multiple intervals
            slideInterval = setInterval(() => {
                if (!isPaused && !isTransitioning) {
                    nextSlide();
                }
            }, slideTimeout);
        }
        
        function stopAutoPlay() {
            if (slideInterval) {
                clearInterval(slideInterval);
                slideInterval = null;
            }
            if (progressInterval) {
                clearInterval(progressInterval);
                progressInterval = null;
            }
        }
        
        // Event listeners
        if (prevBtn) {
            prevBtn.addEventListener('click', (e) => {
                e.preventDefault();
                if (!isTransitioning) {
                    prevSlide();
                    stopAutoPlay();
                    setTimeout(startAutoPlay, 2000); // Resume after 2 seconds
                }
            });
        }
        
        if (nextBtn) {
            nextBtn.addEventListener('click', (e) => {
                e.preventDefault();
                if (!isTransitioning) {
                    nextSlide();
                    stopAutoPlay();
                    setTimeout(startAutoPlay, 2000); // Resume after 2 seconds
                }
            });
        }
        
        // Indicator clicks
        indicators.forEach((indicator, index) => {
            indicator.addEventListener('click', (e) => {
                e.preventDefault();
                if (index !== currentSlide && !isTransitioning) {
                    showSlide(index);
                    stopAutoPlay();
                    setTimeout(startAutoPlay, 2000); // Resume after 2 seconds
                }
            });
        });
        
        // Pause on hover
        heroSlider.addEventListener('mouseenter', () => {
            isPaused = true;
            stopAutoPlay();
        });
        
        heroSlider.addEventListener('mouseleave', () => {
            isPaused = false;
            startAutoPlay();
            resetProgress();
        });
        
        // Touch/swipe support for mobile
        let touchStartX = null;
        let touchStartY = null;
        
        heroSlider.addEventListener('touchstart', (e) => {
            touchStartX = e.touches[0].clientX;
            touchStartY = e.touches[0].clientY;
        }, { passive: true });
        
        heroSlider.addEventListener('touchmove', (e) => {
            if (!touchStartX || !touchStartY) return;
            
            const touchEndX = e.touches[0].clientX;
            const touchEndY = e.touches[0].clientY;
            
            const deltaX = touchStartX - touchEndX;
            const deltaY = touchStartY - touchEndY;
            
            // Only handle horizontal swipes
            if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 30) {
                e.preventDefault();
            }
        }, { passive: false });
        
        heroSlider.addEventListener('touchend', (e) => {
            if (!touchStartX || !touchStartY) return;
            
            const touchEndX = e.changedTouches[0].clientX;
            const touchEndY = e.changedTouches[0].clientY;
            
            const deltaX = touchStartX - touchEndX;
            const deltaY = touchStartY - touchEndY;
            
            // Only handle horizontal swipes (minimum 50px)
            if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
                if (deltaX > 0) {
                    // Swipe left - next slide
                    nextSlide();
                } else {
                    // Swipe right - previous slide
                    prevSlide();
                }
                stopAutoPlay();
                setTimeout(startAutoPlay, 1000);
            }
            
            touchStartX = null;
            touchStartY = null;
        }, { passive: true });
        
        // Keyboard navigation
        document.addEventListener('keydown', (e) => {
            if (heroSlider.matches(':hover') || document.activeElement.closest('.hero-slider')) {
                if (e.key === 'ArrowLeft') {
                    e.preventDefault();
                    prevSlide();
                    stopAutoPlay();
                    setTimeout(startAutoPlay, 1000);
                } else if (e.key === 'ArrowRight') {
                    e.preventDefault();
                    nextSlide();
                    stopAutoPlay();
                    setTimeout(startAutoPlay, 1000);
                }
            }
        });
        
        // Handle visibility changes (pause when tab is not visible)
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                stopAutoPlay();
            } else if (!isPaused) {
                startAutoPlay();
                resetProgress();
            }
        });
        
        // Preload all slide images
        slides.forEach((slide, index) => {
            const img = slide.querySelector('.slide-image');
            if (img && img.src) {
                const preloadImg = new Image();
                preloadImg.src = img.src;
                
                // Show slide when image is loaded (for first slide)
                if (index === 0) {
                    preloadImg.onload = () => {
                        slide.style.opacity = '1';
                    };
                }
            }
        });
        
        // Initialize
        showSlide(0);
        startAutoPlay();
        
        // Add ARIA labels for accessibility
        heroSlider.setAttribute('role', 'region');
        heroSlider.setAttribute('aria-label', 'DevUtilities screenshots slideshow');
        
        indicators.forEach((indicator, index) => {
            indicator.setAttribute('role', 'button');
            indicator.setAttribute('aria-label', `Go to slide ${index + 1}`);
        });
    }
    
    // Scroll effects
    function initScrollEffects() {
        let ticking = false;
        
        function updateHeader() {
            if (!header) return;

            const scrolled = window.pageYOffset > 10;

            if (scrolled) {
                header.classList.add('scrolled');
                header.style.background = 'rgba(255, 255, 255, 0.95)';
                header.style.boxShadow = '0 4px 24px rgba(0, 0, 0, 0.08)';
            } else {
                header.classList.remove('scrolled');
                header.style.background = 'rgba(255, 255, 255, 0.8)';
                header.style.boxShadow = 'none';
            }
        }
        
        function onScroll() {
            if (!ticking) {
                requestAnimationFrame(function() {
                    updateHeader();
                    ticking = false;
                });
                ticking = true;
            }
        }
        
        window.addEventListener('scroll', onScroll);
        updateHeader(); // Initial call
    }
    
    // Image lazy loading
    function initImageLazyLoading() {
        const lazyImages = document.querySelectorAll('img[loading="lazy"]');
        
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.classList.add('loaded');
                        observer.unobserve(img);
                    }
                });
            });
            
            lazyImages.forEach(img => {
                imageObserver.observe(img);
                
                // Add loaded class when image is actually loaded
                img.addEventListener('load', function() {
                    this.classList.add('loaded');
                });
            });
        } else {
            // Fallback for browsers without IntersectionObserver
            lazyImages.forEach(img => {
                img.classList.add('loaded');
            });
        }
    }
    
    // Screenshot gallery functionality
    function initScreenshotGallery() {
        screenshotCards.forEach(card => {
            card.addEventListener('click', function() {
                const img = this.querySelector('img');
                if (img) {
                    openImageModal(img.src, img.alt);
                }
            });
        });
    }
    
    // Simple image modal
    function openImageModal(src, alt) {
        const modal = document.createElement('div');
        modal.className = 'image-modal';
        modal.innerHTML = `
            <div class="modal-backdrop">
                <div class="modal-content">
                    <img src="${src}" alt="${alt}" class="modal-image">
                    <button class="modal-close" aria-label="Close modal">&times;</button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        document.body.style.overflow = 'hidden';
        
        // Add modal styles if not already added
        if (!document.querySelector('#modal-styles')) {
            const styles = document.createElement('style');
            styles.id = 'modal-styles';
            styles.textContent = `
                .image-modal {
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    z-index: 2000;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    opacity: 0;
                    animation: modalFadeIn 0.3s ease forwards;
                }
                
                .modal-backdrop {
                    background: rgba(0, 0, 0, 0.9);
                    width: 100%;
                    height: 100%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 2rem;
                }
                
                .modal-content {
                    position: relative;
                    max-width: 90%;
                    max-height: 90%;
                }
                
                .modal-image {
                    max-width: 100%;
                    max-height: 100%;
                    border-radius: 12px;
                    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
                }
                
                .modal-close {
                    position: absolute;
                    top: -40px;
                    right: 0;
                    background: none;
                    border: none;
                    color: white;
                    font-size: 2rem;
                    cursor: pointer;
                    width: 40px;
                    height: 40px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border-radius: 50%;
                    transition: background 0.2s ease;
                }
                
                .modal-close:hover {
                    background: rgba(255, 255, 255, 0.1);
                }
                
                @keyframes modalFadeIn {
                    to { opacity: 1; }
                }
                
                @media (max-width: 768px) {
                    .modal-backdrop {
                        padding: 1rem;
                    }
                    .modal-close {
                        top: -50px;
                        right: -10px;
                    }
                }
            `;
            document.head.appendChild(styles);
        }
        
        // Close modal functionality
        const closeModal = () => {
            modal.style.opacity = '0';
            setTimeout(() => {
                document.body.removeChild(modal);
                document.body.style.overflow = '';
            }, 300);
        };
        
        modal.querySelector('.modal-close').addEventListener('click', closeModal);
        modal.querySelector('.modal-backdrop').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });
        
        // Close on Escape key
        const escapeHandler = (e) => {
            if (e.key === 'Escape') {
                closeModal();
                document.removeEventListener('keydown', escapeHandler);
            }
        };
        document.addEventListener('keydown', escapeHandler);
    }
    
    // Download button functionality
    function initDownloadButton() {
        if (downloadBtn) {
            downloadBtn.addEventListener('click', function() {
                // Track download attempt (you can replace this with your analytics)
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'download_attempt', {
                        'event_category': 'engagement',
                        'event_label': 'devutilities_download'
                    });
                }
            });
        }
    }
    
    // Utility function to detect if user prefers reduced motion
    function prefersReducedMotion() {
        return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    }
    
    // Feature detection and progressive enhancement
    function initProgressiveEnhancements() {
        // Add JS class to body for CSS hooks
        document.body.classList.add('js-enabled');
        
        // Remove no-js class if present
        document.body.classList.remove('no-js');
        
        // Add support for various features
        if ('IntersectionObserver' in window) {
            document.body.classList.add('intersection-observer');
        }
        
        if ('ServiceWorker' in navigator) {
            document.body.classList.add('service-worker');
        }
        
        // Respect user's motion preferences
        if (prefersReducedMotion()) {
            document.body.classList.add('reduce-motion');
        }
    }
    
    // Initialize progressive enhancements
    initProgressiveEnhancements();
    
    // Handle page visibility changes
    document.addEventListener('visibilitychange', function() {
        if (document.visibilityState === 'visible') {
            // Page is now visible, you can resume any paused animations
        } else {
            // Page is now hidden, you can pause animations to save resources
        }
    });
    
    // Performance monitoring (optional)
    if ('PerformanceObserver' in window) {
        try {
            const perfObserver = new PerformanceObserver((list) => {
                list.getEntries().forEach((entry) => {
                    if (entry.entryType === 'largest-contentful-paint') {
                        // Track LCP for performance monitoring
                        console.log('LCP:', entry.startTime);
                    }
                });
            });
            
            perfObserver.observe({entryTypes: ['largest-contentful-paint']});
        } catch (e) {
            // Ignore errors in performance monitoring
        }
    }
    
})();