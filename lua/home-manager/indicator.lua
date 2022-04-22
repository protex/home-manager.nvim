local Timer = require('home-manager.timer')

Indicator = {}
Indicator.__index = Indicator

function Indicator:new(buffer, lineNumber, generator, timerOptions)
  local this = {
    timer = Timer:new(),
    timerOptions = {
      delay = timerOptions.delay or 0,
      interval = timerOptions.interval or 0,
      generator = generator
    },
    lineNumber = lineNumber,
    buffer = buffer,
    index = 0
  }

  setmetatable(this, Indicator)
  return this
end

function Indicator:start()
  self.timer:start(
    self.timerOptions.delay,
    self.timerOptions.interval,
    vim.schedule_wrap(function()
      local genteratedLine = self.timerOptions.generator(self.index)
      self.buffer:replaceLine(self.lineNumber, genteratedLine)
      self.index = self.index + 1
    end)
  )
end

function Indicator:stop()
  self.timer:stop(function()
    self.buffer:deleteLine(self.lineNumber)
  end)
end

return Indicator
