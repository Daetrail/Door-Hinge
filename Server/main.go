package main

import (
	"Server/internal/handler"
	"Server/internal/middleware"
	"Server/internal/service"
	"database/sql"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"Server/internal/store"

	_ "modernc.org/sqlite"
)

func main() {
	// Create data directory if it doesn't exist
	if err := os.MkdirAll("./data", 0755); err != nil {
		log.Fatal(err)
	}

	// Get absolute path for SQLite DB file and open it
	dir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	dbPath := filepath.Join(dir, "data", "datingapp.db")
	db, err := sql.Open("sqlite", dbPath+"?_pragma=journal_mode(WAL)&_pragma=foreign_keys(1)")
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err := db.Close(); err != nil {
			log.Println(err)
		}
	}()

	// Setup DB tables
	if err := store.SetupDB(db); err != nil {
		log.Fatal(err)
	}

	log.Println("SQLite database ready!")

	// Get JWT secret
	jwtSecret, exists := os.LookupEnv("JWT_SECRET")
	if !exists {
		log.Fatal("JWT_SECRET not found in environment")
	}

	// Create stores
	userStore := store.NewUserStore(db)
	cityStore := store.NewCityStore(db)

	// Add cities in DB
	const cityFilename = "./data/cities15000.txt"
	err = cityStore.AddCountryCityData(cityFilename)
	if err != nil {
		log.Fatal(err)
	}

	// Create services
	authService := service.NewAuthService(userStore, jwtSecret)
	userService := service.NewUserService(userStore)

	// Create handlers
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService)
	cityHandler := handler.NewCityHandler(cityStore)

	// Create middleware
	authMiddleware := middleware.AuthMiddleware(jwtSecret)

	// Routes
	mux := http.NewServeMux()

	// Public
	// Auth
	mux.HandleFunc("POST /auth/sign-up", authHandler.SignUp)
	mux.HandleFunc("POST /auth/sign-in", authHandler.SignIn)

	// City
	mux.HandleFunc("GET /city", cityHandler.CitiesFromCountryCode)

	// Protected
	// Auth
	mux.Handle("GET /auth/verify", authMiddleware(http.HandlerFunc(authHandler.Verify)))
	// User
	mux.Handle("GET /user/me", authMiddleware(http.HandlerFunc(userHandler.Me)))
	mux.Handle("GET /user/pfp", authMiddleware(http.HandlerFunc(userHandler.GetProfilePicture)))
	mux.Handle("POST /user/pfp", authMiddleware(http.HandlerFunc(userHandler.SetProfilePicture)))

	// Catch-all route
	mux.HandleFunc("/", handler.NotFound)

	log.Println("Listening on :4892")
	log.Fatal(http.ListenAndServe(":4892", mux))
}
