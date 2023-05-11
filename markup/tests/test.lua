local serpent = require("serpent")
local base64 = require("./tests/support/base64")
local cjson = require("cjson.safe")
local zlib = require("zlib")

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

--- @type SpecialItemDecoder
local special_item_decoder = {}

function special_item_decoder.decode_string(input)
  local base64_decoded = base64.dec(input)

  local stream = zlib.inflate()
  local success, deflated = pcall(function()
    return stream(base64_decoded, "sync")
  end)

  if success then
    return deflated
  end
end

function special_item_decoder.json_to_table(json)
  return cjson.decode(json)
end

--- @param input string
--- @return AST
local function parse(input)
  return parser.new(special_item_decoder, lexer.new(input)):parse_document()
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
              { kind = "TEXT", text = "```\nlet x = 1" },
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

  describe("rich text", function()
    it("should parse rich text", function()
      local ast = parse("[item=iron-plate]")
      assert.are.same(ast, {
        {
          kind = "PARAGRAPH",
          children = {
            { kind = "RICH_TEXT", key = "item", value = "iron-plate" },
          },
        },
      })
    end)

    it("should work correctly when rich text is unfinished", function()
      local ast = parse("[item=iron-plate")

      assert.are.same(ast, {
        {
          kind = "PARAGRAPH",
          children = {
            { kind = "TEXT", text = "[item=iron-plate" },
          },
        },
      })
    end)
  end)

  describe("special items", function()
    it("outputs nothing when content is empty", function()
      local ast = parse("<special-item></special-item>")

      assert.are.same(ast, {})
    end)

    it("outputs nothing when content is invalid #only", function()
      local ast = parse("<special-item>any content that is not a blueprint</special-item>")

      assert.are.same(ast, {})
    end)

    describe("blueprints", function()
      it("works", function()
        local ast = parse([[<special-item>
0eNqVlMFuwyAMhl8l8plIhbRNw3G7TTvsPk0Tad0OiUAEZFoU5d0H6VRFG9LKgYNB/2f/BjNBqwbsrdQe+ATyaLQD/jqBkxctVNzzY4/AQXrsgIAWXYyskApmAlKf8As4ncm/EmmNLo3FlYzdIVPy8uFLI1XZCmtxnbW6Rz60Vh6F9n/l2/mNAGovvcSr6SUY3/XQtWiDqxvF+WA41rH4JtAbF1RGx7TRfk1gBN7MsaBfEHaDRIYunTd9gtD8EEjIJa4H8IDWF49jb9E5SKCrzPooTRW4zaVUKcoul7JLUfa5lDpFqXMpyYs7ZFJYsrtNLiXZXbrJxSTbS2nOYwyM9Wt8QqGLFzGo4hk7I3UY5DA/y7Tx1S9CQIk2zBmHs3CnsM4i7H2idQuGHei2bli9b9jmULF5/gYdsX1F
</special-item>]])

        assert.are.same(ast, {
          {
            kind = "BLUEPRINT_BLOCK",
            caption = nil,
            value = "0eNqVlMFuwyAMhl8l8plIhbRNw3G7TTvsPk0Tad0OiUAEZFoU5d0H6VRFG9LKgYNB/2f/BjNBqwbsrdQe+ATyaLQD/jqBkxctVNzzY4/AQXrsgIAWXYyskApmAlKf8As4ncm/EmmNLo3FlYzdIVPy8uFLI1XZCmtxnbW6Rz60Vh6F9n/l2/mNAGovvcSr6SUY3/XQtWiDqxvF+WA41rH4JtAbF1RGx7TRfk1gBN7MsaBfEHaDRIYunTd9gtD8EEjIJa4H8IDWF49jb9E5SKCrzPooTRW4zaVUKcoul7JLUfa5lDpFqXMpyYs7ZFJYsrtNLiXZXbrJxSTbS2nOYwyM9Wt8QqGLFzGo4hk7I3UY5DA/y7Tx1S9CQIk2zBmHs3CnsM4i7H2idQuGHei2bli9b9jmULF5/gYdsX1F",
            type = "blueprint",
            blueprint_data = {
              blueprint = {
                icons = {
                  {
                    signal = {
                      type = "item",
                      name = "rail",
                    },
                    index = 1,
                  },
                  {
                    signal = {
                      type = "item",
                      name = "iron-ore",
                    },
                    index = 2,
                  },
                  {
                    signal = {
                      type = "item",
                      name = "light-oil-barrel",
                    },
                    index = 3,
                  },
                  {
                    signal = {
                      type = "item",
                      name = "lubricant-barrel",
                    },
                    index = 4,
                  },
                },
                entities = {
                  {
                    entity_number = 1,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 9,
                    },
                  },
                  {
                    entity_number = 2,
                    name = "train-stop",
                    position = {
                      x = 19,
                      y = 9,
                    },
                    station = "Bert Cypress",
                  },
                  {
                    entity_number = 3,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 11,
                    },
                  },
                  {
                    entity_number = 4,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 13,
                    },
                  },
                  {
                    entity_number = 5,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 15,
                    },
                  },
                  {
                    entity_number = 6,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 17,
                    },
                  },
                  {
                    entity_number = 7,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 19,
                    },
                  },
                  {
                    entity_number = 8,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 21,
                    },
                  },
                  {
                    entity_number = 9,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 23,
                    },
                  },
                  {
                    entity_number = 10,
                    name = "straight-rail",
                    position = {
                      x = 17,
                      y = 25,
                    },
                  },
                  {
                    entity_number = 11,
                    name = "train-stop",
                    position = {
                      x = 19,
                      y = 25,
                    },
                    station = "Jean Paul Lemoine",
                  },
                },
                item = "blueprint",
                label = "fasdfasfa",
                version = 281479276920832,
              },
            },
          },
        })
      end)
    end)

    describe("blueprint books", function()
      it("works", function()
        local ast = parse([[<special-item name="test book">
0eNpFjVEKgzAQRK8S9ltB01I1VylFYty2S2MiJtEWyd2blIKf8/bN7A6DDjgvZHw/WPsCsR/EgbjeCiCPE4gDlz+xAC0H1PmQIjOkkG12Yy6oJ1PW6mSQsiaP7ODoYaTO6/4zYyrddaAxKUZOOaoljFha0hBTzYz4BlHH9FwqTyv2f1QVsOLiyBoQvK3PTcebS8er9sRj/AJlYkQm
</special-item>]])

        assert.are.same(ast, {
          {
            kind = "BLUEPRINT_BLOCK",
            caption = "test book",
            value = "0eNpFjVEKgzAQRK8S9ltB01I1VylFYty2S2MiJtEWyd2blIKf8/bN7A6DDjgvZHw/WPsCsR/EgbjeCiCPE4gDlz+xAC0H1PmQIjOkkG12Yy6oJ1PW6mSQsiaP7ODoYaTO6/4zYyrddaAxKUZOOaoljFha0hBTzYz4BlHH9FwqTyv2f1QVsOLiyBoQvK3PTcebS8er9sRj/AJlYkQm",
            type = "blueprint_book",
            blueprint_data = {
              blueprint_book = {
                blueprints = {},
                item = "blueprint-book",
                label = "book nice wow such cool",
                icons = {
                  {
                    signal = {
                      type = "fluid",
                      name = "crude-oil",
                    },
                    index = 1,
                  },
                },
                active_index = 0,
                version = 281479276920832,
              },
            },
          },
        })
      end)
    end)

    describe("deconstruction planners", function()
      it("works", function()
        local ast = parse([[<special-item>
0eNpdjt0KwjAMhd8l1xV0TvfzKiJjbkcttKm0mSij726GKOhdkvMd8s00YgicJE6D2MDdzfXMiNTOlCBi+ZKWGSxWnt3ZOkHUy2Em7j2oJRsDr4YrkpAhyyMe1JbZfPMkgPsHdvloSKxDl+Dw/uzDqHyRFRJ4bf6arT5mhlx/glPATyks+12VlNByvSmrpqj2TbGut0XOLyU0TTs=
</special-item>]])

        assert.are.same(ast, {
          {
            kind = "BLUEPRINT_BLOCK",
            caption = nil,
            value = "0eNpdjt0KwjAMhd8l1xV0TvfzKiJjbkcttKm0mSij726GKOhdkvMd8s00YgicJE6D2MDdzfXMiNTOlCBi+ZKWGSxWnt3ZOkHUy2Em7j2oJRsDr4YrkpAhyyMe1JbZfPMkgPsHdvloSKxDl+Dw/uzDqHyRFRJ4bf6arT5mhlx/glPATyks+12VlNByvSmrpqj2TbGut0XOLyU0TTs=",
            type = "deconstruction_planner",
            blueprint_data = {
              deconstruction_planner = {
                settings = {
                  entity_filters = {
                    {
                      name = "iron-chest",
                      index = 4,
                    },
                    {
                      name = "steel-chest",
                      index = 5,
                    },
                  },
                  tile_selection_mode = 2,
                },
                item = "deconstruction-planner",
                label = "musor",
                version = 281479276920832,
              },
            },
          },
        })
      end)
    end)

    describe("upgrade planners", function()
      it("works", function()
        local ast = parse([[<special-item>
0eNqFjsEKwjAMhl9Fct7AVdGtryIi1WWzuKaljcMx+u6mhx08eQl/8v9JvhXeYYymx1uYDBFG0CskZLY0pqKdCQGjyMsKQ/SuzHgJCBqQ2PICFZBxpU9sHq/aUsLIcihXwP5vfLCThH+2LPX4Ad3ka2kY5edGWW+UFUzmjpM41oXoZ8Hd8VOqOLPwWk+gVdscz506nzq1bw8q5y/+21Ex
</special-item>]])

        assert.are.same(ast, {
          {
            kind = "BLUEPRINT_BLOCK",
            caption = nil,
            value = "0eNqFjsEKwjAMhl9Fct7AVdGtryIi1WWzuKaljcMx+u6mhx08eQl/8v9JvhXeYYymx1uYDBFG0CskZLY0pqKdCQGjyMsKQ/SuzHgJCBqQ2PICFZBxpU9sHq/aUsLIcihXwP5vfLCThH+2LPX4Ad3ka2kY5edGWW+UFUzmjpM41oXoZ8Hd8VOqOLPwWk+gVdscz506nzq1bw8q5y/+21Ex",
            type = "upgrade_planner",
            blueprint_data = {
              upgrade_planner = {
                settings = {
                  mappers = {
                    {
                      from = {
                        type = "entity",
                        name = "stack-inserter",
                      },
                      to = {
                        type = "entity",
                        name = "stack-filter-inserter",
                      },
                      index = 1,
                    },
                  },
                },
                item = "upgrade-planner",
                label = "improving thing",
                version = 281479276920832,
              },
            },
          },
        })
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

    it("should parse [ inside text", function()
      local ast = parse("kek pek [ so nice")

      assert.are.same(ast, {
        {
          kind = "PARAGRAPH",
          children = {
            { kind = "TEXT", text = "kek pek " },
            { kind = "TEXT", text = "[ so nice" },
          },
        },
      })
    end)
  end)

  describe("xml parser", function()
    local xml_parser = require("__the418_kb__/markup/parser/xml")

    it("should work", function()
      local result, len =
        xml_parser.parse('<special-item name="my blueprint">bpstring</special-item>\nother text')

      assert.are.same(result, {
        {
          label = "special-item",
          xarg = {
            name = "my blueprint",
          },
          "bpstring",
        },
      })
      assert.are.same(len, 57)
    end)

    it("should remove whitespace and newlines from text", function()
      local result, len =
        xml_parser.parse('<special-item name="my blueprint">\n bpstring\n</special-item>')

      assert.are.same(result, {
        {
          label = "special-item",
          xarg = {
            name = "my blueprint",
          },
          "bpstring",
        },
      })
      assert.are.same(len, 60)
    end)

    it("should not break if we pass in text", function()
      local result, len = xml_parser.parse("text www")

      assert.are.same(result, { "text www" })
      assert.are.same(len, 8)
    end)

    it("should not crash if the parser crashes", function()
      local result, len = xml_parser.parse([[<parent>
      <child>content</child>
      <child2>
      <grandchild>content</grandchild>
  </parent>]])

      assert.are.same(result, {})
      assert.are.same(len, 0)
    end)
  end)
end)
