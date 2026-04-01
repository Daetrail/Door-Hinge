package model

type User struct {
	ID          string  `json:"id"`
	Email       string  `json:"email"`
	Name        string  `json:"name"`
	Gender      Gender  `json:"gender"`
	DateOfBirth Date    `json:"dateOfBirth"`
	BioID       string  `json:"bioID"`
	Lat         float64 `json:"lat"`
	Lng         float64 `json:"lng"`
	JoinDate    Date    `json:"joinDate"`
	PfpURL      string  `json:"pfpURL"`
	PwdHash     string  `json:"-"`
}
