package service

import (
	"Server/internal/model"
	"Server/internal/store"
	"context"
	"database/sql"
	"errors"
)

type UserService struct {
	users *store.UserStore
}

func NewUserService(users *store.UserStore) *UserService {
	return &UserService{users: users}
}

func (s *UserService) Me(ctx context.Context, id string) (model.User, error) {
	user, err := s.users.GetByID(ctx, id)
	if err != nil {
		// User doesn't exist
		if errors.Is(err, sql.ErrNoRows) {
			return model.User{}, ErrUserDoesNotExist
		}
		return model.User{}, ErrUserDoesNotExist
	}

	return user, nil
}
