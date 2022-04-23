local defaultHighlights = {
  {
    groupName = 'HomeManagerInfo',
    color = 'cyan',
    reg = '^Activating'
  },
  {
    groupName = 'ErrorMsg',
    reg = '[Ee]rror'
  },
  {
    groupName = 'WarningMsg',
    reg = '[Ww]arning'
  }
}
local highlights = defaultHighlights

local function mergeDefaultAndUserHighlights()
  highlights = defaultHighlights;
  for _, highlightConf in pairs(vim.g.HomeManagerHighlights or {}) do
    table.insert(highlights, highlightConf)
  end
  return highlights
end

local function loadColorHighlights()
  mergeDefaultAndUserHighlights()
  for _, highlightConf in pairs(highlights) do
    if vim.fn.hlexists(highlightConf.groupName) == 0 then
      local cmd = "highlight " .. highlightConf.groupName .. " " .. "guifg=" .. highlightConf.color
      vim.cmd(cmd)
    end
  end
end

local function getColorGroup(line)
  for _, highlightConf in pairs(highlights) do
    local reg = vim.regex(highlightConf.reg)
    if reg:match_str(line) then
      return highlightConf.groupName
    end
  end
  return nil
end


return {
  getColorGroup = getColorGroup,
  loadColorHighlights = loadColorHighlights
}
