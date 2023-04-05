package store

import (
	"gno.land/p/demo/ufmt"
)

type Item struct {
	id uint
	price int64
	description string
}

func NewItem(id uint, price int64, description string) *Item {
	return &Item{
		id: id,
		price: price,
		description: description,
	}
}

func (i Item) GetId() uint {
	return i.id
}

func (i Item) GetIdString() string {
	return ufmt.Sprintf("%d", i.GetId())
}

func (i Item) GetPrice() int64 {
	return i.price
}

func (i Item) GetDescription() string {
	return i.description
}

func (i Item) GetInfo() string {
	return ufmt.Sprintf("id: %d\nprice: %d\ndescription: %s", i.id, i.price, i.description,)
}