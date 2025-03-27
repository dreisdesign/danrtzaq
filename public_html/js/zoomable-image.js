// zoomable-image-single-step.js?v=1.0.0

document.addEventListener("DOMContentLoaded", function () {
  // Function to check if element is inside link tag
  function isInsideLink(element) {
    let parent = element.parentElement;
    while (parent) {
      if (parent.tagName === "A") {
        return true;
      }
      parent = parent.parentElement;
    }
    return false;
  }

  // First add class to all picture images that are not inside links
  document.querySelectorAll("picture img").forEach((img) => {
    if (!img.classList.contains("zoomable-image") && !isInsideLink(img)) {
      img.classList.add("zoomable-image");
      img.setAttribute("title", "Click to zoom");
    }
  });

  const zoomableImages = document.querySelectorAll(".zoomable-image");
  let zoomLevel = 0;
  let overlay, closeButton;

  function getLargestImage(img) {
    // Try to get base image URL without size suffix
    const basePath = img.src.replace(/-\d+w\.(jpe?g|png|webp)/, ".$1");

    // Try formats in order of preference (original, png, jpg, webp)
    const formats = [
      basePath,
      basePath.replace(/\.(jpe?g|png|webp)$/, ".png"),
      basePath.replace(/\.(jpe?g|png|webp)$/, ".jpg"),
      basePath.replace(/\.(jpe?g|png|webp)$/, ".webp"),
    ];

    // Try each format
    for (const path of formats) {
      const testImg = new Image();
      testImg.src = path;
      if (testImg.complete) {
        return path;
      }
    }

    // If no higher quality version found, use original src
    return img.src;
  }

  function disableScroll() {
    document.body.style.overflow = "hidden";
    document.body.style.paddingRight = getScrollbarWidth() + "px";
  }

  function enableScroll() {
    document.body.style.overflow = "";
    document.body.style.paddingRight = "";
  }

  function getScrollbarWidth() {
    return window.innerWidth - document.documentElement.clientWidth;
  }

  function cleanupExistingOverlays() {
    const existingOverlays = document.querySelectorAll(
      ".zoomable-image-overlay",
    );
    const existingCloseButtons = document.querySelectorAll(
      ".zoomable-image-close",
    );

    existingOverlays.forEach((overlay) => {
      overlay.classList.add("closing");
      setTimeout(() => overlay.remove(), 200);
    });
    existingCloseButtons.forEach((button) => button.remove());
    enableScroll();

    // Clean up any text nodes that might have been accidentally created
    document.body.childNodes.forEach((node) => {
      if (
        node.nodeType === Node.TEXT_NODE &&
        node.textContent.includes("zoomable-image")
      ) {
        node.remove();
      }
    });
  }

  zoomableImages.forEach((img) => {
    let currentScale = 1;
    let translateX = 0,
      translateY = 0;
    let isDragging = false;
    let startX, startY;
    let zoomedImg = null;
    let hasMoved = false;

    img.addEventListener("click", function () {
      if (zoomLevel === 0) {
        initializeZoom();
      }
    });

    function handleZoom(e) {
      if (!isDragging && !hasMoved) {
        e.stopPropagation();
        if (currentScale === 1) {
          currentScale = 2;
          zoomedImg.style.cursor = "grab";
        } else {
          currentScale = 1;
          translateX = translateY = 0;
          zoomedImg.style.cursor = "zoom-in";
        }
        zoomedImg.style.transition = "transform 0.3s ease";
        updateTransform();
        setTimeout(() => {
          zoomedImg.style.transition = "none";
        }, 300);
      }
      hasMoved = false; // Reset move state after handling click
    }

    function initializeZoom() {
      cleanupExistingOverlays();
      disableScroll();

      overlay = document.createElement("div");
      overlay.className = "zoomable-image-overlay";
      document.body.appendChild(overlay);

      // Add overlay click handler
      overlay.addEventListener("click", (e) => {
        if (e.target === overlay && !isDragging && !hasMoved) {
          resetZoom();
        }
      });

      // Add close button
      closeButton = document.createElement("button");
      closeButton.innerHTML = "×";
      closeButton.className = "zoomable-image-close";
      document.body.appendChild(closeButton);
      closeButton.addEventListener("click", resetZoom);

      const highResSrc = getLargestImage(img);
      zoomedImg = new Image(); // Assign to outer scope variable
      zoomedImg.src = highResSrc;
      zoomedImg.className = "zoomable-image zoomed-in";
      zoomedImg.alt = img.alt;

      overlay.appendChild(zoomedImg);
      zoomLevel = 1;

      // Add click handler to zoomed image
      zoomedImg.addEventListener("click", handleZoom);
      setupPanning(zoomedImg);
    }

    function setupPanning(zoomedImg) {
      function constrainPan(x, y) {
        const rect = zoomedImg.getBoundingClientRect();
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;

        // Calculate how much of the image should remain visible
        const minVisiblePx = 100; // minimum pixels that should remain visible

        // Calculate bounds
        const maxX = (rect.width * currentScale - viewportWidth) / 2;
        const maxY = (rect.height * currentScale - viewportHeight) / 2;

        return {
          x: Math.max(Math.min(x, maxX + minVisiblePx), -maxX - minVisiblePx),
          y: Math.max(Math.min(y, maxY + minVisiblePx), -maxY - minVisiblePx),
        };
      }

      function snapToEdge() {
        const rect = zoomedImg.getBoundingClientRect();
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;
        const margin = 50; // margin from edges

        let newX = translateX;
        let newY = translateY;

        // Snap horizontally with margin
        if (rect.left > margin) {
          newX -= rect.left - margin;
        } else if (rect.right < viewportWidth - margin) {
          newX += viewportWidth - margin - rect.right;
        }

        // Snap vertically with margin
        if (rect.top > margin) {
          newY -= rect.top - margin;
        } else if (rect.bottom < viewportHeight - margin) {
          newY += viewportHeight - margin - rect.bottom;
        }

        if (newX !== translateX || newY !== translateY) {
          zoomedImg.style.transition = "transform 0.3s ease-out";
          translateX = newX;
          translateY = newY;
          updateTransform();
          setTimeout(() => {
            zoomedImg.style.transition = "none";
          }, 300);
        }
      }

      function startDragging(e) {
        if (currentScale > 1) {
          isDragging = true;
          hasMoved = false;
          startX = e.clientX - translateX;
          startY = e.clientY - translateY;
          zoomedImg.style.cursor = "grabbing";
          e.preventDefault();
        }
      }

      function drag(e) {
        if (!isDragging) return;
        e.preventDefault();
        hasMoved = true;

        const newX = e.clientX - startX;
        const newY = e.clientY - startY;
        const constrained = constrainPan(newX, newY);

        translateX = constrained.x;
        translateY = constrained.y;
        updateTransform();
      }

      function stopDragging(e) {
        if (!isDragging) return;
        isDragging = false;
        zoomedImg.style.cursor = "grab";
        if (hasMoved) {
          snapToEdge();
        }
        e.stopPropagation();
      }

      zoomedImg.addEventListener("mousedown", startDragging);
      overlay.addEventListener("mousemove", drag);
      overlay.addEventListener("mouseup", stopDragging);
      overlay.addEventListener("mouseleave", stopDragging);
      zoomedImg.addEventListener("click", handleZoom);
    }

    function calculateBounds(zoomedImg) {
      const rect = zoomedImg.getBoundingClientRect();
      const viewportWidth = window.innerWidth;
      const viewportHeight = window.innerHeight;

      // Calculate maximum translation based on image and viewport size
      const maxX = (rect.width * currentScale - viewportWidth) / 2;
      const maxY = (rect.height * currentScale - viewportHeight) / 2;

      return { maxX, maxY };
    }

    function updateTransform() {
      const transform = `translate(-50%, -50%) translate(${translateX}px, ${translateY}px) scale(${currentScale})`;
      zoomedImg.style.transform = transform;
    }

    img.addEventListener("mouseover", function () {
      if (zoomLevel === 0) {
        img.style.cursor = "zoom-in";
      }
    });

    img.addEventListener("mouseout", function () {
      if (zoomLevel === 0) {
        img.style.cursor = "";
      }
    });

    function resetZoom() {
      const overlay = document.querySelector(".zoomable-image-overlay");
      const closeButton = document.querySelector(".zoomable-image-close");

      if (overlay) {
        overlay.classList.add("closing");
        setTimeout(() => overlay.remove(), 200);
      }
      if (closeButton) {
        closeButton.remove();
      }

      enableScroll();
      zoomLevel = 0;
      currentScale = 1;
      translateX = 0;
      translateY = 0;
      zoomedImg = null;
      img.style.cursor = "zoom-in";
    }
  });

  // Add error handling to all images
  const images = document.querySelectorAll("img");
  images.forEach(handleImageError);
});

function handleZoomClick(e) {
  e.stopPropagation();
  if (currentScale === 1) {
    currentScale = 2;
    zoomedImg.style.cursor = "grab";
    updateTransform();
  }
}

function handleImageError(img) {
  img.onerror = function () {
    console.error("Failed to load image:", img.src);
    img.classList.add("image-load-error");

    // Try alternate path if current path starts with /assets
    if (img.src.includes("/assets/")) {
      const altPath = img.src.replace("/assets/", "/");
      console.log("Trying alternate path:", altPath);
      img.src = altPath;
    }
  };
}
