local utils = {}

-- ************************************************************************* --

-- ************************************************************************* --
function utils.createEnum(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function() 
            error("Attempt to modify a read-only enum", 2) 
        end
    })
end

return utils
