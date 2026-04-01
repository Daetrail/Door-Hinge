package model

type User struct {
	ID          string `json:"id"`
	Email       string `json:"email"`
	Name        string `json:"name"`
	Gender      Gender `json:"gender"`
	DateOfBirth Date   `json:"dateOfBirth"`
	City        string `json:"city"`
	Country     string `json:"country"`
	JoinDate    Date   `json:"joinDate"`
	PfpURL      string `json:"pfpURL"`
	PwdHash     string `json:"-"`
}
