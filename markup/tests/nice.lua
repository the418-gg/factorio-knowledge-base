local serpent = require("serpent")

do
  local paths = {}
  for str in string.gmatch(package.path, "([^;]+)") do
    table.insert(paths, str)
  end
  local path = debug.getinfo(1, "S").source:sub(2, -10)
  paths[#paths + 1] = path .. "?.lua"
  paths[#paths + 1] = path .. "?/init.lua"
  paths[#paths + 1] = "./?/init.lua"
  paths[#paths + 1] = "../?.lua"
  paths[#paths + 1] = "../?/init.lua"
  paths[#paths + 1] = "../../?.lua"
  paths[#paths + 1] = "../../?/init.lua"

  local patterns = { "^%./%?", "^%.%.", "^/h", "^/u", "." }
  local function special_sort(a, b)
    for _, pattern in ipairs(patterns) do
      local A = string.find(a, pattern)
      local B = string.find(b, pattern)
      if A and not B then
        return true
      end
      if B and not A then
        return false
      end
      if A and B then
        return a < b
      end
    end
    return false
  end
  table.sort(paths, special_sort)
  package.path = table.concat(paths, ";")
end
local function mod_searcher(original)
  -- First search for `modname.some.path`
  local modname = original:gsub("%_%_([%w_]+)%_%_", "%1")
  local filepath = package.searchpath(modname, package.path, ".", "/")
  if not filepath then
    -- Then search for `some.path`
    modname = original:gsub("%_%_([%w_]+)%_%_[%.%\\]", "")
    filepath = package.searchpath(modname, package.path, ".", "/")
    if not filepath then
      return nil
    end
  end
  local loader = loadfile(filepath)
  return loader
end
table.insert(package.searchers, mod_searcher)

local lexer = require("__the418_kb__/markup/parser/lexer")
local parser = require("__the418_kb__/markup/parser/parser")

--- @param input string
--- @return AST
local function parse(input)
  return parser.new(lexer.new(input)):parse_document()
end

describe("FactorioMark", function()
  it("should parse markdown", function()
    local ast = parse("## Heading 2\n\n**kek** pek")
    assert.are.same(ast, {
      {
        kind = "HEADING",
        level = 2,
        children = {
          { kind = "TEXT", text = "Heading 2" },
        },
      },
      {
        kind = "PARAGRAPH",
        children = {
          {
            kind = "EMPHASISED_TEXT",
            emphasis = "BOLD",
            children = {
              { kind = "TEXT", text = "kek" },
            },
          },
          { kind = "TEXT", text = " pek" },
        },
      },
    })
  end)

  describe("paragraphs", function()
    it("should parse paragraphs", function()
      local ast = parse([[
Line 1
same line as line 1

Paragraph 2\
after line break

Another paragraph]])

      assert.are.same(ast, {
        {
          kind = "PARAGRAPH",
          children = {
            { kind = "TEXT", text = "Line 1" },
            { kind = "SOFT_BREAK" },
            { kind = "TEXT", text = "same line as line 1" },
          },
        },
        {
          kind = "PARAGRAPH",
          children = {
            { kind = "TEXT", text = "Paragraph 2" },
            { kind = "LINE_BREAK" },
            { kind = "TEXT", text = "after line break" },
          },
        },
        {
          kind = "PARAGRAPH",
          children = {
            {
              kind = "TEXT",
              text = "Another paragraph",
            },
          },
        },
      })
    end)
  end)

  describe("lists", function()
    it("parses unordered lists", function()
      local ast =
        parse("- list item 1\n- list item 2\n- list item 3 **(multiline)**\\\nline 2\\\nline 3")

      assert.are.same(ast, {
        {
          kind = "LIST",
          level = 1,
          list_type = "UNORDERED",
          items = {
            {
              kind = "PARAGRAPH",
              children = {
                { kind = "TEXT", text = "list item 1" },
                { kind = "SOFT_BREAK" },
              },
            },
            {
              kind = "PARAGRAPH",
              children = {
                { kind = "TEXT", text = "list item 2" },
                { kind = "SOFT_BREAK" },
              },
            },
            {
              kind = "PARAGRAPH",
              children = {
                { kind = "TEXT", text = "list item 3 " },
                {
                  kind = "EMPHASISED_TEXT",
                  emphasis = "BOLD",
                  children = {
                    {
                      kind = "TEXT",
                      text = "(multiline)",
                    },
                  },
                },
                { kind = "LINE_BREAK" },
                { kind = "TEXT", text = "line 2" },
                { kind = "LINE_BREAK" },
                { kind = "TEXT", text = "line 3" },
              },
            },
          },
        },
      })
    end)

    it("parses nested lists #only", function()
      local ast = parse([[
- kek
- ### pek
  - nested 1
    - nested 1.1
    - nested 1.2
  - nested 2
  - nested 3
    - nested 3.1
- wow]])

      assert.are.same(ast, {
        {
          kind = "LIST",
          level = 1,
          list_type = "UNORDERED",
          items = {
            {
              kind = "PARAGRAPH",
              children = {
                { kind = "TEXT", text = "kek" },
                { kind = "SOFT_BREAK" },
              },
            },
            {
              kind = "HEADING",
              level = 3,
              children = {
                { kind = "TEXT", text = "pek" },
                { kind = "SOFT_BREAK" },
              },
            },
            {
              kind = "LIST",
              level = 2,
              list_type = "UNORDERED",
              items = {
                {
                  kind = "PARAGRAPH",
                  children = {
                    { kind = "TEXT", text = "nested 1" },
                    { kind = "SOFT_BREAK" },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "UNORDERED",
                  items = {
                    {
                      kind = "PARAGRAPH",
                      children = {
                        { kind = "TEXT", text = "nested 1.1" },
                        { kind = "SOFT_BREAK" },
                      },
                    },
                    {
                      kind = "PARAGRAPH",
                      children = {
                        { kind = "TEXT", text = "nested 1.2" },
                        { kind = "SOFT_BREAK" },
                      },
                    },
                  },
                },
                {
                  kind = "PARAGRAPH",
                  children = {
                    { kind = "TEXT", text = "nested 2" },
                    { kind = "SOFT_BREAK" },
                  },
                },
                {
                  kind = "PARAGRAPH",
                  children = {
                    { kind = "TEXT", text = "nested 3" },
                    { kind = "SOFT_BREAK" },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "UNORDERED",
                  items = {
                    {
                      kind = "PARAGRAPH",
                      children = {
                        { kind = "TEXT", text = "nested 3.1" },
                        { kind = "SOFT_BREAK" },
                      },
                    },
                  },
                },
              },
            },
            {
              kind = "PARAGRAPH",
              children = {
                { kind = "TEXT", text = "wow" },
              },
            },
          },
        },
      })
    end)
  end)
end)
