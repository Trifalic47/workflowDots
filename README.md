# workflowDots 💀

A minimalist, highly-optimized "ricing" setup for Arch Linux, tailored for **offensive security**, **binary exploitation**, and **memory corruption research**.

Built for speed, keyboard-driven efficiency, and maximum terminal real estate.

## 🛠️ Stack

| Component | Tool | Description |
| :--- | :--- | :--- |
| **Distro** | Arch Linux | Bleeding edge, minimal overhead. |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) | TTY-style terminal with GPU acceleration. |
| **Shell** | Zsh + [Starship](https://starship.rs/) | Bubbled prompt with high-signal git & dev status. |
| **Multiplexer** | Tmux | Custom `C-s`/`C-a` prefix setup for window management. |
| **Editor** | Vim | Primeagen-style minimal config for C, Assembly, and Python. |
| **Compositor** | Picom | `dual_kawase` blur for that modern aesthetic. |
| **Status Bar** | Polybar | Minimal bar with Catppuccin-inspired themes. |

## 🧬 Key Features

- **Binary-First Workflow:** Optimized for low-latency editing of C, x86-64 Assembly, and Rust.
- **Context-Aware Prompt:** Starship configured with powerline-style bubbles for git, language runtimes, and execution time.
- **Glass Aesthetics:** Dual-kawase blur configurations in `picom.conf`.
- **Minimalist Vim:** No bloat, focused on performance and split-pane mastery.
- **Fast Navigation:** Tmux and Vim keybindings synced for seamless movement.

## 📁 Repository Structure

```text
.
├── kitty/              # Terminal configuration (TTY style)
├── picom/              # Compositor settings (Blur/Transparency)
├── polybar/            # Status bar (Catppuccin base)
├── wallpapers/         # Curated aesthetic backgrounds
├── .tmux.conf          # Window management (C-s Prefix)
├── .vimrc              # Low-overhead C/ASM editor config
├── .zshrcNew           # Shell optimizations & aliases
└── starship.toml       # Powerline-bubble prompt config
```

## 🚀 Quick Setup

> [!CAUTION]
> Always review configuration files before symlinking them to your `$HOME`.

1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-username/workflowDots.git
   cd workflowDots
   ```

2. **Symlink configs (Example):**
   ```bash
   ln -s $(pwd)/.vimrc ~/.vimrc
   ln -s $(pwd)/.tmux.conf ~/.tmux.conf
   # Add others to ~/.config/ as needed
   ```

3. **Install dependencies:**
   Ensure you have `starship`, `kitty`, `polybar`, `picom`, `zsh`, `tmux`, and `vim` installed via `pacman`.

## 🖼️ Aesthetics

- **Themes:** Catppuccin / Rose Pine Sword.
- **Transparency:** Background opacity managed via Kitty and Picom.
- **Wallpapers:** Included in `wallpapers/` (Main: `rose-pine-sword.jpg`).

---
*Maintained by a student of binary exploitation. Built for the grind.*
