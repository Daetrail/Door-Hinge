package model

type Bio struct {
	ID                  string   `json:"id"`
	UserID              string   `json:"userID"`
	AboutMe             string   `json:"aboutMe"`
	Hobbies             []string `json:"hobbies"`
	GendersInterestedIn []Gender `json:"gendersInterestedIn"`
	Photos              []Photo  `json:"photos"`
}
