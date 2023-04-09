<h1 align="center">
👓 NeoView.nvim
</h1>

<p align="center">
  <a href="http://www.lua.org">
    <img
      alt="Lua"
      src="https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua"
    />
  </a>
  <a href="https://neovim.io/">
    <img
      alt="Neovim"
      src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white"
    />
  </a>
</p>

## 📢 Introduction

NeoView is a Neovim plugin that allows users to save and restore their views and cursor positions across sessions.

## ✨ Features

- Improves user experience and streamlines workflows in Neovim
- Save and restore views and cursor positions across sessions
- Includes a function for clearing all NeoView data

## 💾 Persistence

NeoView enables users to seamlessly resume their work by restoring their previous view and cursor position upon reopening a file.

## 🔔 Default Behavior

NeoView is enabled by default.

## 🛠️ Usage

To clear the view list in NeoView, you can use the `ClearNeoView` command:

```vim
:ClearNeoView
```

## 📦 Installation

1. Install via your favorite package manager.

- [lazy.nvim](https://github.com/folke/lazy.nvim)
```Lua
{
  "ecthelionvi/NeoView.nvim",
  opts = {}
},
```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```Lua
use "ecthelionvi/NeoView.nvim"
```

2. Setup the plugin in your `init.lua`. Skip this step if you're fine with the default settings or using lazy.nvim with opts set as above.
```Lua
require("NeoView").setup()
```

## 🔧 Configuration

You can pass your config table into the `setup()` function or `opts` if you use lazy.nvim.

The available options:

- `enabled`(boolean) : start NeoView when the plugin is loaded   
  - `true` (default)

### Default Config

```Lua
local config = {
  enabled = true,
}
```
