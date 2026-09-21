-- 1. Find the absolute directory path of this setup file
local current_file = debug.getinfo(1, "S").source:sub(2)

-- 2. Match the path up to the test directory
local project_root = current_file:match("(.*)/lua/tui/test/") or "."

-- 3. Prepend the main project directories to package.path
package.path = project_root .. "/lua/?.lua;" 
            .. project_root .. "/lua/?/init.lua;" 
            .. package.path

return true

