async function generatePortfolioCards() {
  try {
    console.log("Fetching portfolio data...");

    // Use a static JSON file instead of an API
    const response = await fetch(
      "/data/portfolio-items.json?v=" + new Date().getTime(),
    );

    if (!response.ok) {
      throw new Error(`Failed to load portfolio data: ${response.status}`);
    }

    const portfolioSections = await response.json();
    console.log(`Found ${portfolioSections.length} portfolio items`);

    const cardsContainer = document.querySelector(".cards.staggered-animation");
    if (!cardsContainer) {
      throw new Error("Container element not found");
    }

    // Create cards
    const cards = portfolioSections.map((section) => {
      const card = document.createElement("a");
      card.className = "card";
      card.href = section.path;

      card.innerHTML = `
                <div class="card--details">
                    <h2>${section.title}</h2>
                    <div class="card--company-logo">
                        <img src="/assets/images/portfolio/company-logo-${section.company}.svg?v=20250323-0616" alt="Company logo">
                    </div>
                </div>
                <picture>
                    <source srcset="${section.imageBase}-320w.webp 320w, ${section.imageBase}-640w.webp 640w, ${section.imageBase}-960w.webp 960w, ${section.imageBase}-1200w.webp 1200w, ${section.imageBase}-1800w.webp 1800w" type="image/webp" />
                    <img src="${section.imageBase}.png" 
                         alt="${section.description || ""}" 
                         width="1200" 
                         height="648" 
                         loading="lazy" 
                         srcset="${section.imageBase}-320w.png 320w, ${section.imageBase}-640w.png 640w, ${section.imageBase}-960w.png 960w, ${section.imageBase}-1200w.png 1200w, ${section.imageBase}-1800w.png 1800w"
                         sizes="(max-width: 1200px) 100vw, 1200px" />
                </picture>
            `;
      return card;
    });

    // Clear container and add new cards
    cardsContainer.innerHTML = "";
    cardsContainer.append(...cards);

    console.log("Portfolio cards generated successfully");
  } catch (error) {
    console.error("Error loading portfolio data:", error);
    const container = document.querySelector(".cards.staggered-animation");
    if (container) {
      container.innerHTML = `
                <div class="error-message" style="padding: 2rem; text-align: center; width: 100%;">
                    <h2>Failed to load portfolio data</h2>
                    <p>${error.message}</p>
                </div>
            `;
    }
  }
}

document.addEventListener("DOMContentLoaded", generatePortfolioCards);
