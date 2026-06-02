// Global variables
let currentCategory = "all";
let categoriesData = {};
let itemsByCategory = {};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Close button
    document.getElementById('closeBtn').addEventListener('click', function() {
        closeMenu();
        playSound('close');
    });

    // Initial loading state
    showLoadingState();
});

// Function to show loading state
function showLoadingState() {
    document.getElementById('currentCategoryTitle').innerHTML = '<i class="fas fa-spinner fa-spin"></i> Loading...';
    document.getElementById('currentCategoryDescription').textContent = 'Loading blackmarket data...';
}

// Function to generate category tabs
function generateCategoryTabs(categories, defaultCategory) {
    const tabsContainer = document.getElementById('categoryTabs');
    tabsContainer.innerHTML = '';
    
    // Add "All" tab first
    const allTab = document.createElement('button');
    allTab.className = 'category-tab active';
    allTab.setAttribute('data-category', 'all');
    allTab.innerHTML = `
        <i class="fas fa-store"></i>
        <span class="tab-name">All</span>
    `;
    allTab.addEventListener('click', function() {
        switchCategory('all');
    });
    tabsContainer.appendChild(allTab);
    
    // Add category tabs
    categories.forEach(category => {
        const tab = document.createElement('button');
        tab.className = 'category-tab';
        tab.setAttribute('data-category', category.id);
        tab.innerHTML = `
            <i class="fas ${category.icon}"></i>
            <span class="tab-name">${category.name}</span>
        `;
        tab.addEventListener('click', function() {
            switchCategory(category.id);
        });
        tabsContainer.appendChild(tab);
    });
    
    // Set default category
    if (defaultCategory && itemsByCategory[defaultCategory]) {
        setTimeout(() => {
            switchCategory(defaultCategory);
        }, 100);
    } else {
        switchCategory('all');
    }
}

// Function to switch category
function switchCategory(categoryId) {
    if (!itemsByCategory[categoryId]) {
        console.error('Category not found:', categoryId);
        return;
    }
    
    // Update current category
    currentCategory = categoryId;
    
    // Update active tab
    document.querySelectorAll('.category-tab').forEach(tab => {
        tab.classList.remove('active');
        if (tab.getAttribute('data-category') === categoryId) {
            tab.classList.add('active');
        }
    });
    
    // Update category header
    const categoryData = itemsByCategory[categoryId];
    document.getElementById('currentCategoryTitle').innerHTML = `
        <i class="fas ${categoryData.icon}"></i> ${categoryData.name}
    `;
    document.getElementById('currentCategoryDescription').textContent = categoryData.description;
    
    // Generate items for this category
    generateItemCards(categoryData.items);
    
    // Update item counter
    document.getElementById('itemCounter').innerHTML = `
        <span class="counter-text">${categoryData.items.length} items</span>
    `;
    
    // Notify server (optional)
    fetch(`https://${GetParentResourceName()}/changeCategory`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            category: categoryId
        })
    });
}

// Function to generate item cards
function generateItemCards(items) {
    const grid = document.getElementById('itemsGrid');
    const loading = document.getElementById('itemsLoading');
    
    if (!grid) return;
    
    // Hide loading message
    if (loading) {
        loading.style.display = 'none';
    }
    
    // Clear and regenerate content
    grid.innerHTML = '';
    
    if (!items || items.length === 0) {
        grid.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-ban fa-3x"></i>
                <h3>No items available</h3>
                <p>This category is currently empty</p>
            </div>
        `;
        return;
    }
    
    items.forEach(item => {
        createItemCard(grid, item);
    });
    
    // Reattach purchase events
    attachBuyEvents();
}

// Function to create individual item card
function createItemCard(grid, item) {
    const card = document.createElement('div');
    card.className = 'item-card';
    
    // Determine icon based on item type
    let icon = 'fa-box';
    let typeClass = 'item-type-item';
    
    if (item.itemType === 'weapon') {
        icon = 'fa-gun';
        typeClass = 'item-type-weapon';
    } else if (item.id.includes('lockpick') || item.id.includes('drill')) {
        icon = 'fa-tools';
    } else if (item.id.includes('bandage') || item.id.includes('medkit')) {
        icon = 'fa-first-aid';
    } else if (item.id.includes('armor')) {
        icon = 'fa-shield-alt';
    }
    
    card.innerHTML = `
        <div class="item-header">
            <div class="item-type ${typeClass}">
                <i class="fas ${icon}"></i>
                <span>${item.itemType === 'weapon' ? 'WEAPON' : 'ITEM'}</span>
            </div>
            ${item.category ? `<div class="item-category">${getCategoryName(item.category)}</div>` : ''}
        </div>
        <div class="item-image">
            <img src="${item.image}" alt="${item.name}" 
                 onerror="this.onerror=null; this.src='https://via.placeholder.com/300x150/0a0f1e/00f0ff?text=${encodeURIComponent(item.name)}'">
        </div>
        <div class="item-info">
            <h3 class="item-name">${item.name}</h3>
            <p class="item-description">${item.description}</p>
            <div class="item-stats">
                ${item.itemType === 'weapon' ? 
                    `<span class="stat weapon-stat"><i class="fas fa-bullseye"></i> ${item.ammo || 0} rounds</span>` : 
                    `<span class="stat item-stat"><i class="fas fa-cube"></i> ${item.stack || 1} stack</span>`
                }
                <span class="stat price-stat"><i class="fas fa-money-bill-wave"></i> $${item.price.toLocaleString()}</span>
            </div>
            <button class="buy-btn" data-id="${item.id}">
                <i class="fas fa-shopping-cart"></i> BUY NOW
            </button>
        </div>
    `;
    grid.appendChild(card);
}

// Helper function to get category name
function getCategoryName(categoryId) {
    if (categoryId === 'all') return 'ALL';
    if (categoriesData[categoryId]) return categoriesData[categoryId].name.toUpperCase();
    return categoryId.toUpperCase();
}

// Function to attach purchase events
function attachBuyEvents() {
    document.querySelectorAll('.buy-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const itemId = this.getAttribute('data-id');
            purchaseItem(itemId);
        });
    });
}

// Function to purchase an item
function purchaseItem(itemId) {
    playSound('click');
    
    fetch(`https://${GetParentResourceName()}/purchase`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            id: itemId
        })
    })
    .then(response => response.json())
    .then(data => {
        console.log('Purchase response:', data);
    })
    .catch(error => {
        console.error('Purchase error:', error);
    });
}

// Function to play a sound
function playSound(soundName) {
    const sound = document.getElementById(soundName + 'Sound');
    if (sound) {
        sound.currentTime = 0;
        sound.play().catch(e => console.log("Sound play failed:", e));
    }
}

// Function to close the menu
function closeMenu() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        console.log('Menu closed');
    })
    .catch(error => {
        console.error('Close error:', error);
    });
}

// NUI message listener from Lua client
window.addEventListener('message', function(event) {
    const action = event.data.action;

    switch(action) {
        case 'open':
            document.body.style.display = 'flex';
            document.body.classList.add('active');
            
            // Store categories and items data
            if (event.data.categories) {
                // Convert categories array to object for easy lookup
                event.data.categories.forEach(cat => {
                    categoriesData[cat.id] = cat;
                });
            }
            
            if (event.data.itemsByCategory) {
                itemsByCategory = event.data.itemsByCategory;
                
                // Generate category tabs
                generateCategoryTabs(event.data.categories || [], event.data.defaultCategory);
            }

            // Dynamic UI customization
            if (event.data.uiTitle) {
                document.title = event.data.uiTitle;
                const words = event.data.uiTitle.split(' ');
                if (words.length > 1) {
                    const firstPart = words.slice(0, -1).join(' ');
                    const lastWord = words[words.length - 1];
                    const logoTextEl = document.getElementById('logoText');
                    if (logoTextEl) {
                        logoTextEl.innerHTML = `${firstPart} <span class="logo-accent">${lastWord}</span>`;
                    }
                } else {
                    const logoTextEl = document.getElementById('logoText');
                    if (logoTextEl) {
                        logoTextEl.textContent = event.data.uiTitle;
                    }
                }
            }
            if (event.data.uiLogoIcon) {
                const logoIcon = document.getElementById('logoIcon');
                const logoImage = document.getElementById('logoImage');
                
                // If it looks like a FontAwesome icon
                if (event.data.uiLogoIcon.indexOf('fa-') === 0) {
                    if (logoIcon && logoImage) {
                        logoIcon.className = `fas ${event.data.uiLogoIcon} logo-icon`;
                        logoIcon.style.display = 'block';
                        logoImage.style.display = 'none';
                    }
                } else {
                    // It's an image source path
                    if (logoIcon && logoImage) {
                        logoImage.src = event.data.uiLogoIcon;
                        logoImage.style.display = 'block';
                        logoIcon.style.display = 'none';
                    }
                }
            }
            if (event.data.uiWarning) {
                const warningText = document.getElementById('warningText');
                if (warningText) {
                    warningText.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ${event.data.uiWarning}`;
                }
            }
            if (event.data.uiCopyright) {
                const copyrightText = document.getElementById('copyrightText');
                if (copyrightText) {
                    copyrightText.textContent = event.data.uiCopyright;
                }
            }
            break;

        case 'close':
            document.body.style.display = 'none';
            document.body.classList.remove('active');
            
            // Reset state
            resetUIState();
            break;

        case 'playSound':
            playSound(event.data.sound);
            break;
    }
});

// Function to reset UI state
function resetUIState() {
    currentCategory = "all";
    categoriesData = {};
    itemsByCategory = {};
    
    document.getElementById('categoryTabs').innerHTML = `
        <div class="loading-tabs">
            <i class="fas fa-spinner fa-spin"></i> Loading categories...
        </div>
    `;
    
    document.getElementById('itemsGrid').innerHTML = `
        <div class="loading" id="itemsLoading">
            <div class="loading-spinner">
                <i class="fas fa-spinner fa-spin fa-3x"></i>
            </div>
            <p class="loading-text">Loading Items...</p>
            <p class="loading-subtext">Please select a category</p>
        </div>
    `;
    
    document.getElementById('currentCategoryTitle').innerHTML = '<i class="fas fa-store"></i> All Items';
    document.getElementById('currentCategoryDescription').textContent = 'All available items in the blackmarket';
    document.getElementById('itemCounter').innerHTML = '<span class="counter-text">0 items</span>';
}

// ESC key fallback
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});