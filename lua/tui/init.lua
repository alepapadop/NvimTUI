local Node = require("tui.node")
local constants = require("tui.constants")

local M = {}


function M.text(text, options)
    return Node.new(
        constants.NodeKind.TEXT,
        {
            text = text,
        },
        nil,
        options
    )
end

function M.row(children, options)
    return Node.new(
        constants.NodeKind.ROW,
        {},
        children,
        options
    )
end

function M.column(children, options)
    return Node.new(
        constants.NodeKind.COLUMN,
        {},
        children,
        options
    )
end

function M.new()
    error("tui.new() is not implemented yet")
end


return M
