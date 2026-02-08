package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

// ==================== MODE DETERMINATION ====================

// getCurrentMode determines which UI mode to show based on time and user behavior
func getCurrentMode() string {
	hour := time.Now().Hour()
	// Time-based modes
	switch {
	case hour >= 0 && hour < 6:
		return "late_night" // 12AM - 6AM: Minimal midnight browsing
	case hour >= 6 && hour < 9:
		return "morning" // 6AM - 9AM: Morning deals
	case hour >= 9 && hour < 12:
		return "day" // 9AM - 12PM: Standard shopping
	case hour >= 12 && hour < 14:
		return "flash_sale" // 12PM - 2PM: Lunch hour flash sale
	case hour >= 14 && hour < 17:
		return "afternoon" // 2PM - 5PM: Productive browsing
	case hour >= 17 && hour < 20:
		return "evening" // 5PM - 8PM: Evening collections
	case hour >= 20 && hour < 24:
		return "night" // 8PM - 12AM: Night boutique
	default:
		return "day"
	}
}

// ==================== UI CONFIG HANDLER ====================

func handleUiConfig(w http.ResponseWriter, r *http.Request) {
	screen := r.URL.Query().Get("screen")
	if screen == "" {
		screen = "/"
	}

	userId := r.Header.Get("X-User-ID")
	mode := "night"

	log.Printf("🎨 UI Config Request - screen='%s', mode='%s', user='%s'", screen, mode, userId)

	var config interface{}

	switch screen {
	case "/", "home":
		config = getHomeScreenConfig(mode, userId)
	case "/product":
		productID := r.URL.Query().Get("id")
		config = getProductScreenConfig(mode, productID)
	case "/cart":
		config = getCartScreenConfig(mode)
	case "/profile":
		config = getProfileScreenConfig(mode)
	case "/search":
		config = getSearchScreenConfig(mode)
	case "/favorites":
		config = getFavoritesScreenConfig(mode)
	default:
		config = getHomeScreenConfig(mode, userId)
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("X-UI-Mode", mode)
	w.Header().Set("X-Generated-At", time.Now().Format(time.RFC3339))
	w.Header().Set("Access-Control-Allow-Origin", "*")

	json.NewEncoder(w).Encode(config)
}

// ==================== NAVIGATION STATE MANAGEMENT ====================

func getNavigationConfig(screen string, mode string) map[string]interface{} {
	// Define all navigation items with their base configuration
	allNavItems := []map[string]interface{}{
		{"id": "nav-home", "label": "Home", "icon": "home", "route": "/"},
		{"id": "nav-search", "label": "Search", "icon": "search", "route": "/search"},
		{"id": "nav-cart", "label": "Cart", "icon": "cart", "route": "/cart"},
		{"id": "nav-favorites", "label": "Favorites", "icon": "favorite", "route": "/favorites"},
		{"id": "nav-profile", "label": "Profile", "icon": "person", "route": "/profile"},
	}

	// Determine which nav items to show based on mode
	var navItems []interface{}

	switch mode {
	case "late_night":
		navItems = []interface{}{
			allNavItems[0], // Home
			allNavItems[4], // Profile
		}
	case "flash_sale":
		navItems = []interface{}{
			allNavItems[0], // Home (as Deals)
			allNavItems[2], // Cart
		}
	case "evening":
		navItems = []interface{}{
			allNavItems[0], // Home (as Discover)
			allNavItems[3], // Favorites (as Saved)
			allNavItems[4], // Profile (as You)
		}
	case "night":
		navItems = []interface{}{
			allNavItems[0], // Home
			allNavItems[1], // Search (as Explore)
			allNavItems[3], // Favorites
			allNavItems[4], // Profile (as You)
		}
	default:
		// Standard navigation for morning, afternoon, day
		navItems = []interface{}{
			allNavItems[0], // Home
			allNavItems[1], // Search
			allNavItems[2], // Cart
			allNavItems[4], // Profile
		}
	}

	// Update active state based on current screen
	for _, item := range navItems {
		navMap := item.(map[string]interface{})
		route := navMap["route"].(string)

		// Check if this is the active route
		isActive := (route == "/" && (screen == "/" || screen == "home")) ||
			(route == "/search" && screen == "/search") ||
			(route == "/cart" && screen == "/cart") ||
			(route == "/favorites" && screen == "/favorites") ||
			(route == "/profile" && screen == "/profile")

		// Update the map
		navMap["is_active"] = isActive

		// Special cases for different modes
		if mode == "flash_sale" && route == "/" {
			navMap["label"] = "Deals"
		}
		if mode == "evening" {
			if route == "/" {
				navMap["label"] = "Discover"
			}
			if route == "/favorites" {
				navMap["label"] = "Saved"
			}
			if route == "/profile" {
				navMap["label"] = "You"
			}
		}
		if mode == "night" && route == "/search" {
			navMap["label"] = "Explore"
		}
	}

	return map[string]interface{}{
		"bottom_nav":       navItems,
		"top_actions":      []interface{}{},
		"show_back_button": screen != "/" && screen != "home",
		"title":            getScreenTitle(screen),
	}
}

func getScreenTitle(screen string) string {
	switch screen {
	case "/", "home":
		return ""
	case "/search":
		return "Search"
	case "/cart":
		return "Cart"
	case "/favorites":
		return "Favorites"
	case "/profile":
		return "Profile"
	case "/product":
		return "Product Details"
	default:
		return ""
	}
}

// ==================== HOME SCREEN CONFIGS ====================

func getHomeScreenConfig(mode string, userId string) map[string]interface{} {
	switch mode {
	case "late_night":
		return getLateNightModeConfig()
	case "morning":
		return getMorningModeConfig()
	case "flash_sale":
		return getFlashSaleConfig()
	case "afternoon":
		return getAfternoonModeConfig()
	case "evening":
		return getEveningConfig()
	case "night":
		return getNightModeConfig()
	default:
		return getDayModeConfig()
	}
}

// 🌙 LATE NIGHT MODE (12AM - 6AM): Absolute Minimal
func getLateNightModeConfig() map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "home",
		"layout_type": "scroll",
		"theme": map[string]interface{}{
			"is_dark_mode":     true,
			"primary_color":    "#0A0A0A",
			"background_color": "#000000",
			"accent_color":     "#555555",
			"font_sizes": map[string]float64{
				"headline": 24.0,
				"title":    18.0,
				"body":     14.0,
				"caption":  11.0,
			},
			"border_radius": 8.0,
			"spacing": map[string]float64{
				"xs": 4.0,
				"sm": 8.0,
				"md": 16.0,
				"lg": 24.0,
				"xl": 32.0,
			},
		},
		"components": []interface{}{
			map[string]interface{}{
				"id":   "night-message",
				"type": "header",
				"props": map[string]interface{}{
					"title":     "Still browsing?",
					"subtitle":  "Here's what you might like",
					"alignment": "center",
					"showIcon":  true,
					"icon":      "star",
				},
				"style": map[string]interface{}{
					"padding":         24.0,
					"fontSize":        24.0,
					"color":           "#FFFFFF",
					"backgroundColor": "#1A1A1A",
					"borderRadius":    12.0,
				},
			},
			map[string]interface{}{
				"id":    "spacer",
				"type":  "spacer",
				"props": map[string]interface{}{"height": 20.0},
			},
			map[string]interface{}{
				"id":   "minimal-products",
				"type": "product_grid",
				"props": map[string]interface{}{
					"columns":     1,
					"spacing":     20.0,
					"aspectRatio": 1.5,
					"products":    getMidnightProducts(),
				},
				"style": map[string]interface{}{
					"imageHeight":  200.0,
					"borderRadius": 12.0,
					"showDiscount": false,
					"showRating":   false,
					"titleSize":    18.0,
					"priceSize":    20.0,
					"priceColor":   "#FFFFFF",
					"elevation":    1.0,
				},
			},
		},
		"navigation": getNavigationConfig("/", "late_night"),
		"metadata":   getMetadata("late_night"),
	}
}

// ☀️ MORNING MODE (6AM - 9AM): Fresh Start
func getMorningModeConfig() map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "home",
		"layout_type": "scroll",
		"theme": map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#FF9800",
			"background_color": "#FFFBF5",
			"accent_color":     "#FFC107",
			"font_sizes": map[string]float64{
				"headline": 34.0,
				"title":    20.0,
				"body":     16.0,
				"caption":  12.0,
			},
			"border_radius": 16.0,
			"spacing": map[string]float64{
				"xs": 4.0,
				"sm": 8.0,
				"md": 16.0,
				"lg": 24.0,
				"xl": 32.0,
			},
		},
		"components": []interface{}{
			map[string]interface{}{
				"id":   "morning-greeting",
				"type": "header",
				"props": map[string]interface{}{
					"title":     "Good Morning, People! ☀️",
					"subtitle":  "Start your day with great finds",
					"alignment": "left",
				},
				"style": map[string]interface{}{
					"padding":  20.0,
					"fontSize": 34.0,
					"color":    "#FF9800",
				},
			},
			map[string]interface{}{
				"id":   "search",
				"type": "search_bar",
				"props": map[string]interface{}{
					"placeholder": "What are you looking for?",
					"showFilter":  true,
				},
				"style": map[string]interface{}{
					"margin":          16.0,
					"backgroundColor": "#FFFFFF",
					"borderRadius":    12.0,
				},
			},
			map[string]interface{}{
				"id":   "morning-stories",
				"type": "story_circle",
				"props": map[string]interface{}{
					"stories": getMorningStories(),
				},
				"style": map[string]interface{}{
					"padding": 16.0,
				},
			},
			map[string]interface{}{
				"id":   "morning-deals",
				"type": "banner",
				"props": map[string]interface{}{
					"title":      "Early Bird Specials",
					"subtitle":   "Extra 15% off before 9 AM",
					"buttonText": "Shop Now",
					"height":     180.0,
				},
				"style": map[string]interface{}{
					"backgroundColor": "#FF9800",
					"borderRadius":    16.0,
					"margin":          16.0,
					"gradient": map[string]interface{}{
						"colors": []string{"#FF9800", "#FFC107"},
					},
				},
				"action": map[string]interface{}{
					"type":  "navigate",
					"route": "/deals",
				},
			},
			map[string]interface{}{
				"id":   "categories",
				"type": "category_chips",
				"props": map[string]interface{}{
					"categories": []interface{}{
						map[string]interface{}{"id": "1", "name": "New In"},
						map[string]interface{}{"id": "2", "name": "Trending"},
						map[string]interface{}{"id": "3", "name": "Sale"},
						map[string]interface{}{"id": "4", "name": "Premium"},
					},
					"selectedId": "1",
				},
				"style": map[string]interface{}{
					"padding":       16.0,
					"selectedColor": "#FF9800",
				},
			},
			map[string]interface{}{
				"id":   "featured-products",
				"type": "product_carousel",
				"props": map[string]interface{}{
					"products":  getMorningProducts(),
					"height":    320.0,
					"cardWidth": 200.0,
				},
				"style": map[string]interface{}{
					"padding":        16.0,
					"spacing":        12.0,
					"borderRadius":   12.0,
					"imageHeight":    180.0,
					"showDiscount":   true,
					"showRating":     true,
					"showFavorite":   true,
					"titleSize":      16.0,
					"priceSize":      18.0,
					"priceColor":     "#FF9800",
					"elevation":      2.0,
					"contentPadding": 12.0,
				},
			},
			map[string]interface{}{
				"id":   "review",
				"type": "testimonial_card",
				"props": map[string]interface{}{
					"name":     "Sarah M.",
					"subtitle": "Verified Buyer",
					"text":     "Love shopping here in the morning! The early bird deals are amazing and delivery is always on time.",
					"rating":   5.0,
				},
				"style": map[string]interface{}{
					"margin": 16.0,
				},
			},
		},
		"navigation": getNavigationConfig("/", "morning"),
		"metadata":   getMetadata("morning"),
	}
}

// 🔥 FLASH SALE MODE (12PM - 2PM): Maximum Urgency
func getFlashSaleConfig() map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "home",
		"layout_type": "scroll",
		"theme": map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#FF4757",
			"background_color": "#FFFFFF",
			"accent_color":     "#FF6B6B",
			"font_sizes": map[string]float64{
				"headline": 28.0,
				"title":    18.0,
				"body":     14.0,
				"caption":  11.0,
			},
			"border_radius": 8.0,
			"spacing": map[string]float64{
				"xs": 2.0,
				"sm": 4.0,
				"md": 8.0,
				"lg": 12.0,
				"xl": 16.0,
			},
		},
		"components": []interface{}{
			map[string]interface{}{
				"id":   "flash-countdown",
				"type": "countdown_timer",
				"props": map[string]interface{}{
					"label":    "⚡ FLASH SALE ENDS IN",
					"end_time": "1:47:23",
					"showIcon": true,
				},
				"style": map[string]interface{}{
					"backgroundColor": "#FF4757",
					"padding":         14.0,
					"borderRadius":    0.0,
					"fontSize":        18.0,
					"gradient": map[string]interface{}{
						"colors": []string{"#FF4757", "#FF6B6B"},
					},
				},
			},
			map[string]interface{}{
				"id":   "promo-row",
				"type": "row",
				"props": map[string]interface{}{
					"alignment": "spaceEvenly",
				},
				"style": map[string]interface{}{
					"padding": 12.0,
				},
				"children": []interface{}{
					map[string]interface{}{
						"id":   "badge1",
						"type": "promo_badge",
						"props": map[string]interface{}{
							"text": "UP TO 70% OFF",
						},
						"style": map[string]interface{}{
							"backgroundColor": "#FF4757",
							"paddingX":        16.0,
							"paddingY":        8.0,
							"borderRadius":    20.0,
							"fontSize":        12.0,
						},
					},
					map[string]interface{}{
						"id":   "badge2",
						"type": "promo_badge",
						"props": map[string]interface{}{
							"text": "FREE SHIPPING",
						},
						"style": map[string]interface{}{
							"backgroundColor": "#4CAF50",
							"paddingX":        16.0,
							"paddingY":        8.0,
							"borderRadius":    20.0,
							"fontSize":        12.0,
						},
					},
				},
			},
			map[string]interface{}{
				"id":   "flash-products",
				"type": "product_grid",
				"props": map[string]interface{}{
					"columns":     2,
					"spacing":     8.0,
					"aspectRatio": 0.68,
					"products":    getFlashSaleProducts(),
				},
				"style": map[string]interface{}{
					"imageHeight":    130.0,
					"borderRadius":   8.0,
					"showDiscount":   true,
					"showRating":     false,
					"showFavorite":   false,
					"titleSize":      13.0,
					"priceSize":      16.0,
					"priceColor":     "#FF4757",
					"elevation":      1.0,
					"contentPadding": 8.0,
				},
			},
			map[string]interface{}{
				"id":   "urgency",
				"type": "container",
				"style": map[string]interface{}{
					"backgroundColor": "#FFF3CD",
					"padding":         16.0,
					"margin":          8.0,
					"borderRadius":    8.0,
					"borderColor":     "#FFB800",
					"borderWidth":     2.0,
				},
				"children": []interface{}{
					map[string]interface{}{
						"id":   "urgency-text",
						"type": "header",
						"props": map[string]interface{}{
							"title":     "⚠️ Limited Stock!",
							"subtitle":  "Items selling fast. Don't miss out!",
							"alignment": "center",
						},
						"style": map[string]interface{}{
							"fontSize":     16.0,
							"color":        "#856404",
							"padding":      0.0,
							"subtitleSize": 13.0,
						},
					},
				},
			},
		},
		"navigation": getNavigationConfig("/", "flash_sale"),
		"metadata":   getMetadata("flash_sale"),
	}
}

// 🌆 AFTERNOON MODE (2PM - 5PM): Productive Discovery
func getAfternoonModeConfig() map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "home",
		"layout_type": "scroll",
		"theme": map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#00BCD4",
			"background_color": "#F0F8FF",
			"accent_color":     "#00ACC1",
			"font_sizes": map[string]float64{
				"headline": 30.0,
				"title":    19.0,
				"body":     15.0,
				"caption":  12.0,
			},
			"border_radius": 12.0,
			"spacing": map[string]float64{
				"xs": 4.0,
				"sm": 8.0,
				"md": 16.0,
				"lg": 24.0,
				"xl": 32.0,
			},
		},
		"components": []interface{}{
			map[string]interface{}{
				"id":   "afternoon-header",
				"type": "header",
				"props": map[string]interface{}{
					"title":     "Discover Something New",
					"subtitle":  "Curated picks just for you",
					"alignment": "left",
				},
				"style": map[string]interface{}{
					"padding":  18.0,
					"fontSize": 30.0,
					"color":    "#00BCD4",
				},
			},
			map[string]interface{}{
				"id":   "categories-horizontal",
				"type": "horizontal_list",
				"props": map[string]interface{}{
					"height":    140.0,
					"itemWidth": 130.0,
					"items": []interface{}{
						map[string]interface{}{
							"id":        "cat1",
							"title":     "Electronics",
							"image_url": "https://via.placeholder.com/130x100/00BCD4/FFFFFF?text=Electronics",
						},
						map[string]interface{}{
							"id":        "cat2",
							"title":     "Fashion",
							"image_url": "https://via.placeholder.com/130x100/00ACC1/FFFFFF?text=Fashion",
						},
						map[string]interface{}{
							"id":        "cat3",
							"title":     "Home",
							"image_url": "https://via.placeholder.com/130x100/0097A7/FFFFFF?text=Home",
						},
						map[string]interface{}{
							"id":        "cat4",
							"title":     "Sports",
							"image_url": "https://via.placeholder.com/130x100/00838F/FFFFFF?text=Sports",
						},
					},
				},
				"style": map[string]interface{}{
					"padding": 16.0,
					"spacing": 12.0,
				},
			},
			map[string]interface{}{
				"id":   "afternoon-banner",
				"type": "banner",
				"props": map[string]interface{}{
					"title":      "Midday Break Deals",
					"subtitle":   "Take a break, save big",
					"buttonText": "Browse Deals",
					"height":     200.0,
					"alignment":  "center",
				},
				"style": map[string]interface{}{
					"backgroundColor": "#00BCD4",
					"borderRadius":    14.0,
					"margin":          16.0,
				},
			},
			map[string]interface{}{
				"id":   "afternoon-products",
				"type": "product_grid",
				"props": map[string]interface{}{
					"columns":     2,
					"spacing":     14.0,
					"aspectRatio": 0.75,
					"products":    getAfternoonProducts(),
				},
				"style": map[string]interface{}{
					"imageHeight":    200.0,
					"borderRadius":   12.0,
					"showDiscount":   true,
					"showRating":     true,
					"showFavorite":   true,
					"titleSize":      17.0,
					"priceSize":      19.0,
					"priceColor":     "#00BCD4",
					"elevation":      2.0,
					"contentPadding": 12.0,
				},
			},
		},
		"navigation": getNavigationConfig("/", "afternoon"),
		"metadata":   getMetadata("afternoon"),
	}
}

// 🌙 EVENING MODE (5PM - 8PM): Curated Premium
func getEveningConfig() map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "home",
		"layout_type": "scroll",
		"theme": map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#6C5CE7",
			"background_color": "#FAF9F6",
			"accent_color":     "#A29BFE",
			"font_sizes": map[string]float64{
				"headline": 36.0,
				"title":    22.0,
				"body":     17.0,
				"caption":  13.0,
			},
			"border_radius": 16.0,
			"spacing": map[string]float64{
				"xs": 4.0,
				"sm": 8.0,
				"md": 18.0,
				"lg": 28.0,
				"xl": 40.0,
			},
		},
		"components": []interface{}{
			map[string]interface{}{
				"id":   "evening-header",
				"type": "header",
				"props": map[string]interface{}{
					"title":     "Evening Selections",
					"subtitle":  "Curated with care for tonight",
					"alignment": "center",
					"showIcon":  true,
					"icon":      "star",
				},
				"style": map[string]interface{}{
					"padding":         20.0,
					"fontSize":        36.0,
					"color":           "#6C5CE7",
					"subtitleSize":    18.0,
					"subtitleColor":   "#A29BFE",
					"subtitleSpacing": 10.0,
					"iconSize":        32.0,
					"letterSpacing":   0.5,
				},
			},
			map[string]interface{}{
				"id":   "evening-banner",
				"type": "animated_banner",
				"props": map[string]interface{}{
					"title":      "Sunset Collection",
					"subtitle":   "Premium pieces for your evening",
					"buttonText": "Explore",
					"height":     300.0,
					"duration":   1000,
				},
				"style": map[string]interface{}{
					"backgroundColor": "#6C5CE7",
					"borderRadius":    18.0,
					"margin":          20.0,
					"titleSize":       32.0,
					"subtitleSize":    18.0,
					"gradient": map[string]interface{}{
						"colors": []string{"#6C5CE7", "#A29BFE"},
					},
				},
			},
			map[string]interface{}{
				"id":   "featured-carousel",
				"type": "product_carousel",
				"props": map[string]interface{}{
					"products":  getEveningProducts(),
					"height":    350.0,
					"cardWidth": 240.0,
				},
				"style": map[string]interface{}{
					"padding":        20.0,
					"spacing":        16.0,
					"borderRadius":   16.0,
					"imageHeight":    220.0,
					"showDiscount":   false,
					"showRating":     true,
					"showFavorite":   true,
					"titleSize":      19.0,
					"priceSize":      22.0,
					"priceColor":     "#6C5CE7",
					"elevation":      4.0,
					"contentPadding": 14.0,
				},
			},
			map[string]interface{}{
				"id":   "evening-grid",
				"type": "product_grid",
				"props": map[string]interface{}{
					"columns":     2,
					"spacing":     18.0,
					"aspectRatio": 0.8,
					"products":    getEveningProducts(),
				},
				"style": map[string]interface{}{
					"imageHeight":    220.0,
					"borderRadius":   16.0,
					"showDiscount":   false,
					"showRating":     true,
					"showFavorite":   true,
					"titleSize":      18.0,
					"priceSize":      20.0,
					"priceColor":     "#6C5CE7",
					"elevation":      3.0,
					"contentPadding": 14.0,
				},
			},
		},
		"navigation": getNavigationConfig("/", "evening"),
		"metadata":   getMetadata("evening"),
	}
}

// 🌙 NIGHT MODE (8PM - 12AM): Boutique Experience
func getNightModeConfig() map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "home",
		"layout_type": "scroll",
		"theme": map[string]interface{}{
			"is_dark_mode":     true,
			"primary_color":    "#1A1A1A",
			"background_color": "#0A0A0A",
			"accent_color":     "#FFD700",
			"font_sizes": map[string]float64{
				"headline": 40.0,
				"title":    28.0,
				"body":     18.0,
				"caption":  14.0,
			},
			"border_radius": 20.0,
			"spacing": map[string]float64{
				"xs": 4.0,
				"sm": 8.0,
				"md": 20.0,
				"lg": 32.0,
				"xl": 48.0,
			},
		},
		"components": []interface{}{
			map[string]interface{}{
				"id":   "night-hero",
				"type": "banner",
				"props": map[string]interface{}{
					"title":     "Midnight Collection",
					"subtitle":  "Curated elegance for the night",
					"height":    400.0,
					"alignment": "centerLeft",
				},
				"style": map[string]interface{}{
					"backgroundColor": "#1A1A2E",
					"borderRadius":    20.0,
					"margin":          24.0,
					"titleSize":       40.0,
					"subtitleSize":    20.0,
					"contentPadding":  32.0,
				},
			},
			map[string]interface{}{
				"id":    "spacer",
				"type":  "spacer",
				"props": map[string]interface{}{"height": 32.0},
			},
			map[string]interface{}{
				"id":   "night-products",
				"type": "product_grid",
				"props": map[string]interface{}{
					"columns":     1,
					"spacing":     24.0,
					"aspectRatio": 1.2,
					"products":    getNightProducts(),
				},
				"style": map[string]interface{}{
					"imageHeight":    300.0,
					"borderRadius":   20.0,
					"showDiscount":   false,
					"showRating":     false,
					"showFavorite":   true,
					"titleSize":      24.0,
					"priceSize":      28.0,
					"priceColor":     "#FFD700",
					"elevation":      2.0,
					"contentPadding": 16.0,
				},
			},
		},
		"navigation": getNavigationConfig("/", "night"),
		"metadata":   getMetadata("night"),
	}
}

// ☀️ DAY MODE (9AM - 12PM): Standard Shopping
func getDayModeConfig() map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "home",
		"layout_type": "scroll",
		"theme": map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#2C3E50",
			"background_color": "#FFFFFF",
			"accent_color":     "#3498DB",
			"font_sizes": map[string]float64{
				"headline": 32.0,
				"title":    20.0,
				"body":     16.0,
				"caption":  12.0,
			},
			"border_radius": 12.0,
			"spacing": map[string]float64{
				"xs": 4.0,
				"sm": 8.0,
				"md": 16.0,
				"lg": 24.0,
				"xl": 32.0,
			},
		},
		"components": []interface{}{
			map[string]interface{}{
				"id":   "header",
				"type": "header",
				"props": map[string]interface{}{
					"title":     "Welcome Back",
					"subtitle":  "What are you shopping for today?",
					"alignment": "left",
				},
				"style": map[string]interface{}{
					"padding":  16.0,
					"fontSize": 32.0,
					"color":    "#2C3E50",
				},
			},
			map[string]interface{}{
				"id":   "promo-banner",
				"type": "banner",
				"props": map[string]interface{}{
					"title":     "New Arrivals",
					"subtitle":  "Fresh styles just in",
					"height":    200.0,
					"alignment": "centerLeft",
				},
				"style": map[string]interface{}{
					"backgroundColor": "#3498DB",
					"borderRadius":    16.0,
					"margin":          16.0,
				},
			},
			map[string]interface{}{
				"id":   "products",
				"type": "product_grid",
				"props": map[string]interface{}{
					"columns":     2,
					"spacing":     16.0,
					"aspectRatio": 0.75,
					"products":    getDayProducts(),
				},
				"style": map[string]interface{}{
					"imageHeight":    200.0,
					"borderRadius":   12.0,
					"showDiscount":   true,
					"showRating":     true,
					"showFavorite":   true,
					"titleSize":      16.0,
					"priceSize":      18.0,
					"priceColor":     "#2C3E50",
					"elevation":      2.0,
					"contentPadding": 12.0,
				},
			},
		},
		"navigation": getNavigationConfig("/", "day"),
		"metadata":   getMetadata("day"),
	}
}

// ==================== OTHER SCREENS ====================

func getProductScreenConfig(mode string, productID string) map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "product",
		"layout_type": "scroll",
		"theme":       getThemeForMode(mode),
		"components": []interface{}{
			map[string]interface{}{
				"id":   "product-images",
				"type": "image",
				"props": map[string]interface{}{
					"url": "https://via.placeholder.com/400x500/6C5CE7/FFFFFF?text=Product+" + productID,
				},
				"style": map[string]interface{}{
					"width":        400.0,
					"height":       500.0,
					"borderRadius": 0.0,
					"fit":          "cover",
				},
			},
			map[string]interface{}{
				"id":   "product-info",
				"type": "container",
				"style": map[string]interface{}{
					"padding":         24.0,
					"backgroundColor": "#FFFFFF",
				},
				"children": []interface{}{
					map[string]interface{}{
						"id":   "title",
						"type": "header",
						"props": map[string]interface{}{
							"title":    "Premium Leather Jacket",
							"subtitle": "Handcrafted Excellence",
						},
						"style": map[string]interface{}{
							"fontSize": 28.0,
							"padding":  0.0,
						},
					},
					map[string]interface{}{
						"id":   "rating",
						"type": "rating",
						"props": map[string]interface{}{
							"rating":    4.8,
							"maxStars":  5,
							"showValue": true,
						},
						"style": map[string]interface{}{
							"size":  20.0,
							"color": "#FFD700",
						},
					},
					map[string]interface{}{
						"id":   "price",
						"type": "header",
						"props": map[string]interface{}{
							"title": "$299.99",
						},
						"style": map[string]interface{}{
							"fontSize":   36.0,
							"fontWeight": "bold",
							"color":      "#2C3E50",
							"padding":    8.0,
						},
					},
					map[string]interface{}{
						"id":   "buy-button",
						"type": "button",
						"props": map[string]interface{}{
							"label":     "Add to Cart",
							"variant":   "primary",
							"fullWidth": true,
							"icon":      "cart",
						},
						"style": map[string]interface{}{
							"backgroundColor": "#4CAF50",
							"paddingY":        18.0,
							"borderRadius":    12.0,
							"margin":          16.0,
						},
					},
				},
			},
		},
		"navigation": getNavigationConfig("/product", mode),
		"metadata":   getMetadata(mode),
	}
}

func getCartScreenConfig(mode string) map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "cart",
		"layout_type": "scroll",
		"theme":       getThemeForMode(mode),
		"components": []interface{}{
			map[string]interface{}{
				"id":   "cart-header",
				"type": "header",
				"props": map[string]interface{}{
					"title":    "Shopping Cart",
					"subtitle": "3 items",
				},
			},
			map[string]interface{}{
				"id":   "checkout-button",
				"type": "button",
				"props": map[string]interface{}{
					"label":     "Proceed to Checkout - $589.97",
					"variant":   "primary",
					"fullWidth": true,
				},
				"style": map[string]interface{}{
					"backgroundColor": "#4CAF50",
					"margin":          16.0,
				},
			},
		},
		"navigation": getNavigationConfig("/cart", mode),
		"metadata":   getMetadata(mode),
	}
}

func getSearchScreenConfig(mode string) map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "search",
		"layout_type": "scroll",
		"theme":       getThemeForMode(mode),
		"components": []interface{}{
			map[string]interface{}{
				"id":   "search-input",
				"type": "search_bar",
				"props": map[string]interface{}{
					"placeholder": "Search products...",
					"showFilter":  true,
				},
			},
		},
		"navigation": getNavigationConfig("/search", mode),
		"metadata":   getMetadata(mode),
	}
}

func getFavoritesScreenConfig(mode string) map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "favorites",
		"layout_type": "grid",
		"theme":       getThemeForMode(mode),
		"components": []interface{}{
			map[string]interface{}{
				"id":   "favorites-grid",
				"type": "product_grid",
				"props": map[string]interface{}{
					"columns":  2,
					"products": getDayProducts(),
				},
			},
		},
		"navigation": getNavigationConfig("/favorites", mode),
		"metadata":   getMetadata(mode),
	}
}

func getProfileScreenConfig(mode string) map[string]interface{} {
	return map[string]interface{}{
		"screen_id":   "profile",
		"layout_type": "scroll",
		"theme":       getThemeForMode(mode),
		"components": []interface{}{
			map[string]interface{}{
				"id":   "avatar",
				"type": "avatar",
				"props": map[string]interface{}{
					"name": "John Doe",
				},
				"style": map[string]interface{}{
					"size": 100.0,
				},
			},
		},
		"navigation": getNavigationConfig("/profile", mode),
		"metadata":   getMetadata(mode),
	}
}

// ==================== HELPER FUNCTIONS ====================

func getThemeForMode(mode string) map[string]interface{} {
	switch mode {
	case "night", "late_night":
		return map[string]interface{}{
			"is_dark_mode":     true,
			"primary_color":    "#1A1A1A",
			"background_color": "#0A0A0A",
			"accent_color":     "#FFD700",
		}
	case "morning":
		return map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#FF9800",
			"background_color": "#FFFBF5",
			"accent_color":     "#FFC107",
		}
	case "flash_sale":
		return map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#FF4757",
			"background_color": "#FFFFFF",
			"accent_color":     "#FF6B6B",
		}
	case "afternoon":
		return map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#00BCD4",
			"background_color": "#F0F8FF",
			"accent_color":     "#00ACC1",
		}
	case "evening":
		return map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#6C5CE7",
			"background_color": "#FAF9F6",
			"accent_color":     "#A29BFE",
		}
	default:
		return map[string]interface{}{
			"is_dark_mode":     false,
			"primary_color":    "#2C3E50",
			"background_color": "#FFFFFF",
			"accent_color":     "#3498DB",
		}
	}
}

func getMetadata(mode string) map[string]interface{} {
	return map[string]interface{}{
		"mode":         mode,
		"timestamp":    time.Now().Format(time.RFC3339),
		"server_time":  time.Now().Format("3:04 PM"),
		"version":      "2.0.0",
		"generated_by": "SDUI Engine",
	}
}

// ==================== PRODUCT DATA GENERATORS ====================

func getMidnightProducts() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":        "p1",
			"name":      "Midnight Silk Robe",
			"price":     189,
			"image_url": "https://via.placeholder.com/200/1A1A2E/FFFFFF?text=Silk+Robe",
		},
		map[string]interface{}{
			"id":        "p2",
			"name":      "Noir Leather Wallet",
			"price":     129,
			"image_url": "https://via.placeholder.com/200/2C2C3E/FFFFFF?text=Wallet",
		},
		map[string]interface{}{
			"id":        "p3",
			"name":      "Dark Essence Fragrance",
			"price":     159,
			"image_url": "https://via.placeholder.com/200/1A1A2E/FFFFFF?text=Fragrance",
		},
	}
}

func getMorningProducts() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":             "m1",
			"name":           "Morning Brew Coffee Maker",
			"price":          79,
			"original_price": 99,
			"discount":       20,
			"rating":         4.5,
			"review_count":   128,
			"badge":          "NEW",
			"is_favorite":    false,
			"image_url":      "https://via.placeholder.com/200/FF9800/FFFFFF?text=Coffee",
		},
		map[string]interface{}{
			"id":             "m2",
			"name":           "Sunrise Yoga Mat",
			"price":          45,
			"original_price": 60,
			"discount":       25,
			"rating":         4.8,
			"review_count":   95,
			"is_favorite":    true,
			"image_url":      "https://via.placeholder.com/200/FFC107/FFFFFF?text=Yoga+Mat",
		},
		map[string]interface{}{
			"id":           "m3",
			"name":         "Fresh Start Smoothie Blender",
			"price":        89,
			"rating":       4.6,
			"review_count": 203,
			"badge":        "SALE",
			"is_favorite":  false,
			"image_url":    "https://via.placeholder.com/200/FF9800/FFFFFF?text=Blender",
		},
	}
}

func getFlashSaleProducts() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":             "fs1",
			"name":           "Wireless Earbuds",
			"price":          39,
			"original_price": 99,
			"discount":       60,
			"rating":         4.3,
			"review_count":   542,
			"badge":          "FLASH",
			"is_favorite":    false,
			"image_url":      "https://via.placeholder.com/200/FF4757/FFFFFF?text=Earbuds",
		},
		map[string]interface{}{
			"id":             "fs2",
			"name":           "Smart Watch",
			"price":          89,
			"original_price": 199,
			"discount":       55,
			"rating":         4.7,
			"review_count":   287,
			"badge":          "FLASH",
			"is_favorite":    true,
			"image_url":      "https://via.placeholder.com/200/FF6B6B/FFFFFF?text=Watch",
		},
		map[string]interface{}{
			"id":             "fs3",
			"name":           "Portable Speaker",
			"price":          29,
			"original_price": 79,
			"discount":       63,
			"rating":         4.4,
			"review_count":   134,
			"badge":          "FLASH",
			"is_favorite":    false,
			"image_url":      "https://via.placeholder.com/200/FF4757/FFFFFF?text=Speaker",
		},
		map[string]interface{}{
			"id":             "fs4",
			"name":           "Fitness Tracker",
			"price":          19,
			"original_price": 49,
			"discount":       61,
			"rating":         4.2,
			"review_count":   89,
			"badge":          "FLASH",
			"is_favorite":    false,
			"image_url":      "https://via.placeholder.com/200/FF6B6B/FFFFFF?text=Fitness",
		},
	}
}

func getAfternoonProducts() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":             "a1",
			"name":           "Wireless Earbuds Pro",
			"price":          149,
			"original_price": 199,
			"discount":       25,
			"rating":         4.7,
			"review_count":   342,
			"is_favorite":    true,
			"image_url":      "https://via.placeholder.com/200/00BCD4/FFFFFF?text=Earbuds",
		},
		map[string]interface{}{
			"id":           "a2",
			"name":         "Smart Watch Series 5",
			"price":        299,
			"rating":       4.9,
			"review_count": 587,
			"badge":        "NEW",
			"is_favorite":  false,
			"image_url":    "https://via.placeholder.com/200/00ACC1/FFFFFF?text=Watch",
		},
		map[string]interface{}{
			"id":             "a3",
			"name":           "Portable Speaker",
			"price":          89,
			"original_price": 120,
			"discount":       26,
			"rating":         4.5,
			"review_count":   234,
			"is_favorite":    false,
			"image_url":      "https://via.placeholder.com/200/0097A7/FFFFFF?text=Speaker",
		},
		map[string]interface{}{
			"id":           "a4",
			"name":         "USB-C Hub",
			"price":        59,
			"rating":       4.6,
			"review_count": 156,
			"is_favorite":  false,
			"image_url":    "https://via.placeholder.com/200/00838F/FFFFFF?text=Hub",
		},
	}
}

func getEveningProducts() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":           "e1",
			"name":         "Premium Leather Jacket",
			"price":        299,
			"rating":       4.9,
			"review_count": 128,
			"badge":        "PREMIUM",
			"is_favorite":  true,
			"image_url":    "https://via.placeholder.com/200/6C5CE7/FFFFFF?text=Jacket",
		},
		map[string]interface{}{
			"id":           "e2",
			"name":         "Silk Evening Dress",
			"price":        189,
			"rating":       4.8,
			"review_count": 95,
			"is_favorite":  false,
			"image_url":    "https://via.placeholder.com/200/A29BFE/FFFFFF?text=Dress",
		},
		map[string]interface{}{
			"id":           "e3",
			"name":         "Gold-Plated Watch",
			"price":        459,
			"rating":       4.9,
			"review_count": 67,
			"badge":        "LUXURY",
			"is_favorite":  true,
			"image_url":    "https://via.placeholder.com/200/6C5CE7/FFFFFF?text=Watch",
		},
		map[string]interface{}{
			"id":           "e4",
			"name":         "Designer Handbag",
			"price":        389,
			"rating":       4.7,
			"review_count": 203,
			"is_favorite":  false,
			"image_url":    "https://via.placeholder.com/200/A29BFE/FFFFFF?text=Handbag",
		},
	}
}

func getNightProducts() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":           "n1",
			"name":         "Midnight Crystal Necklace",
			"price":        599,
			"rating":       5.0,
			"review_count": 42,
			"badge":        "BOUTIQUE",
			"is_favorite":  true,
			"image_url":    "https://via.placeholder.com/200/1A1A2E/FFD700?text=Necklace",
		},
		map[string]interface{}{
			"id":           "n2",
			"name":         "Black Diamond Ring",
			"price":        899,
			"rating":       4.9,
			"review_count": 28,
			"is_favorite":  false,
			"image_url":    "https://via.placeholder.com/200/2C2C3E/FFD700?text=Ring",
		},
		map[string]interface{}{
			"id":           "n3",
			"name":         "Limited Edition Perfume",
			"price":        249,
			"rating":       4.8,
			"review_count": 56,
			"badge":        "EXCLUSIVE",
			"is_favorite":  true,
			"image_url":    "https://via.placeholder.com/200/1A1A2E/FFD700?text=Perfume",
		},
	}
}

func getDayProducts() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":             "d1",
			"name":           "Casual T-Shirt",
			"price":          29,
			"original_price": 39,
			"discount":       26,
			"rating":         4.5,
			"review_count":   128,
			"badge":          "SALE",
			"is_favorite":    false,
			"image_url":      "https://via.placeholder.com/200/3498DB/FFFFFF?text=T-Shirt",
		},
		map[string]interface{}{
			"id":           "d2",
			"name":         "Denim Jeans",
			"price":        59,
			"rating":       4.7,
			"review_count": 256,
			"is_favorite":  true,
			"image_url":    "https://via.placeholder.com/200/2C3E50/FFFFFF?text=Jeans",
		},
		map[string]interface{}{
			"id":             "d3",
			"name":           "Running Shoes",
			"price":          89,
			"original_price": 120,
			"discount":       26,
			"rating":         4.8,
			"review_count":   342,
			"badge":          "POPULAR",
			"is_favorite":    false,
			"image_url":      "https://via.placeholder.com/200/3498DB/FFFFFF?text=Shoes",
		},
		map[string]interface{}{
			"id":           "d4",
			"name":         "Backpack",
			"price":        49,
			"rating":       4.6,
			"review_count": 189,
			"is_favorite":  false,
			"image_url":    "https://via.placeholder.com/200/2C3E50/FFFFFF?text=Backpack",
		},
	}
}

func getMorningStories() []interface{} {
	return []interface{}{
		map[string]interface{}{
			"id":        "s1",
			"name":      "New In",
			"viewed":    false,
			"image_url": "https://via.placeholder.com/70/FF9800/FFFFFF?text=New",
		},
		map[string]interface{}{
			"id":        "s2",
			"name":      "Sale",
			"viewed":    false,
			"image_url": "https://via.placeholder.com/70/FFC107/FFFFFF?text=Sale",
		},
		map[string]interface{}{
			"id":        "s3",
			"name":      "Trending",
			"viewed":    true,
			"image_url": "https://via.placeholder.com/70/FF9800/FFFFFF?text=Hot",
		},
		map[string]interface{}{
			"id":        "s4",
			"name":      "Deals",
			"viewed":    false,
			"image_url": "https://via.placeholder.com/70/FFC107/FFFFFF?text=Deals",
		},
	}
}
