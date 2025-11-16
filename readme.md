# Boundary Environment Vim Jailbreak (bevJailbreak)

**Boundary Environment Vim Jailbreak** — or **bevJailbreak** — is a lightweight Neovim plugin designed to “jailbreak” your editing environment by allowing you to **copy an entire project** (all Git-tracked files) into a single JSON object, store it in your clipboard, and **reconstruct** the project anywhere with a single command.

This is extremely useful for:
- Migrating workspaces across machines  
- Sharing project states  
- Moving files into Docker / remote dev containers  
- Sandbox editing  
- Testing environments  
- Offline transfer  
- Reproducible bug reports  

The plugin exports **the current state of your files**, not the last commit, making it perfect for temporary work or rapid prototyping.

---

## ✨ Features

- Export your entire project as a **JSON workspace snapshot**  
- Import (reconstruct) a project from JSON  
- Automatically creates directory structures  
- Uses Git to determine the project root  
- Works across local, remote, and container environments  
- Simple Ex-commands:
  - `:BevCopy` — copy project into system clipboard
  - `:BevPaste` — reconstruct project from clipboard
- JSON-based format (clean, safe, versionable, portable)

---

## 📦 Installation (Lazy.nvim)

```lua
{
  "maxiputz/bevJailbreak",
  config = function()
    require("bevJailbreak").setup()
  end,
}
