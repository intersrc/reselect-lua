local function keys(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        ret[#ret + 1] = k;
    end
    return ret
end

local function values(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        ret[#ret + 1] = v;
    end
    return ret
end

return {
    keys = keys,
    values = values
}
