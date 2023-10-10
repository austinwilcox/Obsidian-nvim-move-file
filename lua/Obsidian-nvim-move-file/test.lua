--NOTE: luafile test.lua is how you run this file
--Or source %

local popup = require("plenary.popup")
local move_file_win_id = nil
local move_file_bufnr = nil

local function create_window()
    local width =  60
    local height = 10
    local borderchars =  { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, false)

    local obsidian_move_cmd_win_id, win = popup.create(bufnr, {
        title = "Directories",
        highlight = "ObsidianWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:ObsidianBorder"
    )

    return {
        bufnr = bufnr,
        win_id = obsidian_move_cmd_win_id,
    }
end


local directory_path = '/home/austin/Zettelkasten-v2/'
local files = vim.fn.readdir(directory_path)

local options = { }
for _, file in ipairs(files) do
  --TODO: Make this a recursive function to get all subdirectories
  if vim.fn.isdirectory(directory_path .. "/" .. file) == 1 then
    if file:sub(1, 1) ~= "." then
      table.insert(options, file)
    end
  end
end

local current_buf = vim.api.nvim_get_current_buf()
local full_path = vim.api.nvim_buf_get_name(current_buf)
local win_info = create_window()

move_file_bufnr = win_info.bufnr
move_file_win_id = win_info.win_id

vim.api.nvim_win_set_option(move_file_win_id, "number", true)
vim.api.nvim_buf_set_name(move_file_bufnr, "obsidian-move-file-menu")
vim.api.nvim_buf_set_lines(move_file_bufnr, 0, #options, false, options)
vim.api.nvim_buf_set_option(move_file_bufnr, "filetype", "obsidian-move-file")
vim.api.nvim_buf_set_option(move_file_bufnr, "buftype", "acwrite")
vim.api.nvim_buf_set_option(move_file_bufnr, "bufhidden", "delete")

vim.api.nvim_buf_set_keymap(
    win_info.bufnr,
    "n",
    "<CR>",
    "<Cmd>lua select_menu_item()<CR>",
    {}
)

function select_menu_item()
  local choice = vim.fn.line(".")
  local filename = string.match(full_path, "[^/\\]+$")
  local path_to_place_file = directory_path .. "/" .. options[choice] .. "/" .. filename
  -- local success, errorMsg = os.rename(full_path, directory_path .. "/" .. options[choice] .. "/" .. filename)
  -- if success then
  --   print("File moved successfully, reloading file in new buffer.")
  --   vim.api.nvim_command("e " .. path_to_place_file)
  -- else
  --   print("Error moving file: " .. errorMsg)
  -- end
  close_menu()
end

function close_menu()
  vim.api.nvim_win_close(move_file_win_id, true)

  move_file_bufnr = nil
  move_file_win_id = nil
end