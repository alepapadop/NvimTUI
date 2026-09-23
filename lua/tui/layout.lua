local constants = require("tui.constants")

local M = {}

-- ************************************************************************* --

-- ************************************************************************* --
local function base_size(node)

    if node.kind == constants.NodeKind.TEXT then
        local text = node.props.text or ""

        return #text, 1
    end

    if node.kind == constants.NodeKind.ROW then
        local width = 0
        local height = 0

        for _, child in ipairs(node.children) do
            local child_width, child_height = base_size(child)

            width = width + child_width
            height = math.max(height, child_height)
        end

        return width, height
    end

    if node.kind == constants.NodeKind.COLUMN then
        local width = 0
        local height = 0

        for _, child in ipairs(node.children) do
            local child_width, child_height = base_size(child)

            width = math.max(width, child_width)
            height = height + child_height
        end

        return width, height
    end

    return 0, 0
end

-- ************************************************************************* --

-- ************************************************************************* --
local function requested_width(node)

    if node.layout.width ~= nil then
        return node.layout.width
    end

    local width = base_size(node)

    return width
end

-- ************************************************************************* --

-- ************************************************************************* --
local function requested_height(node)

    if node.layout.height ~= nil then
        return node.layout.height
    end

    local _, height = base_size(node)

    return height
end

-- ************************************************************************* --

-- ************************************************************************* --
local function layout_node(node, x, y, width, height)

    node:set_rect(x, y, width, height)

    if node.kind == constants.NodeKind.TEXT then
        assert(0, "Node " .. constants.NodeKindName[node.kind] .. " is not a layout")
        return
    end

    if node.kind == constants.NodeKind.ROW then
        M.row(node, x, y, width, height)
    elseif node.kind == constants.NodeKind.COLUMN then
        M.column(node, x, y, width, height)
    end
end

-- ************************************************************************* --

-- ************************************************************************* --
function M.row(node, x, y, width, height)

    local children = node.children
    local count = #children

    if count == 0 then
        return
    end

    local fixed_width = 0
    local grow_total = 0

    for _, child in ipairs(children) do
        if child.layout.grow ~= nil then
            grow_total = grow_total + child.layout.grow
        else
            fixed_width = fixed_width + requested_width(child)
        end
    end

    local remaining = math.max(0, width - fixed_width)
    local current_x = x

    for _, child in ipairs(children) do
        local child_width

        if child.layout.grow ~= nil and grow_total > 0 then
            child_width = remaining * child.layout.grow / grow_total
        else
            child_width = requested_width(child)
        end

        --local child_height = requested_height(child)

        --child_height = math.min(child_height, height)

        local child_height

        if child.layout.height ~= nil then
            child_height = child.layout.height
        else
            child_height = height
        end

        layout_node(
            child,
            current_x,
            y,
            child_width,
            child_height
        )

        current_x = current_x + child_width
    end
end

-- ************************************************************************* --

-- ************************************************************************* --
function M.column(node, x, y, width, height)

    local children = node.children
    local count = #children

    if count == 0 then
        return
    end

    local fixed_height = 0
    local grow_total = 0

    for _, child in ipairs(children) do
        if child.layout.grow ~= nil then
            grow_total = grow_total + child.layout.grow
        else
            fixed_height = fixed_height + requested_height(child)
        end
    end

    local remaining = math.max(0, height - fixed_height)
    local current_y = y

    for _, child in ipairs(children) do
        local child_height

        if child.layout.grow ~= nil and grow_total > 0 then
            child_height = remaining * child.layout.grow / grow_total
        else
            child_height = requested_height(child)
        end

        --local child_width = requested_width(child)

        --child_width = math.min(child_width, width)

        local child_width

        if child.layout.width ~= nil then
            child_width = child.layout.width
        else
            child_width = width
        end

        layout_node(
            child,
            x,
            current_y,
            child_width,
            child_height
        )

        current_y = current_y + child_height
    end
end

-- ************************************************************************* --

-- ************************************************************************* --
function M.layout(node, x, y, width, height)

    layout_node(node, x, y, width, height)
end

return M
