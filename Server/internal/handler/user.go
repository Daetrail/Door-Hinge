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
