package handler

import (
	"Server/internal/model"
	"Server/internal/service"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"net/mail"
	"regexp"
	"time"
	"unicode/utf8"

	"github.com/biter777/countries"
)

var (
	hasUpper   = regexp.MustCompile(`[A-Z]`)
	hasLower   = regexp.MustCompile(`[a-z]`)
	hasDigit   = regexp.MustCompile(`[0-9]`)
	hasSpecial = regexp.MustCompile(`[#?!@$%^&*-]`)
	isASCII    = regexp.MustCompile(`^[\x00-\x7F]+$`)
)

var validCityName = regexp.MustCompile(`^[a-zA-ZÀ-ÿ\s'.,-]{2,100}$`)

type AuthHandler struct {
	auth *service.AuthService
}

func NewAuthHandler(auth *service.AuthService) *AuthHandler {
	return &AuthHandler{auth: auth}
}

type signUpRequest struct {
	Email       string       `json:"email"`
	FirstName   string       `json:"firstName"`
	LastName    string       `json:"lastName"`
	Password    string       `json:"password"`
	City        string       `json:"city"`
	Country     string       `json:"country"`
	Gender      model.Gender `json:"gender"`
	DateOfBirth string       `json:"dateOfBirth"`
}

type signInRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type authResponse struct {
	Token string `json:"token"`
}

func (h *AuthHandler) SignUp(w http.ResponseWriter, r *http.Request) {
	var req signUpRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		SendError(w, http.StatusBadRequest, "invalid request")
		return
	}

	if !req.validate() {
		SendError(w, http.StatusBadRequest, "not all fields valid")
		return
	}

	dob, err := time.Parse("2006-01-02", req.DateOfBirth)
	if err != nil {
		SendError(w, http.StatusBadRequest, "invalid date of birth")
		return
	}

	if age(dob) < 18 {
		SendError(w, http.StatusBadRequest, "not old enough")
		return
	}

	token, err := h.auth.SignUp(r.Context(), req.Email, req.FirstName, req.LastName, req.Password, req.City, req.Country, req.Gender, dob)
	if err != nil {
		if errors.Is(err, service.ErrEmailTaken) {
			SendError(w, http.StatusConflict, service.ErrEmailTaken.Error())
			return
		}

		SendError(w, http.StatusInternalServerError, "internal server error")
		log.Println(err)
		return
	}

	SendSuccess(w, http.StatusCreated, authResponse{Token: token})
}

func (h *AuthHandler) SignIn(w http.ResponseWriter, r *http.Request) {
	var req signInRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		SendError(w, http.StatusBadRequest, "invalid request")
		return
	}

	if !req.validate() {
		SendError(w, http.StatusBadRequest, "not all fields valid")
		return
	}

	token, err := h.auth.SignIn(r.Context(), req.Email, req.Password)
	if err != nil {
		if errors.Is(err, service.ErrInvalidCredentials) {
			SendError(w, http.StatusUnauthorized, service.ErrInvalidCredentials.Error())
			return
		}

		SendError(w, http.StatusInternalServerError, "internal server error")
		log.Println(err)
		return
	}

	SendSuccess(w, http.StatusCreated, authResponse{Token: token})
}

func (r *signUpRequest) validate() bool {
	// Check if email is valid
	_, err := mail.ParseAddress(r.Email)
	if err != nil {
		return false
	}

	// Check if name is valid
	if utf8.RuneCountInString(r.FirstName) > 40 || utf8.RuneCountInString(r.FirstName) <= 0 {
		return false
	}
	if utf8.RuneCountInString(r.LastName) > 40 || utf8.RuneCountInString(r.LastName) <= 0 {
		return false
	}

	// Check password
	if !isValidPassword(r.Password) {
		return false
	}

	// Check city
	if !validCityName.MatchString(r.City) {
		return false
	}

	// Check country
	if countries.ByName(r.Country) == countries.Unknown {
		return false
	}

	// Check gender
	if !r.Gender.IsValid() {
		return false
	}

	return true
}

func (r *signInRequest) validate() bool {
	// Check if email is valid
	_, err := mail.ParseAddress(r.Email)
	if err != nil {
		return false
	}

	return true
}

func age(dob time.Time) int {
	now := time.Now()
	age := now.Year() - dob.Year()
	if now.YearDay() < dob.YearDay() {
		age--
	}
	return age
}

func isValidPassword(password string) bool {
	return len(password) >= 8 &&
		len(password) <= 32 &&
		isASCII.MatchString(password) &&
		hasUpper.MatchString(password) &&
		hasLower.MatchString(password) &&
		hasDigit.MatchString(password) &&
		hasSpecial.MatchString(password)
}
