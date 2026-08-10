# 01 · core 原生层

`lua/core/` 下的 6 个文件，**不依赖任何插件**。把 `lua/plugins/` 删光，这一层照样工作。

---

## options.lua —— 选项

**这是最安全、最该由你自己改的文件。** 里面每一行都是一个开关。

改之前可以先在 Neovim 里试，不用编辑文件：

```vim
:set scrolloff=15      " 试试看
:set scrolloff?        " 查当前值
:help 'scrolloff'      " 查这个选项是干什么的（注意有单引号）
```

试出满意的值，再改到文件里。

**最可能想改的几项：**

| 选项 | 当前值 | 改成什么 |
|---|---|---|
| `relativenumber` | true | `false` 用绝对行号 |
| `wrap` | false | `true` 长行自动折行 |
| `scrolloff` | 8 | 数字越大，光标越倾向于停在屏幕中央 |
| `shiftwidth` | 4 | 缩进宽度。**注意**：只是全局默认值，改单个语言看下面 ftplugin |
| `list` | true | `false` 不显示空格/制表符标记 |
| `timeoutlen` | 400 | which-key 弹出的快慢（毫秒） |
| `cursorline` | true | `false` 不高亮当前行 |

### 一个坑：全局 vs 局部

```lua
vim.o.shiftwidth = 4    -- 全局默认
vim.bo.shiftwidth = 2   -- 只对当前 buffer（文件）生效
vim.wo.colorcolumn = '100'  -- 只对当前 window（窗口）生效
```

`options.lua` 里用 `vim.o`（全局），`after/ftplugin/*.lua` 里必须用 `vim.bo`/`vim.wo`，
否则打开一个 Lua 文件会把所有文件的缩进都改成 2。

---

## keymaps.lua —— 键位

**约定：这里只放不依赖插件的键位。** 插件的键位在它自己的文件里。
所以看到一个不认识的键，先在这找；找不到就去 `lua/plugins/` 找。

### 语法

```lua
vim.keymap.set('模式', '按什么键', '执行什么', { desc = '说明' })
```

模式代号：`n` normal、`i` insert、`v` visual、`t` 终端、`x` visual+select、`o` 操作符待定。
多个模式写成表：`{'n','v'}`。

### 加一个键位的例子

想让 `<leader>tt` 打开一个终端：

```lua
map('n', '<leader>tt', '<cmd>terminal<cr>', { desc = '打开终端' })
```

三种「执行什么」的写法：

```lua
map('n', '<leader>a', '<cmd>write<cr>',        { desc = '执行一条命令' })
map('n', '<leader>b', 'ggVG',                  { desc = '模拟按键序列' })
map('n', '<leader>c', function() ... end,      { desc = '执行一段 Lua' })
```

**`desc` 一定要写。** which-key 弹窗和 `<leader>sk` 的搜索列表都靠它。

### 排查键位冲突

```vim
:map <leader>ff       " 查这个键现在绑到了什么
:verbose map gd       " 还会告诉你是哪个文件第几行定义的 ← 排查冲突神器
```

---

## autocmds.lua —— 自动命令

「当某件事发生时，自动做某件事」。

```lua
autocmd('事件名', {
  desc = '说明',
  pattern = '*.md',        -- 可选：只对匹配的文件生效
  callback = function(args)
    -- args.buf 是触发事件的那个 buffer 编号
  end,
})
```

常用事件：

| 事件 | 什么时候触发 |
|---|---|
| `BufWritePre` | 保存文件之前 |
| `BufWritePost` | 保存文件之后 |
| `BufReadPost` | 读完一个文件之后 |
| `FileType` | 识别出文件类型时 |
| `VimEnter` | Neovim 完全启动后 |
| `UIEnter` | 界面画完（用来做延迟加载） |
| `LspAttach` | LSP 挂到某个文件上了 |
| `TermOpen` | 打开终端 |

查全部事件：`:help events`。查当前生效的：`:autocmd`。

### 关于 augroup

文件顶部创建了一个 group，所有 autocmd 都挂在上面：

```lua
local group = vim.api.nvim_create_augroup('MyConfig', { clear = true })
```

`clear = true` 的意思是：重新加载配置时先清空这个组里的旧命令。
**没有它的话，每次 `:source` 配置都会重复注册一遍**，运行几次后同一个 autocmd
会执行十几次，越用越卡。这是新手配置最常见的性能问题。

---

## treesitter.lua —— 语法高亮

注意这个文件在 `core/`（原生层）而不是 `plugins/`，因为**高亮功能本身是 Neovim
自带的**（`vim.treesitter.start()`）。插件只负责下载语言 parser。

Neovim 0.12 自带这些语言的 parser：`c`、`lua`、`vim`、`vimdoc`、`markdown`、`query`。
所以哪怕删掉所有插件，写 C 和 Markdown 也有完整高亮。

文件里用了 `pcall`（试着执行，失败不报错）：没有对应 parser 时自动退回 Neovim 传统的
正则高亮，不会报错也不会没颜色。

---

## diagnostic.lua —— 报错警告的样子

「诊断」= LSP 或编译器报给你的错误/警告。这个文件只管**怎么显示**，不管**从哪来**
（来源在 `lua/lsp/`）。

最可能想改的：

```lua
virtual_text = false        -- 关掉行尾那串提示文字（有人觉得吵）
virtual_lines = true        -- 改成在下一行显示完整信息（更清楚但占地方）
update_in_insert = true     -- 打字时也实时刷新诊断（默认关，因为很烦）
```

也可以不改文件，按 `<leader>cd` 在两种模式间临时切换。

想改图标就改 `signs.text` 里的字符（需要 Nerd Font 才能正常显示）。

---

## statusline.lua —— 状态栏

底部那一条。手写而不用 lualine，因为 lualine 是一套自己的配置语言，你想改还得先学它；
这里就是普通的 Lua 字符串拼接。

当前显示：

```
 NORMAL  src/main.cpp [+]        main  2  1  clangd  cpp  12:34  45%
└─模式──┘└──文件名────────┘        └─git─┘└─诊断─┘└─LSP──┘└类型┘└行:列┘└─%─┘
```

### 怎么改

**删掉某一块** —— 在文件最下面的 `M.render()` 里删掉对应那一行：

```lua
function M.render()
  local parts = {
    mode_block(),
    ' %f%m%r',
    ' %=',
    git_branch(),
    diagnostics(),
    lsp_name(),        -- ← 不想看 LSP 名字就删这行
    ...
  }
end
```

**调整顺序** —— 交换 `parts` 里的顺序即可。`' %='` 是分界线，它之后的内容靠右对齐。

**加一块新内容** —— 写个返回字符串的函数，加进 `parts`：

```lua
local function file_size()
  local bytes = vim.fn.getfsize(vim.fn.expand('%'))
  if bytes < 0 then return '' end
  return string.format(' %.1fK ', bytes / 1024)
end
```

**`%x` 是什么** —— Neovim 状态栏的占位符（`:help 'statusline'`）：

| 占位符 | 含义 |
|---|---|
| `%f` | 文件相对路径 |
| `%m` | 修改标记 `[+]` |
| `%=` | 左右分界，之后的内容靠右 |
| `%l` `%c` | 行号、列号 |
| `%P` | 位置百分比 |
| `%#组名#` … `%*` | 用某个高亮组上色，`%*` 恢复默认 |

**配色**：从主题里「借」颜色（比如模式块的蓝色取自 `Function` 高亮组的前景色），
所以换主题时状态栏会自动跟着变，不用手动改颜色值。

---

## after/ftplugin/ —— 按文件类型的设置

**这是 Neovim 原生机制**，不是插件：打开 `.cpp` 文件时，Neovim 自动执行
`after/ftplugin/cpp.lua`。比在 Lua 里写一堆 `FileType` autocmd 干净得多。

文件名就是 filetype。不知道当前文件是什么 filetype 就敲 `:set filetype?`。

**加一个新语言的局部设置**：新建 `after/ftplugin/python.lua`，写：

```lua
vim.bo.shiftwidth = 4
vim.bo.expandtab = true
vim.wo.colorcolumn = '88'      -- black 格式化工具的行宽
```

再次强调：**必须用 `vim.bo`/`vim.wo`，不能用 `vim.o`**。
