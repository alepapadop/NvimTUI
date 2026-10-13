local constants = require("tui.constants")

local M = {}


-- TEXT
--     intrinsic size = text length × 1
-- 
-- ROW
--     main axis = horizontal
--     fixed children use requested/intrinsic width
--     grow children divide remaining width
--     containers stretch in the cross-axis
-- 
-- COLUMN
--     main axis = vertical
--     fixed children use requested/intrinsic height
--     grow children divide remaining height
--     containers stretch in the cross-axis
-- 
-- GROW is local to its immediate parent

-- align: controls positioning along the main axis
-- place: controls positioning along the cross axis
-- grow: distributes remaining space along the main axis
-- padding: reduces the available content area
-- Container children stretch across the cross axis when place = STRETCH 
-- text children keep their intrinsic size unless explicitly sized.

-- Naming conventions
-- 
-- Container        align               place
-- ROW              Horizontal          Vertical
-- COLUMNG          Verical             Horizontal


-- ************************************************************************* --

-- ************************************************************************* --

local function is_container(node)
    return node.kind == constants.NodeKind.ROW
        or node.kind == constants.NodeKind.COLUMN
end

-- ************************************************************************* --

-- ************************************************************************* --

local function padding(node)
    local value = node.layout.padding

    if value == nil then
        return 0, 0, 0, 0
    end

    if type(value) == "number" then
        return value, value, value, value
    end

    return value.top or 0,
            value.right or 0,
            value.bottom or 0,
            value.left or 0
end

-- ************************************************************************* --

-- ************************************************************************* --

local function align_offset(align, available, size)
    local remaining = math.max(0, available - size)

    if align == constants.Align.CENTER then
        return math.floor(remaining / 2)
    elseif align == constants.Align.END then
        return remaining
    end

    return 0
end


-- ************************************************************************* --

-- ************************************************************************* --
local function base_size(node)

    local width
    local height

    if node.kind == constants.NodeKind.TEXT then
        local text = node.props.text or ""

        width = #text
        height = 1

    elseif node.kind == constants.NodeKind.ROW then
        width = 0
        height = 0

        for _, child in ipairs(node.children) do
            local child_width, child_height = base_size(child)

            width = width + child_width
            height = math.max(height, child_height)
        end

    elseif node.kind == constants.NodeKind.COLUMN then
        width = 0
        height = 0

        for _, child in ipairs(node.children) do
            local child_width, child_height = base_size(child)

            width = math.max(width, child_width)
            height = height + child_height
        end
    else
        return 0, 0
    end

    local top, right, bottom, left = padding(node)

    return width + left + right, height + top + bottom
end

-- ************************************************************************* --

-- ************************************************************************* --
local function requested_width(node)

    if node.layout.width ~= nil then
        return node.layout.width
    end

    local width, _ = base_size(node)

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
--        assert(0, "Node " .. constants.NodeKindName[node.kind] .. " is not a layout")
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

    if #children == 0 then
        return
    end

    local top, right, bottom, left = padding(node)
    local content_x = x + left
    local content_y = y + top
    local content_width = math.max(0, width - left - right)
    local content_height = math.max(0, height - top - bottom)

    local fixed_width = 0
    local grow_total = 0

    -- make the initial calc for the fixed width and also for the total grow request. Those
    -- values will be used later
    for _, child in ipairs(children) do
        if child.layout.grow ~= nil then
            grow_total = grow_total + child.layout.grow
        else
            fixed_width = fixed_width + requested_width(child)
        end
    end

    -- find what remains in order to place also the layouts that have the grow parameter
    local remaining = math.max(0, content_width - fixed_width)
    local main_offset = 0

    local align = node.layout.align or constants.Align.START
    local place = node.layout.place or constants.Place.STRETCH

    -- if no one wants to grow calculate the main offset of the begginning
    if grow_total == 0 then
        main_offset = align_offset(align, content_width, fixed_width)
    end

    -- calculate the current position of x
    local current_x = content_x + main_offset

    for _, child in ipairs(children) do
        local child_width

        -- simple calculation for the width, if we have a grow get the grow that
        -- owns the child from the total grow
        if child.layout.grow ~= nil and grow_total > 0 then
            child_width = remaining * child.layout.grow / grow_total
        else
            child_width = requested_width(child)
        end

        local child_height

        -- if a height exist in the layout get the layout height, if the justify is AUTO get the available size
        -- if nothing get the the size of the content of the layout
        if child.layout.height ~= nil then
            child_height = child.layout.height
        elseif is_container(child) and place == constants.Place.STRETCH then
            child_height = content_height
        else
            child_height = requested_height(child)
        end

        local child_y = content_y

        if place ~= constants.Place.STRETCH and child_height < content_height then
            child_y = content_y + align_offset(place, content_height, child_height)
        end

        layout_node(
            child,
            current_x,
            child_y,
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

    if #children == 0 then
        return
    end

    local top, right, bottom, left = padding(node)

    local content_x = x + left
    local content_y = y + top

    local content_width = math.max(0, width - left - right)
    local content_height = math.max(0, height - top - bottom)


    local fixed_height = 0
    local grow_total = 0

    for _, child in ipairs(children) do
        if child.layout.grow ~= nil then
            grow_total = grow_total + child.layout.grow
        else
            fixed_height = fixed_height + requested_height(child)
        end
    end

    local remaining = math.max(0, content_height - fixed_height)
    local main_offset = 0;

    local align = node.layout.align or constants.Align.START
    local place = node.layout.place or constants.Place.STRETCH

    if grow_total == 0 then
        main_offset = align_offset(align, content_height, fixed_height)
    end

    local current_y = content_y + main_offset



    for _, child in ipairs(children) do
        local child_height

        if child.layout.grow ~= nil and grow_total > 0 then
            child_height = remaining * child.layout.grow / grow_total
        else
            child_height = requested_height(child)
        end

        local child_width

        if child.layout.width ~= nil then
            child_width = child.layout.width
        elseif is_container(child) and place == constants.Place.STRETCH then
            child_width = content_width
        else
            child_width = requested_width(child)
        end

        local child_x = content_x


        if place ~= constants.Place.STRETCH and child_width < content_width then
            child_x = content_x + align_offset(place, content_width, child_width)
        end


        layout_node(
            child,
            child_x,
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
