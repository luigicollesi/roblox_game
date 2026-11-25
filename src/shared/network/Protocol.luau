--!strict
local Protocol = {
	remoteName = "Navigation",
	maxIdLength = 160,
	moveInterval = 0.15,
}
return table.freeze(Protocol)
