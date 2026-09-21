local test_dir = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])") or "./"
dofile(test_dir .. "setup.lua") -- Executes the path fixer instantly

local tui = require("tui")
local constants = require("tui.constants")

local function check(condition, message)
    if not condition then
        error("FAIL: " .. message, 2)
    end

    print("PASS: " .. message)
end

print("Testing TUI Node API")
print("--------------------")

-- Node kinds
check(constants.NodeKind.TEXT == 1, "TEXT kind")
check(constants.NodeKind.ROW == 2, "ROW kind")
check(constants.NodeKind.COLUMN == 3, "COLUMN kind")

check(constants.NodeKindName[constants.NodeKind.TEXT] == "text", "TEXT reverse mapping")
check(constants.NodeKindName[constants.NodeKind.ROW] == "row", "ROW reverse mapping")
check(constants.NodeKindName[constants.NodeKind.COLUMN] == "column", "COLUMN reverse mapping")

-- Text node
local text = tui.text("Hello")

check(text.kind == constants.NodeKind.TEXT, "text node has correct kind")
check(text.props.text == "Hello", "text property is stored")
check(text.parent == nil, "root text has no parent")
check(text:is_leaf(), "text node is a leaf")
check(#text.children == 0, "text node has no children")

-- Node data
local data = {
    id = 42,
    path = "/project/main.cpp",
}

local text_with_data = tui.text("main.cpp", {
    data = data,
})

check(text_with_data.data == data, "user data is preserved")
check(text_with_data.data.id == 42, "user data is accessible")
check(text_with_data.data.path == "/project/main.cpp", "user data fields are preserved")

-- Layout properties
local growing_text = tui.text("Growing", {
    layout = {
        grow = 1,
    },
})

check(growing_text.layout.grow == 1, "layout properties are preserved")

-- Custom rendering
local render_called = false

local custom_text = tui.text("Custom", {
    render = function(node, renderer)
        render_called = true
    end,
})

check(type(custom_text.render_fn) == "function", "custom render function is stored")

custom_text.render_fn(custom_text, nil)

check(render_called, "custom render function can be called")

-- Children
local first = tui.text("First")
local second = tui.text("Second")

local column = tui.column({
    first,
    second,
})

check(column.kind == constants.NodeKind.COLUMN, "column has correct kind")
check(not column:is_leaf(), "column is not a leaf")
check(#column.children == 2, "column has two children")

check(column.children[1] == first, "first child is preserved")
check(column.children[2] == second, "second child is preserved")

check(first.parent == column, "first child has correct parent")
check(second.parent == column, "second child has correct parent")

-- Nested tree
local nested = tui.column({
    tui.text("Top"),

    tui.row({
        tui.text("Left"),
        tui.text("Right"),
    }),
})

check(#nested.children == 2, "nested column has two children")

local row = nested.children[2]

check(row.kind == constants.NodeKind.ROW, "nested row has correct kind")
check(row.parent == nested, "nested row has correct parent")
check(#row.children == 2, "nested row has two children")
check(row.children[1].parent == row, "nested first child has correct parent")
check(row.children[2].parent == row, "nested second child has correct parent")

-- add()
local parent = tui.column({})
local child = tui.text("Added")

local returned = parent:add(child)

check(returned == parent, "add() returns the parent node")
check(#parent.children == 1, "add() adds a child")
check(parent.children[1] == child, "added child is preserved")
check(child.parent == parent, "added child gets correct parent")

-- Rectangle
local rect_node = tui.text("Rectangle")

local returned_rect = rect_node:set_rect(10, 20, 100, 30)

check(returned_rect == rect_node, "set_rect() returns the node")
check(rect_node.rect.x == 10, "rect.x")
check(rect_node.rect.y == 20, "rect.y")
check(rect_node.rect.width == 100, "rect.width")
check(rect_node.rect.height == 30, "rect.height")

-- State
check(type(rect_node.state) == "table", "state is initialized")
check(rect_node.state ~= rect_node.data, "state and data are separate")

rect_node.state.focused = true

check(rect_node.state.focused == true, "state can hold runtime information")
check(rect_node.data ~= rect_node.state, "state remains separate from data")

print("")
print("All tests passed!")


local function dump(node, depth)
    depth = depth or 0

    local indent = string.rep("  ", depth)
    local name = constants.NodeKindName[node.kind]

    print(string.format(
        "%s%s",
        indent,
        name
    ))

    for _, child in ipairs(node.children) do
        dump(child, depth + 1)
    end
end

print("")
print("UI tree:")
print("--------")

dump(nested)

