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

	// Open SQLite DB
	dir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	dbPath := filepath.Join(dir, "data", "datingapp.db")
	db, err := sql.Open("sqlite", dbPath+"?_pragma=journal_mode(WAL)&_pragma=foreign_keys(1)")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Setup DB tables
	if err := store.SetupDB(db); err != nil {
		log.Fatal(err)
	}

	log.Println("SQLite database ready!")
}
