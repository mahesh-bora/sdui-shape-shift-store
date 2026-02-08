package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

// Product struct
type Product struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Price       float64 `json:"price"`
	ImageURL    string  `json:"image_url"`
	Description string  `json:"description"`
	Discount    *int    `json:"discount,omitempty"`
}

// Handle product detail
func handleProductDetail(w http.ResponseWriter, r *http.Request) {
	productID := strings.TrimPrefix(r.URL.Path, "/api/products/")

	product := getProductByID(productID)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(product)
}

func getProductByID(id string) Product {
	products := getAllProducts()

	for _, p := range products {
		if p.ID == id {
			return p
		}
	}

	// Default product
	return Product{
		ID:          id,
		Name:        "Unknown Product",
		Price:       199.98, // Doubled from 99.99
		ImageURL:    "",
		Description: "Product not found",
	}
}

// Mock product database
func getAllProducts() []Product {
	discount15 := 15
	discount25 := 25
	discount40 := 40

	return []Product{
		{
			ID:          "prod_1",
			Name:        "Premium Leather Jacket",
			Price:       599.98, // Doubled from 299.99
			ImageURL:    "https://images.unsplash.com/photo-1551028719-00167b16eac5",
			Description: "Handcrafted Italian leather",
		},
		{
			ID:          "prod_2",
			Name:        "Silk Evening Dress",
			Price:       799.98, // Doubled from 399.99
			ImageURL:    "https://images.unsplash.com/photo-1595777457583-95e059d581b8",
			Description: "Elegant and timeless",
		},
		{
			ID:          "prod_3",
			Name:        "Designer Sunglasses",
			Price:       319.98, // Doubled from 159.99
			ImageURL:    "https://images.unsplash.com/photo-1572635196237-14b3f281503f",
			Description: "UV protection with style",
			Discount:    &discount15,
		},
		{
			ID:          "prod_4",
			Name:        "Cashmere Sweater",
			Price:       499.98, // Doubled from 249.99
			ImageURL:    "https://images.unsplash.com/photo-1576566588028-4147f3842f27",
			Description: "Luxuriously soft",
		},
		{
			ID:          "prod_5",
			Name:        "Oxford Dress Shoes",
			Price:       379.98, // Doubled from 189.99
			ImageURL:    "https://images.unsplash.com/photo-1614252369475-531eba835eb1",
			Description: "Handmade in Italy",
			Discount:    &discount25,
		},
		{
			ID:          "prod_6",
			Name:        "Minimalist Watch",
			Price:       899.98, // Doubled from 449.99
			ImageURL:    "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
			Description: "Swiss movement",
		},
		{
			ID:          "prod_7",
			Name:        "Wool Overcoat",
			Price:       999.98, // Doubled from 499.99
			ImageURL:    "https://images.unsplash.com/photo-1539533018447-63fcce2678e3",
			Description: "Winter elegance",
		},
		{
			ID:          "prod_8",
			Name:        "Leather Handbag",
			Price:       699.98, // Doubled from 349.99
			ImageURL:    "https://images.unsplash.com/photo-1584917865442-de89df76afd3",
			Description: "Spacious and stylish",
			Discount:    &discount40,
		},
	}
}

func init() {
	// Log available products at startup
	products := getAllProducts()
	fmt.Printf("\n📦 Loaded %d products:\n", len(products))
	for _, p := range products {
		discountStr := ""
		if p.Discount != nil {
			discountStr = fmt.Sprintf(" (-%d%%)", *p.Discount)
		}
		fmt.Printf("   %s: %s - $%.2f%s\n", p.ID, p.Name, p.Price, discountStr)
	}
	fmt.Println()
}
