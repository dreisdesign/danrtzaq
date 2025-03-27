/**
 * Video handling script
 * Version: 1.5
 * Last updated: 2025-03-17
 */

document.addEventListener("DOMContentLoaded", function () {
  initializeVideos();
});

function initializeVideos() {
  const videoContainers = document.querySelectorAll(".video-container");
  const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);

  // Keep track of fade timeouts for each video
  const fadeTimeouts = new Map();

  videoContainers.forEach((container) => {
    const video = container.querySelector("video");
    const overlay = container.querySelector(".overlay");

    if (video && overlay) {
      // Force overlay to be visible initially for all browsers
      overlay.style.display = "block";

      // Ensure videos have poster images in Safari
      if (isSafari && !video.hasAttribute("poster")) {
        createPosterFromVideo(video);
      }

      // Special handling for Safari
      if (isSafari) {
        overlay.classList.add("safari-overlay");
      }

      // Apply standard styling to ensure consistency
      standardizeVideoAppearance(container, video, overlay);

      // Pause videos initially
      video.pause();

      // Set the paused class on container
      container.classList.add("paused");

      // Handle clicks and video state changes
      setupVideoInteractions(video, overlay, container, () => {
        // This callback runs when a video starts playing
        // No action needed here - allow all videos to play simultaneously
      });
    }
  });
}

// Function to ensure consistent appearance across all videos
function standardizeVideoAppearance(container, video, overlay) {
  // Restore default classes if needed
  if (!overlay.className.includes("overlay")) {
    overlay.className = "overlay";
  }

  if (/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) {
    overlay.classList.add("safari-overlay");
  }

  // Force overlay to be absolutely positioned and cover the whole video
  overlay.style.position = "absolute";
  overlay.style.top = "0";
  overlay.style.left = "0";
  overlay.style.width = "100%";
  overlay.style.height = "100%";
  overlay.style.zIndex = "2";
  overlay.style.display = "block";

  // Ensure the container has position relative for proper overlay positioning
  container.style.position = "relative";

  // Set explicit z-index for video
  video.style.zIndex = "1";
}

function setupVideoInteractions(video, overlay, container, onPlayCallback) {
  // Handle overlay clicks
  overlay.addEventListener("click", function (e) {
    e.preventDefault();
    e.stopPropagation();

    if (video.paused) {
      playVideo(video, overlay, container, onPlayCallback);
    }

    return false;
  });

  // Handle video clicks with proper event capturing
  video.addEventListener("click", function (e) {
    // Prevent default behavior
    e.preventDefault();
    e.stopPropagation();

    if (video.paused) {
      playVideo(video, overlay, container, onPlayCallback);
    } else {
      pauseVideo(video, overlay, container);
    }

    return false;
  });

  // Listen for video state changes
  video.addEventListener("play", function () {
    overlay.style.display = "none";
    container.classList.remove("paused");
  });

  video.addEventListener("pause", function () {
    overlay.style.display = "block";
    container.classList.add("paused");
  });

  // Handle end of video
  video.addEventListener("ended", function () {
    if (!video.loop) {
      pauseVideo(video, overlay, container);
    }
  });
}

// Helper function to play video
function playVideo(video, overlay, container, callback) {
  try {
    const playPromise = video.play();

    if (playPromise !== undefined) {
      playPromise
        .then((_) => {
          // Playback started successfully
          // Show pause icon and immediately begin fading out over 2 seconds
          overlay.style.display = "block";
          overlay.innerHTML = '<div class="pause-icon">❚ ❚</div>';
          container.classList.remove("paused");
          container.classList.add("playing");

          // Clear any existing timeout
          if (container._fadeTimeout) {
            clearTimeout(container._fadeTimeout);
          }

          // Start with full opacity
          overlay.style.opacity = "1";

          // Set transition to fade out over 2 seconds
          overlay.style.transition = "opacity 2s ease";

          // Start the fade immediately
          requestAnimationFrame(() => {
            overlay.style.opacity = "0";
          });

          // After transition completes, hide the element
          container._fadeTimeout = setTimeout(() => {
            overlay.style.display = "none";
            // Reset for future use
            overlay.style.transition = "";
            overlay.style.opacity = "1";
          }, 2000); // Wait for the 2s transition to complete

          if (callback) callback();
        })
        .catch((error) => {
          // Playback failed - keep overlay visible
          overlay.style.display = "block";
          container.classList.add("paused");
          container.classList.remove("playing");
        });
    }
  } catch (e) {
    // Error handling without logging
  }
}

// Helper function to pause video
function pauseVideo(video, overlay, container) {
  video.pause();
  // Clear any fade timeout
  if (container._fadeTimeout) {
    clearTimeout(container._fadeTimeout);
    container._fadeTimeout = null;
  }

  // Reset overlay to show play button
  overlay.innerHTML = ""; // Remove any pause icon
  overlay.style.transition = "";
  overlay.style.opacity = "1";
  overlay.style.display = "block";
  container.classList.add("paused");
  container.classList.remove("playing");
}

// Function to create a poster image from the video if one doesn't exist
function createPosterFromVideo(video) {
  // Check if video has a source
  if (!video.querySelector("source") || !video.querySelector("source").src) {
    return;
  }

  // Extract path from video source and try to guess a corresponding image
  const videoSrc = video.querySelector("source").src;
  const possiblePosterPath =
    videoSrc.substring(0, videoSrc.lastIndexOf(".")) + ".jpg";

  // Try to set this as poster
  const img = new Image();
  img.onload = function () {
    // Image exists, set as poster
    video.setAttribute("poster", possiblePosterPath);
  };
  img.onerror = function () {
    // If image doesn't exist, try to create one from video
    video.addEventListener(
      "loadeddata",
      function () {
        if (video.readyState >= 2) {
          // Create a canvas to capture the video frame
          const canvas = document.createElement("canvas");
          canvas.width = video.videoWidth;
          canvas.height = video.videoHeight;
          const ctx = canvas.getContext("2d");

          // Draw the video frame
          ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

          // Set the canvas data as the poster
          try {
            const dataURL = canvas.toDataURL("image/jpeg");
            video.setAttribute("poster", dataURL);
          } catch (e) {
            // Error handling without logging
          }
        }
      },
      { once: true },
    );

    // Try to load some video data to generate the poster
    video.preload = "metadata";
    video.load();
  };
  img.src = possiblePosterPath;
}

// Add a class to the document to help with browser-specific styling
document.addEventListener("DOMContentLoaded", function () {
  // Detect Safari
  if (/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) {
    document.documentElement.classList.add("safari");
  }

  // Add global click handler outside videos to pause any playing video
  document.addEventListener("click", function (e) {
    // If click is outside a video or overlay
    if (
      !e.target.closest(".video-container") &&
      !e.target.matches("video") &&
      !e.target.matches(".overlay")
    ) {
      // Find any playing videos and pause them
      const videos = document.querySelectorAll("video");
      videos.forEach((video) => {
        if (!video.paused && !video.ended) {
          const container = video.closest(".video-container");
          const overlay = container.querySelector(".overlay");
          pauseVideo(video, overlay, container);
        }
      });
    }
  });
});

// This code was moved from the HTML files to ensure overlays are always visible
document.addEventListener("DOMContentLoaded", function () {
  setTimeout(function () {
    document
      .querySelectorAll(".video-container .overlay")
      .forEach((overlay) => {
        overlay.style.display = "block";
        overlay.style.opacity = "1";
      });
  }, 500);
});

// Add styles for pause icon to the document
document.addEventListener("DOMContentLoaded", function () {
  // Add the CSS for the pause icon
  const style = document.createElement("style");
  style.textContent = `
        .video-container .overlay .pause-icon {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background-color: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 3rem;
            opacity: 0.8;
        }
        
        /* Make sure the overlay can be visible for the pause state */
        .video-container.playing .overlay {
            pointer-events: none;
            background-color: rgba(0, 0, 0, 0.2);
        }
    `;
  document.head.appendChild(style);

  // Detect Safari
  if (/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) {
    document.documentElement.classList.add("safari");
  }

  // Add global click handler outside videos to pause any playing video
  document.addEventListener("click", function (e) {
    // If click is outside a video or overlay
    if (
      !e.target.closest(".video-container") &&
      !e.target.matches("video") &&
      !e.target.matches(".overlay")
    ) {
      // Find any playing videos and pause them
      const videos = document.querySelectorAll("video");
      videos.forEach((video) => {
        if (!video.paused && !video.ended) {
          const container = video.closest(".video-container");
          const overlay = container.querySelector(".overlay");
          pauseVideo(video, overlay, container);
        }
      });
    }
  });
});
