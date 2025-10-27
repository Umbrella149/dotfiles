return {
  -- 确保 nvim-dap 插件已加载
  "mfussenegger/nvim-dap",

  -- 配置 nvim-dap
  config = function()
    local dap = require("dap")

    -- 设置 GDB 适配器
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      -- 使用 '--interpreter=dap' 让 GDB 支持 DAP 协议
      -- '--eval-command "set print pretty on"' 优化了结构体的打印显示
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }

    -- 额外的：添加一个简单的启动配置（Launch Configuration）
    -- 这样您就可以直接在 C++ 文件中按 `<leader>dc` (Run/Continue) 启动调试
    dap.configurations.cpp = {
      {
        name = "Launch file",
        type = "gdb",
        request = "launch",
        -- ${file_dir} 和 ${file_base} 是 nvim-dap 的内置变量
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = true,
        -- 如果您的可执行文件需要参数，可以在这里设置
        args = {},
      },
    }

    -- 为 C 语言也添加相同的配置
    dap.configurations.c = dap.configurations.cpp
  end,
}
