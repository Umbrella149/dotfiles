-- ============================================================================
-- clangd —— C / C++ 的 language server
-- ============================================================================
-- 这个文件的位置很关键：必须在配置根目录的 lsp/ 下，文件名就是 server 名。
-- Neovim 看到 lua/lsp/init.lua 里写了 vim.lsp.enable({'clangd'})，就会自动
-- 到运行时路径里找 lsp/clangd.lua，读取这个 return 出去的表。
--
-- 安装：sudo pacman -S clang        （已装，clangd 22.1.8）
-- 检查：`:checkhealth lsp` 看它有没有正常启动
--
-- 【重要：让 clangd 知道你的编译参数】
-- clangd 需要知道头文件路径、宏定义、C++ 标准版本，否则会到处报「找不到头文件」。
-- 它靠项目根目录的这两个文件之一获得这些信息：
--   · compile_commands.json —— CMake 项目：
--       cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
--       然后 ln -s build/compile_commands.json .
--   · compile_flags.txt —— 手写 Makefile 或单文件项目，一行一个参数：
--       -std=c++20
--       -I./include
--       -Wall
-- 两个都没有的话，clangd 用默认参数，简单文件能用，复杂项目会误报。
-- ============================================================================

return {
  cmd = {
    'clangd',
    '--background-index',            -- 后台建索引，跨文件跳转才准
    '--clang-tidy',                  -- 顺便做静态检查（会多报一些代码风格问题）
    '--header-insertion=iwyu',       -- 补全时自动加 #include
    '--completion-style=detailed',   -- 补全候选显示完整签名
    '--function-arg-placeholders',   -- 补全函数时把参数填成可跳转的占位符
    '--fallback-style=llvm',         -- 没有 .clang-format 时用 LLVM 风格
  },

  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },

  -- 「项目根目录」怎么判断：从当前文件往上找，看到这些文件/目录之一就停。
  -- 顺序有意义，越靠前优先级越高。
  root_markers = {
    '.clangd',
    'compile_commands.json',
    'compile_flags.txt',
    'CMakeLists.txt',
    'Makefile',
    '.git',
  },

  -- 告诉 clangd 一些 Neovim 侧的能力，让它启用对应功能
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,   -- 允许补全时顺带改动光标附近的代码（自动加 include）
      },
    },
    offsetEncoding = { 'utf-8', 'utf-16' },
  },
}
