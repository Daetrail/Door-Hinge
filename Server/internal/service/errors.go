package service

import "errors"

var ErrEmailTaken = errors.New("email already taken")
var ErrInvalidCredentials = errors.New("invalid credentials")
var ErrUserDoesNotExist = errors.New("user does not exist")
var ErrUserDoesNotHaveProfilePicture = errors.New("no profile picture set")
var ErrInvalidFiletype = errors.New("invalid filetype")
