local lu = require('test.luaunit')
local reselect = require('src.reselect')

TestReselect = {} -- class

function TestReselect:test_defaultEqualityCheck()
    lu.assertIsTrue(reselect._defaultEqualityCheck(1, 1))
    lu.assertIsTrue(reselect._defaultEqualityCheck(2, 2))
    lu.assertIsFalse(reselect._defaultEqualityCheck(1, 2))
    lu.assertIsFalse(reselect._defaultEqualityCheck({}, {})) -- shallow
end

function TestReselect:test_areArgumentsShallowlyEqual()
    lu.assertIsTrue(reselect._areArgumentsShallowlyEqual(reselect._defaultEqualityCheck, {1, 2, 3}, {1, 2, 3}))
    lu.assertIsFalse(reselect._areArgumentsShallowlyEqual(reselect._defaultEqualityCheck, {1, 2, 3}, {1, 2}))
    lu.assertIsFalse(reselect._areArgumentsShallowlyEqual(reselect._defaultEqualityCheck, {1, 2, 3}, {1, 2, 4}))
    lu.assertIsFalse(reselect._areArgumentsShallowlyEqual(reselect._defaultEqualityCheck, {1, 2, 3}, nil))
    lu.assertIsFalse(reselect._areArgumentsShallowlyEqual(reselect._defaultEqualityCheck, {1, 2, 3}, {1, 3, 2}))
end

function TestReselect:test_defaultMemoize()
    local count = 0
    function sum3(a, b, c)
        count = count + 1
        return a + b + c
    end
    local memoizedSum3 = reselect.defaultMemoize(sum3);

    lu.assertEquals(count, 0)
    lu.assertEquals(memoizedSum3(1, 2, 3), 6);
    lu.assertEquals(count, 1)
    lu.assertEquals(memoizedSum3(1, 2, 3), 6);
    lu.assertEquals(count, 1) -- The parameters are the same, no longer calculated
    lu.assertEquals(memoizedSum3(1, 2, 3), 6);
    lu.assertEquals(count, 1) -- The parameters are the same, no longer calculated
    lu.assertEquals(memoizedSum3(1, 2, 4), 7);
    lu.assertEquals(count, 2)
    lu.assertEquals(memoizedSum3(1, 2, 4), 7);
    lu.assertEquals(count, 2) -- The parameters are the same, no longer calculated
    lu.assertEquals(memoizedSum3(1, 2, 4), 7);
    lu.assertEquals(count, 2) -- The parameters are the same, no longer calculated
    lu.assertEquals(memoizedSum3(1, 2, 3), 6);
    lu.assertEquals(count, 3)
    lu.assertEquals(memoizedSum3(1, 2, 3), 6);
    lu.assertEquals(count, 3) -- The parameters are the same, no longer calculated
end

function TestReselect:test_createSelector()
    local count, countA, countB, countC = 0, 0, 0, 0
    local selector = reselect.createSelector(function(state)
        countA = countA + 1
        return state.a
    end, function(state)
        countB = countB + 1
        return state.b
    end, function(state)
        countC = countC + 1
        return state.c
    end, function(a, b, c)
        count = count + 1
        return a + b + c
    end)

    local state1 = {
        a = 1,
        b = 2,
        c = 3
    }
    lu.assertEquals(selector(state1), 6)
    lu.assertEquals(countA, 1)
    lu.assertEquals(countB, 1)
    lu.assertEquals(countC, 1)
    lu.assertEquals(count, 1)
    lu.assertEquals(selector(state1), 6)
    lu.assertEquals(countA, 1)
    lu.assertEquals(countB, 1)
    lu.assertEquals(countC, 1)
    lu.assertEquals(count, 1)
    lu.assertEquals(selector(state1), 6)
    lu.assertEquals(countA, 1)
    lu.assertEquals(countB, 1)
    lu.assertEquals(countC, 1)
    lu.assertEquals(count, 1)

    state1.a = 4

    -- Do not recalculate if the reference does not change
    lu.assertEquals(selector(state1), 6)
    lu.assertEquals(countA, 1)
    lu.assertEquals(countB, 1)
    lu.assertEquals(countC, 1)
    lu.assertEquals(count, 1)

    local state2 = {
        a = 1,
        b = 2,
        c = 3
    }
    lu.assertEquals(selector(state2), 6)
    lu.assertEquals(countA, 2)
    lu.assertEquals(countB, 2)
    lu.assertEquals(countC, 2)
    lu.assertEquals(count, 1) -- Parameters have not changed, so no recalculation

    local state3 = {
        a = 1,
        b = 2,
        c = 4
    }
    lu.assertEquals(selector(state3), 7)
    lu.assertEquals(countA, 3)
    lu.assertEquals(countB, 3)
    lu.assertEquals(countC, 3)
    lu.assertEquals(count, 2)
    lu.assertEquals(selector(state3), 7)
    lu.assertEquals(countA, 3)
    lu.assertEquals(countB, 3)
    lu.assertEquals(countC, 3)
    lu.assertEquals(count, 2)
    lu.assertEquals(selector(state3), 7)
    lu.assertEquals(countA, 3)
    lu.assertEquals(countB, 3)
    lu.assertEquals(countC, 3)
    lu.assertEquals(count, 2)
end
