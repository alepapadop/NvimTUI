local constants = require("tui.constants")


local Node = {}
Node.__index = Node

-- ************************************************************************* --

-- ************************************************************************* --
local function new_rect()
    return {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
    }
end

-- ************************************************************************* --

-- ************************************************************************* --
function Node.new(kind, props, children, options)
    options = options or {}

    local self = setmetatable({
        kind = kind,

        props = props or {},
        data = options.data or {},
        state = {},
        layout = options.layout or {},

        rect = new_rect(),

        parent = nil,
        children = {},

        render_fn = options.render,

    }, Node)


    if children then
        for _, child in ipairs(children) do
            self:add(child)
        end
    end

    return self
end

-- ************************************************************************* --

-- ************************************************************************* --
function Node:add(child)
    child.parent = self
    self.children[#self.children + 1] = child

    return self
end

-- ************************************************************************* --

-- ************************************************************************* --
function Node:is_leaf()
    return #self.children == 0
end

-- ************************************************************************* --

-- ************************************************************************* --
function Node:set_rect(x, y, width, height)
    self.rect.x = x
    self.rect.y = y
    self.rect.width = width
    self.rect.height = height

    return self
end

-- ************************************************************************* --

-- ************************************************************************* --


return Node
