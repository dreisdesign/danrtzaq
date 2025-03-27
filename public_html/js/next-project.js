async function generateNextProjectCard() {
  try {
    // Get current path to look up the next project
    const currentPath = window.location.pathname.replace(/\/$/, "/");

    // Fetch the next project mapping
    const response = await fetch(
      "/data/next-project.json?v=" + new Date().getTime(),
    );

    if (!response.ok) {
      throw new Error(`Failed to load next project data: ${response.status}`);
    }

    const nextProjectMap = await response.json();

    // Find the next project for this page
    const nextProject = nextProjectMap[currentPath];
    if (!nextProject) {
      console.warn("No next project defined for", currentPath);
      return;
    }

    // Find the container for the next project card
    const container = document.querySelector(".next-project-container");
    if (!container) return;

    // Create the card HTML
    const nextProjectHTML = `
        <div class="cards">
            <a class="card" href="${nextProject.path}">
                <div class="card--details">
                    <p><strong>Up Next</strong></p>
                    <h2>${nextProject.title}</h2>
                    <div class="card--company-logo">
                        <img src="/assets/images/portfolio/company-logo-${nextProject.company}.svg?v=20250326-1159" alt="Company logo">
                    </div>
                </div>
                <picture>
                    <source srcset="${nextProject.imageBase}-320w.webp 320w, ${nextProject.imageBase}-640w.webp 640w, ${nextProject.imageBase}-960w.webp 960w, ${nextProject.imageBase}-1200w.webp 1200w, ${nextProject.imageBase}-1800w.webp 1800w" type="image/webp" />
                    <img 
                        id="featured--image_preview"
                        src="${nextProject.imageBase}.png"
                        alt="Preview of ${nextProject.title}"
                        loading="lazy"
                        width="1880"
                        height="1000"
                        srcset="${nextProject.imageBase}-320w.png 320w, ${nextProject.imageBase}-640w.png 640w, ${nextProject.imageBase}-960w.png 960w, ${nextProject.imageBase}-1200w.png 1200w, ${nextProject.imageBase}-1800w.png 1800w"
                        sizes="(max-width: 1200px) 100vw, 1200px"
                    />
                </picture>
            </a>
        </div>
        `;

    // Insert the card
    container.innerHTML = nextProjectHTML;
  } catch (error) {
    console.error("Error generating next project card:", error);
  }
}

document.addEventListener("DOMContentLoaded", generateNextProjectCard);
