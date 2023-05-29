local directory = string.gsub(..., "/", "."):match("(.-)[^%.]+$")
local Array = require(directory .. 'helpers.array')
local Object = require(directory .. 'helpers.object')

local function defaultEqualityCheck(a, b)
    return a == b;
end

local function areArgumentsShallowlyEqual(equalityCheck, prev, next)
    if (prev == nil or next == nil or #prev ~= #next) then
        return false;
    end

    -- Do this in a for loop (and not a `forEach` or an `every`) so we can determine equality as fast as possible.
    local length = #prev;
    for i = 1, length do
        if (not equalityCheck(prev[i], next[i])) then
            return false;
        end
    end

    return true;
end

local function defaultMemoize(func, equalityCheck)
    equalityCheck = equalityCheck or defaultEqualityCheck

    local lastArgs = nil;
    local lastResult = nil;

    return function(...)
        local arguments = {...}
        if (not areArgumentsShallowlyEqual(equalityCheck, lastArgs, arguments)) then
            lastResult = func(...);
        end

        lastArgs = arguments;
        return lastResult;
    end
end

local function _conditionalOperator(condition, exprIfTrue, exprIfFalse)
    if condition then
        return exprIfTrue
    else
        return exprIfFalse
    end
end
local function getDependencies(funcs)
    local dependencies = _conditionalOperator(type(funcs[1]) ~= 'function' and #funcs[1] > 0, funcs[1], funcs)

    assert(Array.every(dependencies, function(dep)
        return type(dep) == 'function';
    end), 'Selector creators expect all input-selectors to be functions')

    return dependencies;
end

local function createSelectorCreator(memoize, ...)
    local unpack = unpack or table.unpack
    local memoizeOptions = {...}

    return function(...)
        local funcs = {...}

        local recomputations = 0;
        local resultFunc = funcs[#funcs];
        table.remove(funcs, #funcs);
        local dependencies = getDependencies(funcs);

        local memoizedResultFunc = memoize(function(...)
            recomputations = recomputations + 1
            return resultFunc(...);
        end, unpack(memoizeOptions));

        local selector = {};
        selector.resultFunc = resultFunc;
        selector.dependencies = dependencies;
        selector.recomputations = function()
            return recomputations;
        end
        selector.resetRecomputations = function()
            recomputations = 0;
            return recomputations
        end
        setmetatable(selector, {
            -- If a selector is called with the exact same arguments we don't need to traverse our dependencies again.
            __call = memoize(function(sel, ...)
                local params = {}
                local length = #dependencies;

                for i = 1, length do
                    params[#params + 1] = (dependencies[i](...));
                end

                return memoizedResultFunc(unpack(params))
            end)
        })
        return selector;
    end
end

local createSelector = createSelectorCreator(defaultMemoize);

-- TODO: This function has not been tested yet.
local function createStructuredSelector(selectors, selectorCreator)
    selectorCreator = selectorCreator or createSelector;

    assert(type(selectors) == 'table', 'createStructuredSelector expects first argument to be an object ' ..
        ('where each property is a selector, instead received a ' .. type(selectors)))

    local objectKeys = Object.keys(selectors);
    return selectorCreator(objectKeys.map(function(key)
        return selectors[key];
    end), function(...)
        local values = {...}

        return Array.reduce(values, function(composition, value, index)
            composition[objectKeys[index]] = value;
            return composition;
        end, {});
    end);
end

return {
    _defaultEqualityCheck = defaultEqualityCheck,
    _areArgumentsShallowlyEqual = areArgumentsShallowlyEqual,
    _getDependencies = getDependencies,

    defaultMemoize = defaultMemoize,
    createSelectorCreator = createSelectorCreator,
    createStructuredSelector = createStructuredSelector,
    createSelector = createSelector
};
