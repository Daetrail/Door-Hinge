package model

import (
	"fmt"
	"time"
)

type Gender int

const (
	GenderMale Gender = iota
	GenderFemale
	GenderGay
	GenderLesbian
	GenderNonBinary
	GenderTrans
)

func (g Gender) IsValid() bool {
	switch g {
	case GenderMale, GenderFemale, GenderNonBinary, GenderLesbian, GenderGay, GenderTrans:
		return true
	}
	return false
}

type Date struct {
	time.Time
}

func (d Date) MarshalJSON() ([]byte, error) {
	return []byte(`"` + d.Format("2006-01-02") + `"`), nil
}

func (d *Date) UnmarshalJSON(b []byte) error {
	t, err := time.Parse(`"2006-01-02"`, string(b))
	if err != nil {
		return err
	}
	d.Time = t
	return nil
}

func (d *Date) Scan(value any) error {
	switch v := value.(type) {
	case time.Time:
		d.Time = v
		return nil
	case string:
		t, err := time.Parse("2006-01-02", v)
		if err != nil {
			t, err = time.Parse("2006-01-02T15:04:05Z07:00", v)
			if err != nil {
				return err
			}
		}
		d.Time = t
		return nil
	default:
		return fmt.Errorf("cannot scan %T into Date", value)
	}
}
