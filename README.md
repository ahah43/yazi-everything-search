# Yazi Everything Search Plugin

A plugin for the [yazi](https://github.com/sxyazi/yazi) file manager that allows you to search files on Windows using [Everything](https://www.voidtools.com/) and select them interactively with [fzf](https://github.com/junegunn/fzf).

## Prerequisites

- yazi v0.2.0 or newer
- Everything (with `es.exe` in your PATH)
- fzf (with `fzf.exe` in your PATH)

## Installation

1.  Add this to your `packages.toml` file (usually at `%AppData%\yazi\config\packages.toml`):

    ```toml
    [plugin]
    use = "YourGitHubUsername/yazi-everything-search"
    ```

2.  Add a keybinding to your `yazi.toml`:

    ```toml
    [manager.prepend_keymaps]
    normal = [
        { on = [ "f" ], run = "plugin everything-search --preset" },
    ]
    ```

## Configuration

If `es.exe` or `fzf.exe` are not in your system's PATH, you can specify their locations in your `yazi.toml`:

```toml
[plugin]
[plugin.everything-search]
es_path = "C:\\Program Files\\Everything\\es.exe"
fzf_path = "C:\\path\\to\\your\\fzf.exe"```
