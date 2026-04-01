package store

import "database/sql"

func SetupDB(db *sql.DB) error {
	_, err := db.Exec(`
		CREATE TABLE IF NOT EXISTS users (
			id TEXT PRIMARY KEY,
			email TEXT UNIQUE NOT NULL,
			name TEXT NOT NULL,
			gender INTEGER NOT NULL,
			dateOfBirth DATETIME NOT NULL,
			city TEXT NOT NULL,
			country TEXT NOT NULL,
			joinDate DATETIME DEFAULT CURRENT_TIMESTAMP,
			pfpURL TEXT,
			pwdHash TEXT NOT NULL
		);	

		CREATE TABLE IF NOT EXISTS bios (
			id TEXT PRIMARY KEY,
			userID TEXT NOT NULL,
			aboutMe TEXT NOT NULL,
			FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE
		);

		CREATE TABLE IF NOT EXISTS hobbies (
			id TEXT PRIMARY KEY,
			bioID TEXT NOT NULL,
			name TEXT NOT NULL,
			FOREIGN KEY (bioID) REFERENCES bios(id) ON DELETE CASCADE
		);

		CREATE TABLE IF NOT EXISTS genders_interested_in (
			id TEXT PRIMARY KEY,
			bioID TEXT NOT NULL,
			gender TEXT NOT NULL,
			FOREIGN KEY (bioID) REFERENCES bios(id) ON DELETE CASCADE
		);

		CREATE TABLE IF NOT EXISTS photos (
			id TEXT PRIMARY KEY,
			bioID TEXT NOT NULL,
			url TEXT NOT NULL,
			position INTEGER NOT NULL,
			FOREIGN KEY (bioID) REFERENCES bios(id) ON DELETE CASCADE
		);
	`)

	return err
}
