local Timer = {}
Timer.__index = Timer

function Timer:new()
  local this = {
    timer = vim.loop.new_timer(),
    started = false
  }

  setmetatable(this, Timer)

  return this
end

function Timer:start(delay, interval, callback)
  self.started = true
  self.timer:start(delay, interval, callback)
end

function Timer:stop(callback)
  if self.started then
    self.started = false
    self.timer:stop()
    if callback then
      callback()
    end
  end
end

return Timer
