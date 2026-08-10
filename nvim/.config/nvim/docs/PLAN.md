# Neovim 配置规划（v0 草案，待你审阅）

> 目标：一份**你完全掌控**的配置。每一行都知道为什么存在、由谁提供。
> 本文档是框架，请直接在上面批注/删改，我按批注实现。

---

## 0. 设计原则

1. **原生优先**：Neovim 0.12 自带的能力一律不装插件。装插件前先问"这是不是原生已有的"。
2. **来源可见**：每个功能都标注 `[原生]` 还是 `[插件:xxx]`。配置文件的目录结构本身就体现这个区分——`lua/core/` 里零插件依赖，删光 `lua/plugins/` 配置依然能用。
3. **一个插件一个文件**：插件的 `setup()`、键位、自动命令都写在它自己的文件里。删插件 = 删一个文件 + 删列表里一行。
4. **不预装"以后可能用得上"的东西**：需要时再加。
5. **键位显式声明**：不依赖插件的默认键位（那正是"魔法感"的来源），所有键位在自己的文件里写出来。

---

## 1. 目录结构

```
~/.config/nvim/
├── init.lua                  # 唯一入口，只有几行 require，看一眼就知道全貌
│
├── lua/
│   ├── core/                 # 【零插件依赖】把这层配好，不装任何插件也是好用的编辑器
│   │   ├── options.lua       #   vim.opt 全局选项
│   │   ├── keymaps.lua       #   与插件无关的键位
│   │   ├── autocmds.lua      #   自动命令
│   │   └── diagnostic.lua    #   vim.diagnostic 外观与行为（原生，不需插件）
│   │
│   ├── plugins/              # 【插件层】
│   │   ├── init.lua          #   插件清单：vim.pack.add{...}，一眼看完装了什么
│   │   ├── treesitter.lua    #   每个插件一个文件，包含它的 setup + 键位
│   │   ├── picker.lua
│   │   ├── gitsigns.lua
│   │   └── ...
│   │
│   └── lsp/
│       ├── init.lua          #   LspAttach 键位、诊断、capabilities、通用行为
│       └── servers/          #   每个 language server 一个文件（vim.lsp.config 风格）
│           ├── lua_ls.lua
│           ├── rust_analyzer.lua
│           └── clangd.lua
│
├── after/ftplugin/           # 【按文件类型】缩进、折叠、局部键位（原生机制，不用插件）
│   ├── lua.lua
│   ├── markdown.lua
│   └── ...
│
├── snippets/                 # 自己写的代码片段（用原生 vim.snippet，可选）
├── lazy-lock.json / pack 锁  # 插件版本锁定（取决于选哪个管理器）
└── PLAN.md                   # 本文档
```

**为什么这样分：**
- `core/` 与 `plugins/` 的物理隔离，就是"原生 vs 插件"的边界。以后你想知道某个行为哪来的，先看 `core/` 有没有。
- `after/ftplugin/` 是 Neovim 原生的按文件类型加载机制，比在 lua 里写一堆 `FileType` autocmd 更干净，也是 LazyVim 藏起来的东西之一。
- 不设 `utils/`、`config/`、`extras/` 这些抽象层——它们是配置膨胀的起点。

---

## 2. 功能规划

### 2.1 编辑核心 —— 全部 `[原生]`，不装插件

| 功能 | 实现 |
|---|---|
| 行号 / 相对行号 / 光标行 | `number` `relativenumber` `cursorline` |
| 缩进（空格、宽度、智能） | `expandtab` `shiftwidth` `smartindent` |
| 搜索（忽略大小写但智能、增量预览） | `ignorecase` `smartcase` `inccommand=split` |
| 持久化撤销（关了 nvim 还能 undo） | `undofile` |
| 系统剪贴板 | `clipboard=unnamedplus`（Wayland 下用 wl-clipboard） |
| 分屏方向、滚动留白 | `splitright` `splitbelow` `scrolloff` |
| 真彩色 | `termguicolors` |
| 不可见字符显示 | `list` `listchars` |
| 会话恢复 | `sessionoptions` + 原生 `:mksession` |
| 大文件不卡 | 原生 0.11+ 已有大文件保护，按需微调 |

### 2.2 你可能以为是插件、其实 0.12 原生就有的（重点章节）

这一节直接回答你说的"分不清是插件还是 nvim 自带"。以下**全部不需要插件**：

| 你熟悉的 LazyVim 行为 | 真相 |
|---|---|
| `gc` / `gcc` 注释切换 | **原生**（0.10 起） |
| `K` 看文档、`grn` 重命名、`gra` code action、`grr` 找引用、`gri` 找实现 | **原生 LSP 默认键位**（0.11 起） |
| 复制时高亮闪一下 | **原生**（0.11 起默认开启） |
| `]d` `[d` 跳诊断、`]q` `[q` 跳 quickfix、`]b` `[b` 切 buffer | **原生**（0.11 起一大批 `]`/`[` 映射） |
| LSP 自动补全弹窗 | **原生** `vim.lsp.completion.enable{ autotrigger = true }`（0.11 起） |
| snippet 展开与跳转 | **原生** `vim.snippet`（0.10 起） |
| inlay hints（行内类型提示） | **原生** `vim.lsp.inlay_hint` |
| 诊断以"虚拟行"形式展示 | **原生** `virtual_lines`（0.11 起） |
| LSP 服务器配置与启用 | **原生** `vim.lsp.config` / `vim.lsp.enable`（0.11 起，可以不用 nvim-lspconfig） |
| **插件管理器** | **原生** `vim.pack`（0.12 起，可以不用 lazy.nvim） |
| 语法高亮（lua/c/markdown/vim/query） | **原生**已内置这几个 treesitter parser |
| EditorConfig 支持 | **原生** |
| `.md` 转 man page 阅读、`:Man` | **原生** |
| 文件树 | **原生** netrw（`:Explore`），够用但简陋 |
| 模糊查找文件 | **原生** `:find` + `path+=**` + wildmenu 弹窗，够用但慢 |
| 终端 | **原生** `:terminal` |
| 自动读取外部改动、括号匹配高亮、diff 模式 | **原生** |

> 我的建议：**先只用原生跑一周**。你会发现需要插件的地方比想象中少得多，而且届时你提出的需求会非常精确。

### 2.3 需要插件的部分（候选清单，请勾选/否决）

**强烈建议装（4 个）**

| 插件 | 解决什么原生解决不了的问题 | 备选 |
|---|---|---|
| 配色主题 | 原生只有 `default`/`habamax` | tokyonight / catppuccin / kanagawa / gruvbox |
| nvim-treesitter | 原生只内置 5 种语言的 parser，其他语言（rust/java/python/ts/go）要靠它装 | 无替代 |
| 模糊查找器 | 原生 `:find` 不能搜内容、不能预览 | fzf-lua / telescope / mini.pick |
| gitsigns.nvim | 行内 git 状态、hunk 跳转与暂存 | 无好替代 |

**看你习惯，我给建议（请表态）**

| 插件 | 用途 | 我的倾向 |
|---|---|---|
| conform.nvim | 统一格式化入口（stylua/rustfmt/clang-format/prettier） | 建议装，比手写 formatexpr 省心 |
| blink.cmp | 更强的补全（路径/buffer/snippet 多来源、模糊排序） | **先不装**，用原生补全试用；不够再加 |
| mini.surround | `ys`/`cs`/`ds` 包围符号操作 | 建议装，原生无替代且极高频 |
| mini.pairs | 自动补全括号引号 | 中立，有人觉得碍事 |
| oil.nvim | 把目录当 buffer 编辑（比 netrw 舒服，比 neo-tree 轻） | 建议装 |
| which-key.nvim | 按键提示 | **不建议**——键位是自己写的，本来就该记得住 |
| nvim-dap | 断点调试（你有 `~/debugger` 目录，Java/C++/Rust 可能需要） | 待你确认 |
| mason.nvim | 在 nvim 内装 LSP/formatter | **不建议**——Arch 有 pacman，用系统包管理器更可控 |
| lualine / mini.statusline | 状态栏 | 建议**手写原生 statusline**（几十行，完全可控） |

### 2.4 明确**不**装的（这些是 LazyVim 里让你困惑的主要来源）

- 启动页 dashboard / alpha
- buffer 顶栏 bufferline（用原生 `:b <name>` 和查找器切换）
- 缩进参考线 indent-blankline
- 通知美化 nvim-notify / noice
- 文件树 neo-tree（太重，oil 或 netrw 够）
- 动画滚动、彩虹括号、todo 高亮、trouble、flash 跳转
- 任何"AI 补全"插件（除非你要）
- 自动会话管理插件

### 2.5 你的环境特有的需求（我从 dotfiles 推测，请确认）

- **fcitx5 中文输入法**：插入模式退出时自动切回英文输入法（几行 autocmd + `fcitx5-remote`，原生可实现，不需插件）
- **Markdown 写作**：你有 `~/obsidian`、`~/novels`、`~/English-learning`、`~/read_later`——是否需要中文友好的换行/拼写/预览配置？
- **tmux**：是否需要 tmux ↔ nvim 无缝窗格切换？
- **lazygit**：已装，建议用原生 `:terminal` 起浮动窗口调用，不需要 lazygit 插件

---

## 3. 语言支持规划（LSP / 格式化）

从你的目录推测你用：**Lua、Rust、C/C++、Java、Python、Go、JS/TS、Markdown**。
LSP 服务器全部走 **pacman 安装**（不用 mason），配置用**原生 `vim.lsp.config`**：

| 语言 | LSP | 格式化 | 现状 |
|---|---|---|---|
| Lua | lua-language-server | stylua | 未装 |
| Rust | rust-analyzer | rustfmt | rustc 已装 |
| C/C++ | clangd | clang-format | clangd **已装** |
| Java | jdtls | google-java-format | jdk 已装 |
| Python | basedpyright / ruff | ruff | 未装 |
| Go | gopls | gofmt | go 已装 |
| TS/JS | vtsls | prettier | node 已装 |
| Markdown | marksman | prettier | 未装 |

**请告诉我实际要哪几个**，其余不配。

---

## 4. 实施阶段

- **Phase 1｜纯原生地基**：`init.lua` + `core/*`，一个插件都不装。跑起来先用。
- **Phase 2｜最小插件集**：插件管理器 + 主题 + treesitter + 查找器 + gitsigns。
- **Phase 3｜LSP**：按你确认的语言逐个加，先用原生补全。
- **Phase 4｜按需补充**：格式化、surround、oil、DAP……你用得难受了再加。

每个阶段结束我会写一份"这一层加了什么、每个键位是谁提供的"说明。

---

## 5. 需要你决定的问题

请逐条回答（回答"随你"我就按我的倾向来）：

1. **插件管理器**：`vim.pack`（0.12 原生，简单透明，无 lazy-loading）还是 `lazy.nvim`（成熟、有 UI、懒加载）？
   *我的倾向：`vim.pack`，最符合你"完全掌控"的诉求。*
2. **Leader 键与键位风格**：保留 LazyVim 的肌肉记忆（`<Space>ff` 找文件、`<Space>sg` 全局搜索…）还是从零设计一套？
3. **补全**：先用原生 LSP 补全，还是直接上 `blink.cmp`？
4. **查找器**：`fzf-lua`（快、依赖你已装的 fzf）/ `telescope`（生态大）/ `mini.pick`（极简）？
   *我的倾向：fzf-lua。*
5. **文件浏览**：原生 netrw / `oil.nvim` / 都要？
6. **主题**：有偏好吗？深色浅色？
7. **语言范围**：第 3 节的表里实际要哪几个？
8. **调试（DAP）**：现在要还是以后再说？
9. **fcitx5 自动切换输入法**：要吗？
10. **状态栏**：手写原生（可控）还是 lualine（省事）？

---

## 6. 其他

- 配置目录 `~/dotfiles/nvim/.config/nvim`（stow 布局），`~/.config/nvim` 软链接**已建好**，可以直接开写。
- `~/dotfiles` 当前**不是 git 仓库**。要不要初始化一个？配置迭代过程中能回滚会舒服很多。
