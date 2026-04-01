package main

import (
	"database/sql"
	"log"
	"path/filepath"
	//"net/http"
	"os"

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
			log.Println("error closing database:", err)
		}
	}()

	// Setup DB tables
	if err := store.SetupDB(db); err != nil {
		log.Fatal(err)
	}

	log.Println("SQLite database ready!")
}
