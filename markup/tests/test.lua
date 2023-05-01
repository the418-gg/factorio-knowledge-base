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
local function get_mod_name(modname)
  if modname == "the418_kb" then
    return os.getenv("ROOT_DIR_NAME") or "the418_kb"
  else
    return modname
  end
end
local function mod_searcher(original)
  -- First search for `modname.some.path`
  local modname = get_mod_name(original:gsub("%_%_([%w_]+)%_%_", function(name)
    return get_mod_name(name)
  end))
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
    local ast = parse("## Heading 2\n\n---\n**kek** pek")
    assert.are.same(ast, {
      {
        kind = "HEADING",
        level = 2,
        children = {
          { kind = "TEXT", text = "Heading 2" },
        },
      },
      {
        kind = "HORIZONTAL_RULE",
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

  describe("not quite the right items", function()
    it("should parse as text correctly", function()
      local ast = parse([[
#Heading 1
--
nice
-- nice
-wow
1.such]])
      assert.are.same(ast, {
        {
          kind = "PARAGRAPH",
          children = {
            {
              kind = "TEXT",
              text = "#Heading 1",
            },
            { kind = "SOFT_BREAK" },
            {
              kind = "TEXT",
              text = "--",
            },
            { kind = "SOFT_BREAK" },
            {
              kind = "TEXT",
              text = "nice",
            },
            { kind = "SOFT_BREAK" },
            {
              kind = "TEXT",
              text = "-- nice",
            },
            { kind = "SOFT_BREAK" },
            {
              kind = "TEXT",
              text = "-wow",
            },
            { kind = "SOFT_BREAK" },
            {
              kind = "TEXT",
              text = "1.such",
            },
          },
        },
      })
    end)
  end)

  describe("paragraphs", function()
    it("should parse paragraphs", function()
      local ast = parse([[
12 Line 1
same line as line 1

Paragraph 2\
after line break

Another paragraph]])

      assert.are.same(ast, {
        {
          kind = "PARAGRAPH",
          children = {
            { kind = "TEXT", text = "12 Line 1" },
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
              kind = "LIST_ITEM",
              order = 1,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "list item 1" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 2,
              content = {

                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "list item 2" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 3,
              content = {
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
        },
      })
    end)

    it("parses nested unordered lists", function()
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
              kind = "LIST_ITEM",
              order = 1,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "kek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 2,
              content = {
                kind = "HEADING",
                level = 3,
                children = {
                  { kind = "TEXT", text = "pek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST",
              level = 2,
              list_type = "UNORDERED",
              items = {
                {
                  kind = "LIST_ITEM",
                  order = 1,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 1" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "UNORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.1" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                    {
                      kind = "LIST_ITEM",
                      order = 2,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.2" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 2,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 2" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 3,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 3" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "UNORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
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
            },
            {
              kind = "LIST_ITEM",
              order = 3,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "wow" },
                },
              },
            },
          },
        },
      })
    end)

    it("parses ordered lists", function()
      local ast = parse(
        "1. list item 1\n2. list item 2\n345. list item 3 **(multiline)**\\\nline 2\\\nline 3"
      )

      assert.are.same(ast, {
        {
          kind = "LIST",
          level = 1,
          list_type = "ORDERED",
          items = {
            {
              kind = "LIST_ITEM",
              order = 1,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "list item 1" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 2,
              content = {

                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "list item 2" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 3,
              content = {
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
        },
      })
    end)

    it("parses nested ordered lists", function()
      local ast = parse([[
1. kek
2. ### pek
  1. nested 1
    1. nested 1.1
    2. nested 1.2
  2. nested 2
  3. nested 3
    1. nested 3.1
3. wow]])

      assert.are.same(ast, {
        {
          kind = "LIST",
          level = 1,
          list_type = "ORDERED",
          items = {
            {
              kind = "LIST_ITEM",
              order = 1,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "kek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 2,
              content = {
                kind = "HEADING",
                level = 3,
                children = {
                  { kind = "TEXT", text = "pek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST",
              level = 2,
              list_type = "ORDERED",
              items = {
                {
                  kind = "LIST_ITEM",
                  order = 1,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 1" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "ORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.1" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                    {
                      kind = "LIST_ITEM",
                      order = 2,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.2" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 2,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 2" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 3,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 3" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "ORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
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
            },
            {
              kind = "LIST_ITEM",
              order = 3,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "wow" },
                },
              },
            },
          },
        },
      })
    end)

    it("parses nested mixed lists", function()
      local ast = parse([[
1. kek
2. ### pek
  - nested 1
    1. nested 1.1
    2. nested 1.2
  - nested 2
  - nested 3
    - nested 3.1
3. wow]])

      assert.are.same(ast, {
        {
          kind = "LIST",
          level = 1,
          list_type = "ORDERED",
          items = {
            {
              kind = "LIST_ITEM",
              order = 1,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "kek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 2,
              content = {
                kind = "HEADING",
                level = 3,
                children = {
                  { kind = "TEXT", text = "pek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST",
              level = 2,
              list_type = "UNORDERED",
              items = {
                {
                  kind = "LIST_ITEM",
                  order = 1,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 1" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "ORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.1" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                    {
                      kind = "LIST_ITEM",
                      order = 2,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.2" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 2,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 2" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 3,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 3" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "UNORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
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
            },
            {
              kind = "LIST_ITEM",
              order = 3,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "wow" },
                },
              },
            },
          },
        },
      })
    end)

    it("parses nested mixed lists (flipped)", function()
      local ast = parse([[
- kek
- ### pek
  1. nested 1
    - nested 1.1
    - nested 1.2
  2. nested 2
  3. nested 3
    3. nested 3.1
- wow]])

      assert.are.same(ast, {
        {
          kind = "LIST",
          level = 1,
          list_type = "UNORDERED",
          items = {
            {
              kind = "LIST_ITEM",
              order = 1,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "kek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST_ITEM",
              order = 2,
              content = {
                kind = "HEADING",
                level = 3,
                children = {
                  { kind = "TEXT", text = "pek" },
                  { kind = "SOFT_BREAK" },
                },
              },
            },
            {
              kind = "LIST",
              level = 2,
              list_type = "ORDERED",
              items = {
                {
                  kind = "LIST_ITEM",
                  order = 1,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 1" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "UNORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.1" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                    {
                      kind = "LIST_ITEM",
                      order = 2,
                      content = {
                        kind = "PARAGRAPH",
                        children = {
                          { kind = "TEXT", text = "nested 1.2" },
                          { kind = "SOFT_BREAK" },
                        },
                      },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 2,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 2" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST_ITEM",
                  order = 3,
                  content = {
                    kind = "PARAGRAPH",
                    children = {
                      { kind = "TEXT", text = "nested 3" },
                      { kind = "SOFT_BREAK" },
                    },
                  },
                },
                {
                  kind = "LIST",
                  level = 3,
                  list_type = "ORDERED",
                  items = {
                    {
                      kind = "LIST_ITEM",
                      order = 1,
                      content = {
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
            },
            {
              kind = "LIST_ITEM",
              order = 3,
              content = {
                kind = "PARAGRAPH",
                children = {
                  { kind = "TEXT", text = "wow" },
                },
              },
            },
          },
        },
      })
    end)
  end)

  describe("code blocks", function()
    describe("inline code", function()
      it("should parse inline code", function()
        local ast = parse("`let x = 1`")
        assert.are.same(ast, {
          {
            kind = "PARAGRAPH",
            children = {
              { kind = "CODE_INLINE", text = "let x = 1" },
            },
          },
        })
      end)

      it("should be escapable", function()
        local ast = parse("\\`let x = 1`")
        assert.are.same(ast, {
          {
            kind = "PARAGRAPH",
            children = {
              { kind = "TEXT", text = "`let x = 1" },
              { kind = "TEXT", text = "`" },
            },
          },
        })
      end)

      it("should work with unfinished empty code correctly", function()
        local ast = parse("`")
        assert.are.same(ast, {
          {
            kind = "PARAGRAPH",
            children = {
              { kind = "TEXT", text = "`" },
            },
          },
        })
      end)

      it("should work with unfinished inline code correctly", function()
        local ast = parse("`let **x** = 1")
        assert.are.same(ast, {
          {
            kind = "PARAGRAPH",
            children = {
              { kind = "TEXT", text = "`let " },
              {
                kind = "EMPHASISED_TEXT",
                emphasis = "BOLD",
                children = { { kind = "TEXT", text = "x" } },
              },
              { kind = "TEXT", text = " = 1" },
            },
          },
        })
      end)

      it("should parse multiline inline code", function()
        local ast = parse([[
wow `let x = 1 else end
after that begin echo resolve` super cool
]])

        assert.are.same(ast, {
          {
            kind = "PARAGRAPH",
            children = {
              { kind = "TEXT", text = "wow " },
              { kind = "CODE_INLINE", text = "let x = 1 else end" },
              { kind = "LINE_BREAK" },
              { kind = "CODE_INLINE", text = "after that begin echo resolve" },
              { kind = "TEXT", text = " super cool" },
              { kind = "SOFT_BREAK" },
            },
          },
        })
      end)
    end)

    describe("code blocks", function()
      it("should parse code blocks", function()
        local ast = parse([[
```
let x = 1
let y = 2
return x + y
```]])

        assert.are.same(ast, {
          {
            kind = "CODE_BLOCK",
            text = "let x = 1\nlet y = 2\nreturn x + y",
          },
        })
      end)

      it("should be escapable", function()
        local ast = parse([[
\```
let x = 1
```]])
        assert.are.same(ast, {
          {
            kind = "PARAGRAPH",
            children = {
              { kind = "TEXT", text = "`" },
              { kind = "CODE_INLINE", text = "" },
              { kind = "SOFT_BREAK" },
              { kind = "TEXT", text = "let x = 1" },
              { kind = "SOFT_BREAK" },
              { kind = "TEXT", text = "```" },
            },
          },
        })
      end)

      describe("unfinished blocks", function()
        it("should parse correctly when blatantly unfinished", function()
          local ast = parse([[
```
let x = 1]])
          assert.are.same(ast, {
            {
              kind = "CODE_BLOCK",
              text = "let x = 1",
            },
          })
        end)

        it("should parse correctly when only one ` is at the end", function()
          local ast = parse([[
```
let x = 1
`]])
          assert.are.same(ast, {
            {
              kind = "CODE_BLOCK",
              text = "let x = 1\n`",
            },
          })
        end)

        it("should parse correctly when only two ` are at the end", function()
          local ast = parse([[
```
let x = 1
``]])
          assert.are.same(ast, {
            {
              kind = "CODE_BLOCK",
              text = "let x = 1\n``",
            },
          })
        end)

        it("should parse correctly when ```smth is at the end", function()
          local ast = parse([[
```
let x = 1
```nope]])
          assert.are.same(ast, {
            {
              kind = "CODE_BLOCK",
              text = "let x = 1\n```nope",
            },
          })
        end)
      end)
    end)
  end)

  describe("specific cases", function()
    it("should parse content after heading", function()
      local ast = parse([[
# heading 1
---]])

      assert.are.same(ast, {
        {
          kind = "HEADING",
          level = 1,
          children = {
            { kind = "TEXT", text = "heading 1" },
            { kind = "SOFT_BREAK" },
          },
        },
        {
          kind = "HORIZONTAL_RULE",
        },
      })
    end)
  end)
end)
