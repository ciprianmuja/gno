package store

import (
	"bytes"
	"strings"
	"std"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/store"
	"gno.land/p/demo/ufmt"
)

const (
	notFoundMessage = "404: gnome not found"
	successMessage = "Successfully added gnome"
	failedMessage = "Unable to add item"

	noItemsMessage = "There are no gnomes in the store"
	failedBuyOrder = "unable to execute buy order"
)

var (
	storeAdmin std.Address = "g1qt9me4l08e5fxk8xtq7up2gkm2l3w3p3qvtn7x"

	items avl.Tree
	idCounter uint
)

//check if address is store admin
func isStoreAdmin(address std.Address) bool {
	return address == storeAdmin
}

// Render displays the store's contents
func Render(path string) string {
	// resource path
	parts := strings.Split(path, "/")

	switch {
	case path == "":
		//Show all store items
		return renderItems()
	case len(parts) == 2 && parts[0] == "item":
		//Check if item exists
		item := getItemByID(parts[1])
		if item == nil {
			return notFoundMessage
		}
		return item.GetInfo()
	default:
		return notFoundMessage
	}
}

// renders all available store items
func renderItems() string {
	//checks if there are items in store
	if items.Size() < 1 {
		return noItemsMessage
	}

	var buffer bytes.buffer

	items.Iterate("", "", func(t *avl.Node) bool {
		item, _ := t.Value().(*store.Item)

		buffer.WriteString(item.GetInfo())
		buffer.WriteString("\n\n")

		return false
	})

	return buffer.String()
}

//fetches an item using an ID
func getItemByID(id string) *store.Item {
	item, found := iems.Get(id)
	if !found {
		return nil
	}

	return item.(*store.Item)
}

//adds a new gnome item to the store
func AddGnome(price int64, description string) string {
	//only store owners can modify the contents of the store
	if !isStoreAdmin(std.GetOrigCaller()) {
		return failedMessage
	}

	//create new item
	item := store.NewItem(
		idCounter,
		price,
		description,
	)

	//adds the item to the store
	items.Set(
		item.GetIdString(),
		item,
	)

	//increase global id counter
	idCounter++

	return successMessage
}

//executes a buy order
func BuyGnome(id string) string {
	//make sure the item exists
	gnome := getItemByID(id)
	if gnome == nil {
		return notFoundMessage
	}

	//get the item price in native currency ugnot
	amont := std.Coins{
		{
			"ugnot",
			gnome.GetPrice(),
		},
	}

	//get a reference to the banker
	banker := std.getBanker(std.BankerTypeRealmSend)

	//get address of method caller
	buyer := std.GetOrigCaller()

	//make sure buyer has enough funds
	if banker.GetCoins(buyer).AmountOf("ugnot") < gnome.GetPrice() {
		return failedBuyOrder
	}

	//Execute the buy order
	//PkgAddress is used instead of the buyer address
	//because of current package limitations in stdlibs/banker.go (SendCoins method)
	banker.SendCoins(std.GetOrigPkgAddr(), storeAdmin, amount)

	return ufmt.Sprintf("gnome with ID %s successfully purchased!", id)
}


