local test_dir = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])") or "./"
dofile(test_dir .. "setup.lua") -- Executes the path fixer instantly


local tui = require("tui")
local layout = require("tui.layout")
local constants = require("tui.constants")

local passed = 0
local failed = 0

local function fail(message)
    error(message, 2)
end

local function equal(actual, expected, message)
    if actual ~= expected then
        fail(("%s: expected %s, got %s"):format(
            message,
            tostring(expected),
            tostring(actual)
        ))
    end
end

local function rect(node, x, y, width, height, label)
    label = label or "rect"

    equal(node.rect.x, x, label .. ".x")
    equal(node.rect.y, y, label .. ".y")
    equal(node.rect.width, width, label .. ".width")
    equal(node.rect.height, height, label .. ".height")
end

local function test(name, fn)
    local ok, err = pcall(fn)

    if ok then
        passed = passed + 1
        print("PASS " .. name)
    else
        failed = failed + 1
        print("FAIL " .. name)
        print("     " .. tostring(err))
    end
end

local function run(node, width, height, x, y)
    layout.layout(node, x or 0, y or 0, width, height)
    return node
end

local function opts(layout_props)
    return { layout = layout_props or {} }
end

local function text(value, layout_props)
    return tui.text(value, opts(layout_props))
end

local function row(children, layout_props)
    return tui.row(children, opts(layout_props))
end

local function column(children, layout_props)
    return tui.column(children, opts(layout_props))
end

local function assert_constants()
    assert(constants.NodeKind.TEXT ~= nil, "missing NodeKind.TEXT")
    assert(constants.NodeKind.ROW ~= nil, "missing NodeKind.ROW")
    assert(constants.NodeKind.COLUMN ~= nil, "missing NodeKind.COLUMN")
    assert(constants.Align.START ~= nil, "missing Align.START")
    assert(constants.Align.CENTER ~= nil, "missing Align.CENTER")
    assert(constants.Align.END ~= nil, "missing Align.END")
    assert(constants.Align.STRETCH ~= nil, "missing Align.STRETCH")
    assert(constants.Place ~= nil, "missing Place constants")
    assert(constants.Place.START ~= nil, "missing Place.START")
    assert(constants.Place.CENTER ~= nil, "missing Place.CENTER")
    assert(constants.Place.END ~= nil, "missing Place.END")
    assert(constants.Place.STRETCH ~= nil, "missing Place.STRETCH")
end

test("constants expose node kinds and align/place values", function()
    assert_constants()
end)

test("text gets its intrinsic size", function()
    local child = tui.text("hello")
    local root = tui.row({ child })

    layout.layout(root, 0, 0, 20, 4)

    rect(root, 0, 0, 20, 4, "root")
    rect(child, 0, 0, 5, 1, "text")
end)

test("empty text has zero width and one row of height", function()
    local child = tui.text("")
    local root = tui.row({ child })

    layout.layout(root, 0, 0, 10, 3)

    rect(child, 0, 0, 0, 1, "empty text")
end)

test("empty row does not lay out children", function()
    local node = row({})
    run(node, 12, 4)
    rect(node, 0, 0, 12, 4, "empty row")
end)

test("empty column does not lay out children", function()
    local node = column({})
    run(node, 12, 4)
    rect(node, 0, 0, 12, 4, "empty column")
end)

test("row places fixed-size children from the start by default", function()
    local first = text("abc")
    local second = text("de")
    local node = row({ first, second })

    run(node, 12, 3)

    rect(first, 0, 0, 3, 1, "first")
    rect(second, 3, 0, 2, 1, "second")
end)

test("column places fixed-size children from the start by default", function()
    local first = text("abc")
    local second = text("de")
    local node = column({ first, second })

    run(node, 8, 6)

    rect(first, 0, 0, 3, 1, "first")
    rect(second, 0, 1, 2, 1, "second")
end)

test("row grow distributes remaining width proportionally", function()
    local first = text("fixed")
    local second = text("a", { grow = 1 })
    local third = text("b", { grow = 2 })
    local node = row({ first, second, third })

    run(node, 20, 3)

    -- Fixed width = 5; remaining width = 15; grow weights = 1:2.
    rect(first, 0, 0, 5, 1, "fixed")
    rect(second, 5, 0, 5, 1, "grow 1")
    rect(third, 10, 0, 10, 1, "grow 2")
end)

test("column grow distributes remaining height proportionally", function()
    local first = text("fixed")
    local second = text("a", { grow = 1 })
    local third = text("b", { grow = 2 })
    local node = column({ first, second, third })

    run(node, 10, 10)

    -- Fixed height = 1; remaining height = 9; grow weights = 1:2.
    rect(first, 0, 0, 5, 1, "fixed")
    rect(second, 0, 1, 10, 3, "grow 1")
    rect(third, 0, 4, 10, 6, "grow 2")
end)

test("nested row grows to fill its parent column", function()
    local header = text("header")
    local left = text("left")
    local right = text("right", { grow = 1 })
    local content = row({ left, right }, { grow = 1 })
    local root = column({ header, content })

    run(root, 30, 10)

    rect(header, 0, 0, 6, 1, "header")
    rect(content, 0, 1, 30, 9, "content row")
    rect(left, 0, 1, 4, 1, "left")
    rect(right, 4, 1, 26, 1, "right")
end)

test("nested column grows to fill its parent row", function()
    local left = column({
        text("a"),
        text("bb"),
    }, { grow = 1 })
    local right = text("right")
    local root = row({ left, right })

    run(root, 20, 6)

    rect(left, 0, 0, 15, 6, "left column")
    rect(left.children[1], 0, 0, 15, 1, "left first child")
    rect(left.children[2], 0, 1, 15, 1, "left second child")
    rect(right, 15, 0, 5, 1, "right text")
end)

test("row align CENTER positions the fixed-size group on the main axis", function()
    local first = text("abc")
    local second = text("de")
    local node = row({ first, second }, { align = constants.Align.CENTER })

    run(node, 12, 3)

    rect(first, 3, 0, 3, 1, "first")
    rect(second, 6, 0, 2, 1, "second")
end)

test("row align END positions the fixed-size group at the end", function()
    local first = text("abc")
    local second = text("de")
    local node = row({ first, second }, { align = constants.Align.END })

    run(node, 12, 3)

    rect(first, 7, 0, 3, 1, "first")
    rect(second, 10, 0, 2, 1, "second")
end)

test("column align CENTER positions the fixed-size group on the main axis", function()
    local first = text("abc")
    local second = text("de")
    local node = column({ first, second }, { align = constants.Align.CENTER })

    run(node, 8, 8)

    rect(first, 0, 2, 3, 1, "first")
    rect(second, 0, 3, 2, 1, "second")
end)

test("column align END positions the fixed-size group at the end", function()
    local first = text("abc")
    local second = text("de")
    local node = column({ first, second }, { align = constants.Align.END })

    run(node, 8, 8)

    rect(first, 0, 5, 3, 1, "first")
    rect(second, 0, 6, 2, 1, "second")
end)

test("row place CENTER centers a child on the cross axis", function()
    local child = column({ text("x") })
    local node = row({ child }, { place = constants.Place.CENTER })

    run(node, 10, 8)

    rect(child, 0, 3, 1, 1, "child column")
end)

test("row place END places a child at the cross-axis end", function()
    local child = column({ text("x") })
    local node = row({ child }, { place = constants.Place.END })

    run(node, 10, 8)

    rect(child, 0, 7, 1, 1, "child column")
end)

test("column place CENTER centers a child on the cross axis", function()
    local child = row({ text("x") })
    local node = column({ child }, { place = constants.Place.CENTER })

    run(node, 10, 6)

    rect(child, 4, 0, 1, 1, "child row")
end)

test("column place END places a child at the cross-axis end", function()
    local child = row({ text("x") })
    local node = column({ child }, { place = constants.Place.END })

    run(node, 10, 6)

    rect(child, 9, 0, 1, 1, "child row")
end)

test("place STRETCH stretches container children across the cross axis", function()
    local child_row = row({ text("x") })
    local node = column({ child_row }, { place = constants.Place.STRETCH })

    run(node, 10, 6)

    rect(child_row, 0, 0, 10, 1, "child row")
end)

test("place STRETCH does not stretch text intrinsic height", function()
    local child = text("x")
    local node = row({ child }, { place = constants.Place.STRETCH })

    run(node, 10, 6)

    rect(child, 0, 0, 1, 1, "text child")
end)

test("explicit child width and height override intrinsic dimensions", function()
    local child = text("abc", { width = 7, height = 3 })
    local node = row({ child })

    run(node, 15, 8)

    rect(child, 0, 0, 7, 3, "explicit-size text")
end)

test("row padding offsets children and reduces content width", function()
    local first = text("a")
    local second = text("b", { grow = 1 })
    local node = row(
        { first, second },
        { padding = { top = 1, right = 2, bottom = 1, left = 3 } }
    )

    run(node, 20, 6)

    -- Content rect: x=3, y=1, width=15, height=4.
    -- One fixed column leaves 14 columns for the growing child.
    rect(first, 3, 1, 1, 1, "first")
    rect(second, 4, 1, 14, 1, "second")
end)

test("column padding offsets children and reduces content height", function()
    local first = text("a")
    local second = text("b", { grow = 1 })
    local node = column(
        { first, second },
        { padding = { top = 2, right = 1, bottom = 1, left = 3 } }
    )

    run(node, 12, 10)

    -- Content rect: x=3, y=2, width=8, height=7.
    -- One fixed row leaves 6 rows for the growing child.
    rect(first, 3, 2, 1, 1, "first")
    rect(second, 3, 3, 1, 6, "second")
end)

test("numeric padding applies equally on every side", function()
    local child = text("x")
    local node = row({ child }, { padding = 2 })

    run(node, 12, 8)

    rect(child, 2, 2, 1, 1, "child")
end)

test("align CENTER does not create a negative offset on overflow", function()
    local first = text("123456")
    local second = text("7890")
    local node = row({ first, second }, { align = constants.Align.CENTER })

    run(node, 8, 3)

    -- Fixed content is wider than the container, so positioning starts at x=0.
    rect(first, 0, 0, 6, 1, "first")
    rect(second, 6, 0, 4, 1, "second")
end)

test("align END does not create a negative offset on overflow", function()
    local first = text("123456")
    local second = text("7890")
    local node = column({ first, second }, { align = constants.Align.END })

    run(node, 8, 1)

    -- Fixed content is taller than the container, so positioning starts at y=0.
    rect(first, 0, 0, 6, 1, "first")
    rect(second, 0, 1, 4, 1, "second")
end)

test("non-zero origin is preserved throughout nested layout", function()
    local first = text("a")
    local second = text("b")
    local child = row({ first, second })
    local root = column({ child })

    run(root, 10, 5, 7, 4)

    rect(root, 7, 4, 10, 5, "root")
    rect(child, 7, 4, 10, 1, "child row")
    rect(first, 7, 4, 1, 1, "first")
    rect(second, 8, 4, 1, 1, "second")
end)

print(("\nLayout tests: %d passed, %d failed"):format(passed, failed))

if failed > 0 then
    error(("%d layout test(s) failed"):format(failed))
end
