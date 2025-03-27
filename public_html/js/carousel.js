/* filepath: /Users/danielreis/web/danrtzaq/public_html/js/carousel.js */
/* Carousel with Swipe Support v1.4
 * Adds swipe gestures to carousel elements for mobile devices
 * Using external CSS for styles - see /styles/feature-carousel.css
 */

class Carousel {
  constructor(element) {
    this.carousel = element;
    this.container = element.querySelector(".carousel-container");
    this.track = element.querySelector(".carousel-track");
    this.slides = element.querySelectorAll(".carousel-slide");
    this.items = Array.from(this.slides); // Make sure we're using the slides as items
    this.totalItems = this.items.length;
    this.currentIndex = 0;

    // Find the content caption container
    this.captionContainer = element.querySelector(".content-caption");
    if (this.captionContainer) {
      this.descriptions = Array.from(
        this.captionContainer.querySelectorAll(".carousel-description"),
      );
    } else {
      this.descriptions = [];
    }

    // Ensure caption container is properly positioned
    this.ensureCaptionContainment();

    // Initialize carousel
    this.initButtons();
    this.initIndicators();
    this.setupEventListeners();
    this.setupAnimation();
    this.initVideos();

    // Add focus for accessibility
    this.carousel.setAttribute("tabindex", "0");

    // Add hint class for mobile devices
    if ("ontouchstart" in window) {
      this.carousel.classList.add("has-gesture-hint");
    }

    // Initial update
    this.updateCarousel(false);

    // Log initialization for debugging
    console.log(`Carousel initialized with ${this.totalItems} items`);
  }

  ensureCaptionContainment() {
    // Find the carousel's content-caption element
    if (this.captionContainer) {
      // Make sure the caption container has the proper width
      this.captionContainer.style.width = "100%";
      this.captionContainer.style.maxWidth = "100%";
      this.captionContainer.style.boxSizing = "border-box"; // Ensure padding is included

      // Ensure descriptions don't overflow
      const descriptions = this.captionContainer.querySelectorAll(
        ".carousel-description",
      );
      descriptions.forEach((desc) => {
        desc.style.maxWidth = "100%";
        desc.style.boxSizing = "border-box";
        desc.style.padding = "5px"; // Add padding
      });
    }
  }

  initVideos() {
    const videoContainers = this.carousel.querySelectorAll(".video-container");

    videoContainers.forEach((container) => {
      const video = container.querySelector("video");
      if (!video) return;

      // Set initial state
      if (video.paused) {
        container.classList.add("paused");
      }

      // Handle click for both play and pause
      container.addEventListener("click", (e) => {
        if (container.classList.contains("paused")) {
          video.play().catch(() => {});
        } else {
          video.pause();
        }
      });

      // Update state on play/pause
      video.addEventListener("play", () => {
        container.classList.remove("paused");
      });

      video.addEventListener("pause", () => {
        container.classList.add("paused");
      });
    });
  }

  setupAnimation() {
    // Add transition property to the track element for smooth sliding
    if (this.track) {
      this.track.style.transition = "transform 0.5s ease-in-out";
    }
  }

  initButtons() {
    this.prevButton = this.carousel.querySelector(".carousel-button.prev");
    this.nextButton = this.carousel.querySelector(".carousel-button.next");

    if (this.prevButton) {
      this.prevButton.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.prev();
        console.log("Prev button clicked, now at index:", this.currentIndex);
      });
    }

    if (this.nextButton) {
      this.nextButton.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.next();
        console.log("Next button clicked, now at index:", this.currentIndex);
      });
    }
  }

  initIndicators() {
    this.indicators = Array.from(
      this.carousel.querySelectorAll(".carousel-indicator"),
    );

    this.indicators.forEach((indicator, index) => {
      indicator.addEventListener("click", () => {
        this.goToSlide(index);
        console.log("Indicator clicked, now at index:", this.currentIndex);
      });
    });
  }

  setupEventListeners() {
    // Setup keyboard navigation
    this.carousel.addEventListener("keydown", (e) => {
      if (e.key === "ArrowLeft") {
        this.prev();
        e.preventDefault();
      } else if (e.key === "ArrowRight") {
        this.next();
        e.preventDefault();
      }
    });

    // Setup touch events
    this.carousel.addEventListener(
      "touchstart",
      (e) => {
        this.touchStartX = e.changedTouches[0].screenX;
        this.touchStartY = e.changedTouches[0].screenY;
        this.carousel.classList.add("is-touching");
      },
      { passive: true },
    );

    this.carousel.addEventListener(
      "touchend",
      (e) => {
        this.touchEndX = e.changedTouches[0].screenX;
        this.touchEndY = e.changedTouches[0].screenY;
        this.carousel.classList.remove("is-touching");

        const xDiff = this.touchEndX - this.touchStartX;
        const yDiff = this.touchEndY - this.touchStartY;
        const minSwipeDistance = 30;

        if (
          Math.abs(xDiff) > Math.abs(yDiff) &&
          Math.abs(xDiff) > minSwipeDistance
        ) {
          if (xDiff > 0) {
            this.prev();
          } else {
            this.next();
          }
        }
      },
      { passive: true },
    );
  }

  goToSlide(index) {
    if (index < 0 || index >= this.totalItems) {
      console.warn("Invalid slide index:", index);
      return;
    }
    this.currentIndex = index;
    this.updateCarousel();
  }

  next() {
    if (this.totalItems <= 1) return;
    this.currentIndex = (this.currentIndex + 1) % this.totalItems;
    this.updateCarousel();
  }

  prev() {
    if (this.totalItems <= 1) return;
    this.currentIndex =
      (this.currentIndex - 1 + this.totalItems) % this.totalItems;
    this.updateCarousel();
  }

  updateCarousel(animate = true) {
    // Update slide positions using the track element
    if (this.track) {
      if (!animate) {
        // Temporarily remove transition for immediate positioning
        const originalTransition = this.track.style.transition;
        this.track.style.transition = "none";
        this.track.style.transform = `translateX(-${this.currentIndex * 100}%)`;

        // Force reflow to ensure the style change takes effect immediately
        void this.track.offsetWidth;

        // Restore transition
        this.track.style.transition = originalTransition;
      } else {
        this.track.style.transform = `translateX(-${this.currentIndex * 100}%)`;
      }
    }

    // Update indicators
    if (this.indicators && this.indicators.length) {
      this.indicators.forEach((indicator, index) => {
        indicator.classList.toggle("active", index === this.currentIndex);
        indicator.setAttribute("aria-selected", index === this.currentIndex);
        indicator.setAttribute("role", "tab");
      });
    }

    // Update descriptions if they exist
    if (this.descriptions && this.descriptions.length > 0) {
      this.descriptions.forEach((desc, index) => {
        // Use toggle to add/remove the active class
        desc.classList.toggle("active", index === this.currentIndex);

        // Also update ARIA-hidden for accessibility
        desc.setAttribute("aria-hidden", index !== this.currentIndex);
      });
    }

    // Dispatch custom event for slide change
    const event = new CustomEvent("slideChanged", {
      detail: {
        currentIndex: this.currentIndex,
        totalSlides: this.totalItems,
      },
    });
    this.carousel.dispatchEvent(event);
  }
}

// Initialize carousels
document.addEventListener("DOMContentLoaded", () => {
  // Load CSS dynamically if it's not already loaded
  if (!document.querySelector('link[href*="feature-carousel.css"]')) {
    const cssLink = document.createElement("link");
    cssLink.rel = "stylesheet";
    cssLink.href = "/styles/feature-carousel.css";
    document.head.appendChild(cssLink);
  }

  // Initialize all carousels on the page
  const carousels = document.querySelectorAll(".carousel");
  carousels.forEach((carousel) => {
    // Only initialize if it has slides
    const slides = carousel.querySelectorAll(".carousel-slide");
    if (slides.length > 0) {
      new Carousel(carousel);
    } else {
      console.warn("Carousel has no slides:", carousel);
    }
  });
});
