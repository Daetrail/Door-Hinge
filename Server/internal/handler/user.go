package handler

import (
	"Server/internal/service"
	"errors"
	"log"
	"net/http"
)

type UserHandler struct {
	user *service.UserService
}

func NewUserHandler(user *service.UserService) *UserHandler {
	return &UserHandler{user: user}
}

func (h *UserHandler) Me(w http.ResponseWriter, r *http.Request) {
	// Obtain userID from context
	userID, ok := r.Context().Value("userID").(string)
	if !ok {
		SendError(w, http.StatusUnauthorized, "unauthorised")
		return
	}

	// Obtain user from DB
	user, err := h.user.Me(r.Context(), userID)
	if err != nil {
		if errors.Is(err, service.ErrUserDoesNotExist) {
			SendError(w, http.StatusBadRequest, "user does not exist")
			return
		}
		SendError(w, http.StatusInternalServerError, "internal server error")
		log.Println(err)
		return
	}

	SendSuccess(w, http.StatusOK, user)
}

func (h *UserHandler) GetProfilePicture(w http.ResponseWriter, r *http.Request) {
	// Obtain userID from context
	userID, ok := r.Context().Value("userID").(string)
	if !ok {
		SendError(w, http.StatusUnauthorized, "unauthorised")
		return
	}

	// Get filename of profile picture
	filename, err := h.user.GetProfilePictureFilename(r.Context(), userID)
	if err != nil {
		if errors.Is(err, service.ErrUserDoesNotExist) {
			SendError(w, http.StatusBadRequest, "user does not exist")
			return
		}
		if errors.Is(err, service.ErrUserDoesNotHaveProfilePicture) {
			SendError(w, http.StatusNotFound, "no profile picture set")
			return
		}
		SendError(w, http.StatusInternalServerError, "internal server error")
		log.Println(err)
		return
	}

	http.ServeFile(w, r, filename)
}

func (h *UserHandler) SetProfilePicture(w http.ResponseWriter, r *http.Request) {
	// Cap entire request body at 15MB
	r.Body = http.MaxBytesReader(w, r.Body, 15<<20)

	// Parse the form
	err := r.ParseMultipartForm(5 << 20)
	if err != nil {
		SendError(w, http.StatusRequestEntityTooLarge, "file too large")
		return
	}
	file, _, err := r.FormFile("image")
	if err != nil {
		SendError(w, http.StatusBadRequest, "missing image")
		return
	}
	defer file.Close()

	// Obtain userID from context
	userID, ok := r.Context().Value("userID").(string)
	if !ok {
		SendError(w, http.StatusUnauthorized, "unauthorised")
		return
	}

	err = h.user.SetProfilePicture(r.Context(), userID, file)
	if err != nil {
		if errors.Is(err, service.ErrInvalidFiletype) {
			SendError(w, http.StatusBadRequest, "invalid filetype")
			return
		}
		SendError(w, http.StatusInternalServerError, "internal server error")
		log.Println(err)
		return
	}

	SendSuccessWithNoData(w, http.StatusCreated)
}
