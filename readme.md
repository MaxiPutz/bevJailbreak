# bevJailbreak

A tiny Neovim plugin that lets you **copy and restore entire project files** through your system clipboard — perfect for transferring workspaces, sharing project states, or synchronizing temporary environments.

`bevJailbreak` exports your current Git-tracked files as a **JSON object** and can recreate them anywhere with a single command.

---

## ✨ Features

- Copy all Git-tracked files into a **single JSON clipboard string**  
- Paste the JSON back into a project and **reconstruct folders + files automatically**  
- Works across machines, Docker containers, SSH sessions, remote systems, or temporary environments  
- File contents are taken **from disk**, not from the last commit  
- Automatically resolves the correct project root (`git rev-parse --show-toplevel`)  
- Ex-commands:
  - `:BevCopy`
  - `:BevPaste`

---

## 📦 Installation (Lazy.nvim)

```lua
{
  "maxiputz/bevJailbreak",
  config = function()
    require("bevJailbreak").setup()
  end,
}

