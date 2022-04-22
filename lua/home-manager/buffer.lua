Buffer = {}
Buffer.__index = Buffer

function Buffer:new(bufnr)
  local this = {
    bufnr = bufnr or vim.api.nvim_create_buf(false, true)
  }
  setmetatable(this, Buffer)
  return this
end


function Buffer:replaceLines(start, finish, replacementLines)
  if type(replacementLines) == 'string' then
    replacementLines = {replacementLines}
  end
  vim.api.nvim_buf_set_lines(self.bufnr, start, finish, true, replacementLines)
end

function Buffer:replaceLine(line, replacementLine)
  if type(replacementLine) == 'string' then
    replacementLine = {replacementLine}
  end
  self:replaceLines(line - 1, line, replacementLine)
end

function Buffer:appendLines(additionalLines, lineNumber)
  if type(additionalLines) == 'string' then
    additionalLines = {additionalLines}
  end
  if not lineNumber then
    lineNumber = -1
  end
  self:replaceLines(lineNumber, lineNumber, additionalLines)
end

function Buffer:deleteLastLineOfBuffer()
  self:deleteLine(-1)
end

function Buffer:deleteLine(line)
  self:replaceLines(line - 1, line, {})
end

function Buffer:getLines(start, finish)
  return vim.api.nvim_buf_get_lines(self.bufnr, start, finish, true)
end

function Buffer:colorLine(line, color)

end

function Buffer:scrollDown()
  vim.api.nvim_buf_call(self.bufnr, function() vim.cmd[[norm ]] end)
end

return Buffer
