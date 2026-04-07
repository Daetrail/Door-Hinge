package store

import (
	"bufio"
	"context"
	"database/sql"
	"os"
	"strings"
)

type CityStore struct {
	db *sql.DB
}

func NewCityStore(db *sql.DB) *CityStore {
	return &CityStore{db: db}
}

func (s *CityStore) AddCountryCityData(filename string) (e error) {
	// Check if the country_city table exists
	var count int
	err := s.db.QueryRow("SELECT COUNT(*) FROM country_city;").Scan(&count)
	if err == nil && count > 0 {
		return nil
	}

	// Open file
	file, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer func() {
		if err := file.Close(); err != nil {
			e = err
		}
	}()

	scanner := bufio.NewScanner(file)

	// Begin new transaction for DB
	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer func() {
		if e != nil {
			if err := tx.Rollback(); err != nil {
				e = err
			}
		}
	}()

	for scanner.Scan() {
		line := scanner.Text()
		split := strings.Split(line, "\t")

		// Insert country code and corresponding city in the DB
		// https://www.geonames.org/ for the country-city data
		_, err := tx.Exec(
			"INSERT INTO country_city (id, countryCode, city) VALUES (?, ?, ?);",
			split[0], split[8], split[1],
		)
		if err != nil {
			return err
		}
	}

	// Check for errors during scan
	if err := scanner.Err(); err != nil {
		return err
	}

	// Commit transaction
	if err = tx.Commit(); err != nil {
		return err
	}

	return nil
}

func (s *CityStore) GetCitiesFromCountryCode(ctx context.Context, countryCode string) (c []string, e error) {
	rows, err := s.db.QueryContext(ctx, "SELECT city FROM country_city WHERE countryCode = ? ORDER BY city ASC", countryCode)
	if err != nil {
		return nil, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			c = nil
			e = err
		}
	}()

	var cities []string
	for rows.Next() {
		var entry string
		if err := rows.Scan(&entry); err != nil {
			return cities, err
		}
		cities = append(cities, entry)
	}
	if err = rows.Err(); err != nil {
		return cities, err
	}
	return cities, nil
}
