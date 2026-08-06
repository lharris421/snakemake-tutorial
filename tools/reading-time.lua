--[[
  Put an estimated reading time under each chapter title.

  Quarto's own `reading-time` option only applies to website listing cards, not
  to book pages, so the estimate is computed here from the document Pandoc is
  about to render.

  Prose and code are counted separately, because nobody reads a transcript at
  prose speed: words in paragraphs at WPM, lines of code blocks at LPM.  Both
  are deliberately easy to retune.
--]]

local WPM = 200 -- prose words per minute
local LPM = 30  -- lines of code or terminal output per minute

local words = 0
local code_lines = 0

local function count_lines(text)
  local n = 0
  for _ in text:gmatch("[^\n]+") do
    n = n + 1
  end
  return n
end

-- First pass: tally.  Str only fires on prose, so inline `code` and fenced
-- blocks are excluded from the word count by construction.
local tally = {
  Str = function(el)
    if el.text:find("%w") then
      words = words + 1
    end
  end,

  CodeBlock = function(el)
    code_lines = code_lines + count_lines(el.text)
  end,
}

-- Second pass: insert the estimate after the chapter's level-1 heading.
local insert = {
  Pandoc = function(doc)
    local minutes = math.floor(words / WPM + code_lines / LPM + 0.5)
    if minutes < 1 then
      minutes = 1
    end

    local label = pandoc.Div(
      { pandoc.Plain({ pandoc.Str(minutes .. " min read") }) },
      pandoc.Attr("", { "reading-time" })
    )

    for i, block in ipairs(doc.blocks) do
      if block.t == "Header" and block.level == 1 then
        table.insert(doc.blocks, i + 1, label)
        return doc
      end
    end

    -- No level-1 heading in the body (Quarto lifted it into the title): the
    -- top of the body is directly under the title anyway.
    table.insert(doc.blocks, 1, label)
    return doc
  end,
}

return { tally, insert }
