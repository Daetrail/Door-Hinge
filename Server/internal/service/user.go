package service

import (
	"Server/internal/model"
	"Server/internal/store"
	"context"
	"database/sql"
	"errors"
	"image"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"mime/multipart"
	"path/filepath"
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
		return model.User{}, err
	}

	return user, nil
}

func (s *UserService) GetProfilePictureFilename(ctx context.Context, id string) (string, error) {
	hasProfilePicture, profilePictureFilename, err := s.users.DoesUserHaveProfilePicture(ctx, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", ErrUserDoesNotExist
		}
	}

	if !hasProfilePicture {
		return "", ErrUserDoesNotHaveProfilePicture
	}

	return filepath.Join("data", "uploads", "profile_pictures", profilePictureFilename), nil
}

func (s *UserService) SetProfilePicture(ctx context.Context, id string, file multipart.File) error {
	// Decode image to validate
	_, format, err := image.Decode(file)
	if err != nil {
		return ErrInvalidFiletype
	}
	_, err = file.Seek(0, io.SeekStart)
	if err != nil {
		return err
	}

	var ext string
	if format == "jpeg" {
		ext = "jpg"
	} else {
		ext = format
	}

	err = s.users.SetProfilePicture(ctx, id, file, ext)
	if err != nil {
		return err
	}

	return nil
}
