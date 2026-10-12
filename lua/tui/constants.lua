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
    START = 1,
    END = 2,
    CENTER = 3,
    AUTO = 4,
    STRETCH = 4,
})

constants.AlignName = utils.createEnum({
    [constants.Align.START] = "start",
    [constants.Align.END] = "end",
    [constants.Align.CENTER] = "center",
    [constants.Align.AUTO] = "auto",
    [constants.Align.STRETCH] = "stretch",
})

constants.Place = constants.Align
constants.PlaceName = constants.AlignName


return constants
