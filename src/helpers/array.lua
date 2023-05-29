-- head(table)
-- e.g: head({1, 2, 3}) -> 1
local function head(tbl)
    return tbl[1]
end

-- tail(table)
-- e.g: tail({1, 2, 3}) -> {2, 3}
local function tail(tbl)
    if #tbl < 1 then
        return nil
    else
        local ret = {}
        for i = 2, #tbl do
            table.insert(ret, tbl[i])
        end
        return ret
    end
end

-- foldr(function, default, table)
-- e.g: foldr(operator.mul, 1, {1,2,3,4,5}) -> 120
local function foldr(tbl, val, func)
    for _, v in pairs(tbl) do
        val = func(val, v)
    end
    return val
end

-- reduce(table, function)
-- e.g: reduce({1,2,3,4}, operator.add) -> 10
local function reduce(tbl, reducer)
    return foldr(tail(tbl), head(tbl), reducer)
end

-- every(table, function)
local function every(tbl, callbackFn)
    for i, v in ipairs(tbl) do
        if not callbackFn(v, i, tbl) then
            return false
        end
    end
    return true
end

return {
    head = head,
    tail = tail,
    reduce = reduce,
    every = every
}
