package service

import (
	"Server/internal/model"
	"Server/internal/store"
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	users  *store.UserStore
	secret string
}

func (s *AuthService) SignUp(ctx context.Context, email, name, password, city, country string, gender model.Gender, dob model.Date) (string, error) {
	// Check if user already exists
	exists, err := s.users.EmailExists(ctx, email)
	if err != nil {
		return "", err
	}
	if exists {
		return "", ErrEmailTaken
	}

	// Hash the password
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	// Save user to database
	userID, err := s.users.Create(ctx, email, name, string(hash), city, country, gender, dob)
	if err != nil {
		return "", err
	}

	return s.generateToken(userID)
}

func (s *AuthService) SignIn(ctx context.Context, email, password string) (string, error) {
	// Grab user by email
	user, err := s.users.GetByEmail(ctx, email)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", ErrInvalidCredentials
		}
		return "", err
	}

	// Check if password matches its hash
	err = bcrypt.CompareHashAndPassword([]byte(user.PwdHash), []byte(password))
	if err != nil {
		return "", ErrInvalidCredentials
	}

	return s.generateToken(user.ID)
}

func (s *AuthService) generateToken(userID string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"userID": userID,
		"exp":    time.Now().Add(72 * time.Hour).Unix(),
	})
	return token.SignedString([]byte(s.secret))
}
