local gui_stack = {}

--- @alias GuiRefs { window: LuaGuiElement }

--- @class Gui
--- @field refs GuiRefs
--- @field handle_event function

--- @class GuiStack
--- @field guis Gui[]

--- @return GuiStack
function gui_stack.new()
  return { guis = {} }
end

--- @param stack GuiStack
--- @param gui Gui
function gui_stack.push(stack, gui)
  table.insert(stack.guis, gui)
end

--- @param stack GuiStack
function gui_stack.pop(stack)
  table.remove(stack.guis, #stack.guis)
end

--- @param stack GuiStack
--- @return Gui?
function gui_stack.current(stack)
  return stack.guis[#stack.guis]
end

return gui_stack
