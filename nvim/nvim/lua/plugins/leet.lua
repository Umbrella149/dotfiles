return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
      -- include a picker of your choice, see picker section for more details
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- configuration goes here
      lang = "cpp",
      image_support = true,
      cn = { -- leetcode.cn
        enabled = true, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
      },
      injector = {
        ["cpp"] = {
          imports = function()
            return {
              "#include <bits/stdc++.h>",
              "using namespace std;",
              "struct ListNode {",
              "    int val;",
              "    ListNode *next;",
              "    ListNode() : val(0), next(nullptr) {}",
              "    ListNode(int x) : val(x), next(nullptr) {}",
              "    ListNode(int x, ListNode *next) : val(x), next(next) {}",
              "};",
              "struct TreeNode {",
              "    int val;",
              "    TreeNode *left;",
              "    TreeNode *right;",
              "    TreeNode() : val(0), left(nullptr), right(nullptr) {}",
              "    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}",
              "    TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}",
              "};",
            }
          end,
        },
      },
    },
  },
}
