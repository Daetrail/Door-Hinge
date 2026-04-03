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

	// Create services
	authService := service.NewAuthService(userStore, jwtSecret)
	userService := service.NewUserService(userStore)

	// Create handlers
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService)

	// Create middleware
	authMiddleware := middleware.AuthMiddleware(jwtSecret)

	// Routes
	mux := http.NewServeMux()

	// Public
	// Auth
	mux.HandleFunc("POST /api/auth/sign-up", authHandler.SignUp)
	mux.HandleFunc("POST /api/auth/sign-in", authHandler.SignIn)

	// Protected
	// User
	mux.Handle("GET /api/user/me", authMiddleware(http.HandlerFunc(userHandler.Me)))

	// Catch-all route
	mux.HandleFunc("/", handler.NotFound)

	log.Println("Listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
