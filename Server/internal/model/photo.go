package model

type Photo struct {
	ID       string `json:"id"`
	BioID    string `json:"bioID"`
	URL      string `json:"URL"`
	Position int    `json:"position"`
}
