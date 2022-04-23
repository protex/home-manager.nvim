local popup = require("plenary.popup")
local Buffer = require("home-manager.buffer")
local cmd = require("home-manager.cmd")
local Indicator = require("home-manager.indicator")
local util = require('home-manager.utils')
local getColorGroup = require('home-manager.colors').getColorGroup

local function createPopup(winHeader)
  local viewHeight = vim.o.lines - vim.o.cmdheight -2
  local viewWidth = vim.o.columns
  local winHeight = math.floor(viewHeight * 0.7)
  local winWidth = math.floor(viewWidth * 0.7)
  local buffer = Buffer:new()


  popup.create(buffer.bufnr, {
    width = winWidth,
    minheight = winHeight,
    line = math.floor((viewHeight - winHeight) / 2),
    col = math.floor((viewWidth - winWidth) / 2),
    border = true,
    title = winHeader
  })
  return buffer
end

local function updateBufferAndStopIndicator(buffer, indicator, data)
  indicator:stop()

  local colorGroup
  if type(data) ~= "table" then
    colorGroup = getColorGroup(data)
    data = {"> " .. data}
  end
  buffer:appendLines(data)
  if colorGroup then
    buffer:colorPos(buffer:info().linecount, 2, string.len(data[1]) - 1, colorGroup)
  end
  buffer:scrollDown()
end

local function updateBufferOnStdWrap(buffer, indicator)
  return function(error, data)
    assert(not error, error)
    updateBufferAndStopIndicator(buffer, indicator, data)
  end
end

local function indicatorGenerator(i)
    local pad = ""
    local padAmount = 0
    if i % 10 < 5 then
      padAmount = i % 5
    else
      padAmount = 5 - (i % 5)
    end
    for _=1,padAmount do
      pad = pad .. " "
    end
    return pad .. "<=>"
end

local function homeManagerPopup(args)
  local title = "home-manager " .. args[1] .. " output"
  local fullCommand = {"$ home-manager " .. table.concat(args, " "), ""}
  local buffer = createPopup(title)
  local indicatorLine = #fullCommand

  buffer:replaceLines(0, -1, fullCommand)

  local indicator = Indicator:new(
    buffer,
    indicatorLine,
    indicatorGenerator,
    {delay = 0, interval = 200})
  indicator:start()

  cmd.homeManager {
    args = args,
    on_stderr = vim.schedule_wrap(updateBufferOnStdWrap(buffer, indicator)),
    on_stdout = vim.schedule_wrap(updateBufferOnStdWrap(buffer, indicator)),
    on_exit = vim.schedule_wrap(function()
      updateBufferAndStopIndicator(buffer, indicator, {"", "Finished..."})
    end),
  }
end

local function homeManager(...)
  homeManagerPopup({...})
end

local function prefetchSha256()
  local buffer = Buffer:new(vim.fn.bufnr('%'))
  local info, lastLineInEntry = util.getRepoInfo(buffer)

  local sha256 = cmd.nixPrefetchGit(
    info.owner.text,
    info.repo.text,
    info.rev.text)
  local lineNumber = lastLineInEntry
  local shaLineNumber = info.sha256.lineNumber
  local replace = false
  if util.shaLineExists(shaLineNumber) then
    lineNumber = shaLineNumber
    replace = true
  end
  util.insertSha256(buffer, sha256, lineNumber, replace)
  vim.cmd("normal [{v]}=")
end


return {
  createPopup = createPopup,
  homeManagerPopup = homeManagerPopup,
  prefetchSha256 = prefetchSha256,
  homeManager = homeManager
}
