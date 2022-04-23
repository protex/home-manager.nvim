local OPTION_REG = vim.regex([[^[-]\+]])
local optionsWithArgs = {
  "-f",
  "-A",
  "-I",
  "--flake",
  "-b",
  "--cores",
  "-j, ",
  "--max-jobs",
  "--builders",
  "--option",
  [[--arg(.*)]]
}
local optionsWithTwoArgs = {
  "--option",
  [[--arg(.*)]]
}
local options = {
  "-f",
  "-A",
  "-I",
  "--flake",
  "-b",
  "-v",
  "-n",
  "-h",
  "--version",
  [[--arg(.*)]],
  "--cores",
  "--debug",
  "--impure",
  "--keep-failed",
  "--keep-going",
  "-j ",
  "--max-jobs",
  "--option",
  "--show-trace",
  "--substitute",
  "--no-substitute",
  "--no-out-link",
  "--no-write-lock-file",
  "--builders"
}
local mainArgs = {
  'help',
  'edit',
  'option',
  'build',
  'instantiate',
  'switch',
  'generations',
  'remove-generations',
  'expire-generations',
  'packages',
  'news',
  'uninstall'
}

local function argIsOption(arg)
  if arg then
    return OPTION_REG:match_str(arg)
  else
    return false
  end
end

local function argIsOptionWithArgs(arg)
  if argIsOption(arg) then
    for _, value in pairs(optionsWithArgs) do
      if vim.regex([[\c]]..value):match_str(arg) then
        return true
      end
    end
  end
  return false
end

local function argIsOptionWithTwoArgs(arg)
  if argIsOption(arg) then
    for _, value in pairs(optionsWithTwoArgs) do
      if vim.regex([[\c]]..value):match_str(arg) then
        return true
      end
    end
  end
  return false
end

local function matchMainArgCompletions(lead)
  local completions = {}
  for _, value in pairs(mainArgs) do
    local reg = vim.regex("^"..lead)
    if reg:match_str(value) then
      table.insert(completions, value)
    end
  end
  return completions
end

local function matchOptionArgCompletions(lead)
  local completions = {}
  for _, value in pairs(options) do
    if vim.regex("^"..lead):match_str(value) then
      table.insert(completions, value)
    end
  end
  return completions
end

local function complete(lead, fullLine, ...)
  local splitLine = {}
  for value in string.gmatch(fullLine, "%S+") do
    table.insert(splitLine, value)
  end

  local previousArg = splitLine[#splitLine-1]
  local twoPreviousArg = splitLine[#splitLine-2]
  if argIsOption(lead)
    and not argIsOptionWithArgs(previousArg)
    and not argIsOptionWithTwoArgs(twoPreviousArg) then
    return matchOptionArgCompletions(lead)
  elseif argIsOptionWithArgs(previousArg) or argIsOptionWithTwoArgs(twoPreviousArg) then
    return {}
  else
    return matchMainArgCompletions(lead)
  end
end

return complete
