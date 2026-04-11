package model

type User struct {
	ID          string  `json:"id"`
	Email       string  `json:"email"`
	FirstName   string  `json:"firstName"`
	LastName    string  `json:"lastName"`
	Gender      Gender  `json:"gender"`
	DateOfBirth Date    `json:"dateOfBirth"`
	City        string  `json:"city"`
	Country     string  `json:"country"`
	JoinDate    Date    `json:"joinDate"`
	PfpURL      *string `json:"-"`
	PwdHash     string  `json:"-"`
}
