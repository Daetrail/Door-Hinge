package store

import (
	"Server/internal/model"
	"context"
	"database/sql"
	"strings"
	"time"

	"github.com/google/uuid"
)

type UserStore struct {
	db *sql.DB
}

func NewUserStore(db *sql.DB) *UserStore {
	return &UserStore{db: db}
}

func (store *UserStore) Create(ctx context.Context, email, firstName, lastName, passwordHash, city, country string, gender model.Gender, dob time.Time) (string, error) {
	id := uuid.New().String()
	_, err := store.db.ExecContext(ctx,
		"INSERT INTO users (id, email, firstName, lastName, gender, dateOfBirth, city, country, joinDate, pwdHash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
		id, email, firstName, lastName, gender, dob.Format("2006-01-02"), city, country, time.Now().Format("2006-01-02"), passwordHash,
	)
	return id, err
}

func (store *UserStore) GetByEmail(ctx context.Context, email string) (model.User, error) {
	var user model.User
	err := store.db.QueryRowContext(ctx,
		"SELECT id, email, firstName, lastName, gender, dateOfBirth, city, country, joinDate, pfpURL, pwdHash FROM users WHERE email = ?",
		strings.ToLower(email),
	).Scan(&user.ID, &user.Email, &user.FirstName, &user.LastName, &user.Gender, &user.DateOfBirth, &user.City, &user.Country, &user.JoinDate, &user.PfpURL, &user.PwdHash)
	if err != nil {
		return model.User{}, err
	}
	return user, err
}

func (store *UserStore) GetByID(ctx context.Context, id string) (model.User, error) {
	var user model.User
	err := store.db.QueryRowContext(ctx,
		"SELECT id, email, firstName, lastName, gender, dateOfBirth, city, country, joinDate, pfpURL FROM users WHERE id = ?",
		id,
	).Scan(&user.ID, &user.Email, &user.FirstName, &user.LastName, &user.Gender, &user.DateOfBirth, &user.City, &user.Country, &user.JoinDate, &user.PfpURL)
	return user, err
}

func (store *UserStore) EmailExists(ctx context.Context, email string) (bool, error) {
	var exists bool
	err := store.db.QueryRowContext(ctx,
		"SELECT EXISTS(SELECT 1 FROM users WHERE email = ?)",
		strings.ToLower(email),
	).Scan(&exists)
	return exists, err
}
