do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.Units.Test",
    addSpec = function(self, name, func, args)
      table.insert(self.specs, XeninUI.Units.Spec(name, func))

      return self
    end,
    runSpecFunc = function(self, spec)
      local p = XeninUI.Promises.new()

      local success, returnVal = xpcall(spec:getFunc(), debug.traceback, self)
      local result = XeninUI.Units.Result(spec:getName(), success, returnVal)

      if result:isSuccess() then
        if istable(result:getReturn()) then
          result:getReturn():next(function()
            p:resolve(result:getMessagePrint())
          end, function(err)
            result:setSuccess(false)
            result:setError(err or "Promise failedd")
            p:reject(result:getMessagePrint())
          end)
        else
          p:resolve(result:getMessagePrint())
        end
      else
        p:reject(result:getMessagePrint())
      end

      return p
    end,
    setBeforeAll = function(self, func)
      self.beforeAll = func return self end,
    setBeforeEach = function(self, func)
      self.beforeEach = func return self end,
    setAfterEach = function(self, func)
      self.afterEach = func return self end,
    setAfterAll = function(self, func)
      self.afterAll = func return self end,
    finishedTests = function(self, dontPrint)
      if (!dontPrint) then
        for i, v in ipairs(self.msgs) do
          table.insert(v, "\n")
          MsgC(unpack(v))
        end
      end
    end,
    run = function(self, dontPrint)
      self.msgs = {
      {
        Color(255, 255, 255),
        tostring(self.name) .. " should:"
      }
      }

      local p = XeninUI.Promises.new()

      local start = SysTime()
      local errors = 0
      local successes = 0
      local size = #self.specs
      local i = 1
      local function nextFunc()
        self:afterEach()
        i = i + 1
      end
      local function runTest()
        if (i > size) then
          self:afterAll()
          self:finishedTests()

          local ms = math.Round((SysTime() - start) * 1000, 2)
          p:resolve({
            msgs = self.msgs,
            executionTime = ms,
            size = size,
            errors = errors,
            successes = successes
          })
        end

        local tbl = self.specs[i]
        self:beforeEach()
        self:runSpecFunc(tbl):next(function(result)
          successes = successes + 1

          table.insert(self.msgs, result)

          nextFunc()
          runTest()
        end, function(err)
          errors = errors + 1

          table.insert(self.msgs, err)

          nextFunc()
          runTest()
        end)
      end

      local err = self:beforeAll()
      if istable(err) then

        err:next(function()
          runTest()
        end, function(err)
          p:reject(err)
        end)
      else
        if err then
          return p:reject(err)
        end
        runTest()
      end

      return p
    end,
    __type = function(self)
      return self.__name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name)
      self.specs = {}
      self.name = name
      self.beforeAll = function() end
      self.beforeEach = function() end
      self.afterEach = function() end
      self.afterAll = function() end
    end,
    __base = _base_0
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  XeninUI.Units.Test = _class_0
end

function XeninUI:Test(script, printOut, delay)
  if printOut == nil then printOut = true
  end
  local p = XeninUI.Promises.new()
  local tbl = XeninUI.Scripts:get(script)
  if (!tbl) then
    if printOut then MsgC(XeninUI.Theme.Red, "That script doesn't exist\n")end

    return p:reject("That script doesn't exist")
  end
  local tests = tbl.tests
  if (!istable(tests) or (istable(tests) and #tests == 0)) then
    if print then MsgC(XeninUI.Theme.Red, "There are no tests for this script\n")end

    return p:reject("There are no tests for this script")
  end

  XeninUI.IsTesting = script
  local i = 0
  local time = 0
  local passes = 0
  local fails = 0
  local size = 0
  local msgs = {}
  local function nextTest()
    i = i + 1

    local promise = tests[i]
    if (!promise) then
      local successRate = math.Round((passes / size) * 100, 2)
      if printOut then
        MsgC(XeninUI.Theme.Yellow, "Took " .. tostring(time) .. "ms to run " .. tostring(size) .. " specs with " .. tostring(passes) .. " passes, " .. tostring(fails) .. " fails, and a pass rate of " .. tostring(successRate) .. "%\n")
      end

      p:resolve({
        time = time,
        passes = passes,
        fails = fails,
        size = size,
        msgs = msgs
      })

      XeninUI.IsTesting = nil
    else
      promise:run():next(function(result)
        time = time + result.executionTime
        passes = passes + result.successes
        fails = fails + result.errors
        size = size + result.size

        table.insert(msgs, result.msgs)

        if delay then
          timer.Simple(delay, function()
            nextTest()end)
        else
          nextTest()
        end
      end, function(err)
        print("test error", err)
        p:reject(err)
      end)
    end
  end

  nextTest()

  return p
end

concommand.Add("xenin_test", function(ply, cmd, args)
  if (IsValid(ply) and !XeninUI.Permissions:canAccessFramework(ply)) then return end

  XeninUI:Test(args[1], !tobool(args[2]), tonumber(args[3])):next(function(result) end, function(err)
    ErrorNoHalt(err .. "\n")end)
end)
