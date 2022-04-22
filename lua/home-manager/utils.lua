local function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
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

return {
  tableConcat = tableConcat,
  getRepoInfo = getRepoInfo,
  insertSha256 = insertSha256,
  shaLineExists = shaLineExists
}

