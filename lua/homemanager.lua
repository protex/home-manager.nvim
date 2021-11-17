local Job = require("plenary.job")
local popup = require("plenary.popup")
local Timer = require("timer")
local Buffer = require("buffer")
local cmd = require("cmd")
local Indicator = require("indicator")

local function createPopup(winHeader)
  local viewHeight = vim.o.lines - vim.o.cmdheight -2
  local viewWidth = vim.o.columns
  local winHeight = math.floor(viewHeight * 0.7)
  local winWidth = math.floor(viewWidth * 0.7)
  local buffer = Buffer:new()

  buffer:replaceLines(0, -1, winHeader)


  popup.create(buffer.bufnr, {
    width = winWidth,
    minheight = winHeight,
    line = math.floor((viewHeight - winHeight) / 2),
    col = math.floor((viewWidth - winWidth) / 2),
    border = true
  })
  return buffer
end


local function updateBufferOnStdWrap(buffer, indicator)
  return function(error, data)
    assert(not error, error)
    indicator:stop()

    buffer:appendLines({data})
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
  local header = {"Running home-manager " .. args[1], "", ""}
  local s = "asdf"
  local buffer = createPopup(header)
  local indicatorLine = 3

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
      indicator:stop()
      buffer:appendLines({"Finished..."})
    end),
  }
end

local function build()
  homeManagerPopup({"build", "--no-out-link"})
end

local function switch()
  homeManagerPopup({"switch"})
end

-- https://github.com/theHamsta/nvim-treesitter/blob/a5f2970d7af947c066fb65aef2220335008242b7/lua/nvim-treesitter/incremental_selection.lua#L22-L30
local function getVisualSelectionRange()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow, cscol, cerow, cecol
  else
    return cerow, cecol, csrow, cscol
  end
end

local function matchOwnerLine(line)
  return line:match([[%s*owner%s*=%s*"([^"]*)";]])
end
local function matchRepoLine(line)
  return line:match([[%s*repo%s*=%s*"([^"]*)";]])
end
local function matchRevLine(line)
  return line:match([[%s*rev%s*=%s*"([^"]*)";]])
end
local function matchShaLine(line)
  return line:match([[%s*sha256%s*=%s*"([^"]*)";]])
end

local function getRepoInfo(buffer)
  vim.cmd("normal [{v]}")
  local top, _, bottom, _ = getVisualSelectionRange()
  local lines = buffer:getLines(top, bottom)
  local lastLineInEntry = -1
  local info = {
    repo = {
      text = "",
      lineNumber = -1
    },
    owner = {
      text = "",
      lineNumber = -1
    },
    rev = {
      text = "",
      lineNumber = -1
    },
    sha256 = {
      text = "",
      lineNumber = -1
    }
  }
  for i=1,#lines do
    local line = lines[i]
    if matchOwnerLine(line) then
      info.owner.text = matchOwnerLine(line)
      info.owner.lineNumber = top + i
      if info.owner.lineNumber > lastLineInEntry then
        lastLineInEntry = info.owner.lineNumber
      end
    elseif matchRepoLine(line) then
      info.repo.text = matchRepoLine(line)
      info.repo.lineNumber = top + i
      if info.repo.lineNumber > lastLineInEntry then
        lastLineInEntry = info.repo.lineNumber
      end
    elseif matchRevLine(line) then
      info.rev.text = matchRevLine(line)
      info.rev.lineNumber = top + i
      if info.rev.lineNumber > lastLineInEntry then
        lastLineInEntry = info.rev.lineNumber
      end
    elseif matchShaLine(line) then
      info.sha256.text = matchShaLine(line)
      info.sha256.lineNumber = top + i
      if info.sha256.lineNumber > lastLineInEntry then
        lastLineInEntry = info.sha256.lineNumber
      end
    end
  end
  return info, lastLineInEntry
end

local function insertSha256(buffer, sha256, lineNumber, replace)
  local shaLine = {'sha256 = "' .. sha256 .. '";'}
  if (replace) then
    buffer:replaceLine(lineNumber, shaLine)
  else
    buffer:appendLines(shaLine, lineNumber)
  end
end

local function shaLineExists(lineNumber)
  return lineNumber > -1
end

local function prefetchSha256()
  local buffer = Buffer:new(vim.fn.bufnr('%'))
  local info, lastLineInEntry = getRepoInfo(buffer)

  local sha256 = cmd.nixPrefetchGit(
    info.owner.text,
    info.repo.text,
    info.rev.text)
  local lineNumber = lastLineInEntry
  local shaLineNumber = info.sha256.lineNumber
  local replace = false
  if shaLineExists(shaLineNumber) then
    lineNumber = shaLineNumber
    replace = true
  end
  insertSha256(buffer, sha256, lineNumber, replace)
  vim.cmd("normal [{v]}=")
end


return {
  build = build,
  switch = switch,
  createPopup = createPopup,
  homeManagerPopup = homeManagerPopup,
  prefetchSha256 = prefetchSha256
}
