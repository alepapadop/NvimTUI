local utils = require("tui.utils")

local constants = {}

-- ************************************************************************* --

-- ************************************************************************* --
constants.NodeKind = utils.createEnum({
	TEXT = 1,
	ROW = 2,
	COLUMN = 3,

})

-- ************************************************************************* --

-- ************************************************************************* --
constants.NodeKindName = utils.createEnum({
	[constants.NodeKind.TEXT] = "text",
	[constants.NodeKind.ROW] = "row",
	[constants.NodeKind.COLUMN] = "column",
})

-- ************************************************************************* --

-- ************************************************************************* --
constants.Align = utils.createEnum({
    LEFT = 1,
    RIGHT = 2,
    CENTTER = 3,
    AUTO = 4,
})

constants.AlignName = utils.createEnum({
    [constants.Align.LEFT] = "left",
    [constants.Align.RIGHT] = "right",
    [constants.Align.CENTER] = "center",
    [constants.Align.AUTO] = "auto",
})

constants.Justify = utils.createEnum({
    LEFT = 1,
    RIGHT = 2,
    CENTTER = 3,
    AUTO = 4,
})

constants.JustifyName = utils.createEnum({
    [constants.Justify.LEFT] = "left",
    [constants.Justify.RIGHT] = "right",
    [constants.Justify.CENTER] = "center",
    [constants.Justify.AUTO] = "auto",

})


return constants
