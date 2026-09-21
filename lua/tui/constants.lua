local utils = require("tui.utils")

local constants = {}

constants.NodeKind = utils.createEnum({
	TEXT = 1,
	ROW = 2,
	COLUMN = 3,

})

constants.NodeKindName = utils.createEnum({
	[constants.NodeKind.TEXT] = "text",
	[constants.NodeKind.ROW] = "row",
	[constants.NodeKind.COLUMN] = "column",
})

return constants
