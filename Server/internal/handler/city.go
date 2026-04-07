package handler

import (
	"Server/internal/store"
	"database/sql"
	"errors"
	"log"
	"net/http"
)

type CityHandler struct {
	city *store.CityStore
}

func NewCityHandler(city *store.CityStore) *CityHandler {
	return &CityHandler{city: city}
}

func (h *CityHandler) CitiesFromCountryCode(w http.ResponseWriter, r *http.Request) {
	countryCode := r.URL.Query().Get("cc")
	if len(countryCode) != 2 {
		SendError(w, http.StatusBadRequest, "invalid country code")
		return
	}

	cities, err := h.city.GetCitiesFromCountryCode(r.Context(), countryCode)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			SendError(w, http.StatusNotFound, "no cities with provided country code")
			return
		}
		SendError(w, http.StatusInternalServerError, "internal server error")
		log.Println(err)
		return
	}

	SendSuccess(w, http.StatusOK, cities)
}
