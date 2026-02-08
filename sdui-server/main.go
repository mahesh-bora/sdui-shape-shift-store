package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	// Initialize server
	mux := http.NewServeMux()

	// Routes
	mux.HandleFunc("/api/ui-config", handleUiConfig)
	mux.HandleFunc("/api/products/", handleProductDetail)
	mux.HandleFunc("/api/analytics", handleAnalytics)
	mux.HandleFunc("/health", handleHealth)

	// CORS middleware
	handler := enableCORS(mux)

	// Start server
	port := ":8080"
	fmt.Printf("🚀 Shape-Shifting Store Server running on http://localhost%s\n", port)
	fmt.Println("📡 Endpoints:")
	fmt.Println("   GET  /api/ui-config?screen=<name>")
	fmt.Println("   GET  /api/products/<id>")
	fmt.Println("   POST /api/analytics")
	fmt.Println("   GET  /health")
	fmt.Println("\n⏰ Server will automatically change UI based on time:")
	fmt.Println("   🌙 Night Mode:     8PM - 8AM  (Minimal Boutique)")
	fmt.Println("   ☀️  Day Mode:       8AM - 12PM (Standard Shop)")
	fmt.Println("   🔥 Flash Sale:     12PM - 2PM (Urgent, Dense)")
	fmt.Println("   🌆 Evening Mode:   6PM - 8PM  (Curated)")

	log.Fatal(http.ListenAndServe(port, handler))
}

// CORS middleware
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// Health check
func handleHealth(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":    "healthy",
		"timestamp": time.Now().Format(time.RFC3339),
		"mode":      getCurrentMode(),
	})
}

// Analytics endpoint (just logs for demo)
func handleAnalytics(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var event map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&event); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	log.Printf("📊 Analytics: %v", event)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// Get current mode based on time
// func getCurrentMode() string {
// 	now := time.Now()
// 	hour := now.Hour()

// 	switch {
// 	case hour >= 12 && hour < 14:
// 		return "flash_sale"
// 	case hour >= 18 && hour < 20:
// 		return "evening"
// 	case hour >= 20 || hour < 8:
// 		return "night"
// 	default:
// 		return "day"
// 	}
// }
