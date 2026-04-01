package model

import "time"

type Gender int

const (
	GenderMale Gender = iota
	GenderFemale
	GenderNonBinary
	GenderLesbian
	GenderGay
	GenderTrans
)

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
