local test_dir = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])") or "./"
dofile(test_dir .. "setup.lua") -- Executes the path fixer instantly


local tui = require("tui")
local layout = require("tui.layout")

local function check(condition, message, found, expected)
    if not condition then
        error("FAIL: " .. message .. " found: " .. found .. " expected: " .. expected, 2)
    end

    print("PASS: " .. message)
end

local function check_rect(node, x, y, width, height, name)
    check(node.rect.x == x, name .. ": x", node.rect.x, x)
    check(node.rect.y == y, name .. ": y", node.rect.y, y)
    check(node.rect.width == width, name .. ": width", node.rect.width, width)
    check(node.rect.height == height, name .. ": height", node.rect.height, height)
end

print("Testing TUI Layout")
print("------------------")

-- TEXT
local text = tui.text("Hello")

layout.layout(text, 0, 0, 80, 24)

check_rect(text, 0, 0, 80, 24, "text")

-- Text intrinsic dimensions
local intrinsic = tui.text("Hello")

layout.layout(intrinsic, 0, 0, 80, 24)

check(
    #intrinsic.props.text == 5,
    "text intrinsic width"
)

-- Explicit dimensions
local sized = tui.text("Hello", {
    layout = {
        width = 20,
        height = 3,
    },
})

layout.layout(sized, 0, 0, 80, 24)

check_rect(sized, 0, 0, 80, 24, "sized text")

-- COLUMN
local column = tui.column({
    tui.text("Hello"),
    tui.text("World!"),
})

layout.layout(column, 0, 0, 20, 10)

check_rect(column, 0, 0, 20, 10, "column")

check_rect(
    column.children[1],
    0, 0, 5, 1,
    "column first child"
)

check_rect(
    column.children[2],
    0, 1, 6, 1,
    "column second child"
)

-- ROW
local row = tui.row({
    tui.text("Hello"),
    tui.text("World!"),
})

layout.layout(row, 0, 0, 20, 10)

check_rect(row, 0, 0, 20, 10, "row")

check_rect(
    row.children[1],
    0, 0, 5, 1,
    "row first child"
)

check_rect(
    row.children[2],
    5, 0, 6, 1,
    "row second child"
)

-- ROW + GROW
local growing_row = tui.row({
    tui.text("Name"),
    tui.text("Value", {
        layout = {
            grow = 1,
        },
    }),
})

layout.layout(growing_row, 0, 0, 30, 5)

check_rect(
    growing_row.children[1],
    0, 0, 4, 1,
    "growing row fixed child"
)

check_rect(
    growing_row.children[2],
    4, 0, 26, 1,
    "growing row grow child"
)

-- Multiple grow values
local proportional = tui.row({
    tui.text("A", {
        layout = {
            grow = 1,
        },
    }),

    tui.text("B", {
        layout = {
            grow = 2,
        },
    }),
})

layout.layout(proportional, 0, 0, 30, 5)

check_rect(
    proportional.children[1],
    0, 0, 10, 1,
    "proportional first child"
)

check_rect(
    proportional.children[2],
    10, 0, 20, 1,
    "proportional second child"
)

-- COLUMN + GROW
local growing_column = tui.column({
    tui.text("Header"),

    tui.text("Content", {
        layout = {
            grow = 1,
        },
    }),
})

layout.layout(growing_column, 0, 0, 40, 20)

check_rect(
    growing_column.children[1],
    0, 0, 6, 1,
    "growing column fixed child"
)

check_rect(
    growing_column.children[2],
    0, 1, 7, 19,
    "growing column grow child"
)

-- Nested layout
local nested = tui.column({
    tui.text("Header"),

    tui.row({
        tui.text("Left"),

        tui.text("Right", {
            layout = {
                grow = 1,
            },
        }),
    }),
})

layout.layout(nested, 0, 0, 30, 10)

check_rect(
    nested.children[1],
    0, 0, 6, 1,
    "nested header"
)

local nested_row = nested.children[2]

check_rect(
    nested_row,
    0, 1, 30, 9,
    "nested row"
)

check_rect(
    nested_row.children[1],
    0, 1, 4, 1,
    "nested left"
)

check_rect(
    nested_row.children[2],
    4, 1, 26, 1,
    "nested right"
)

print("")
print("All layout tests passed!")
