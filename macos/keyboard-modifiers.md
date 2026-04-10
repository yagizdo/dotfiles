# macOS Keyboard Modifier Remapping (External Keyboard)

System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys

| Modifier Key       | Remapped To     |
|--------------------|-----------------|
| Caps Lock (⇪)      | Caps Lock       |
| Control (^)        | Command (⌘)     |
| Option (⌥)         | Option (⌥)      |
| Command (⌘)        | Control (^)     |
| Globe (🌐)         | Globe           |

## Summary

- Physical **Ctrl** key → acts as **Command** (⌘)
- Physical **Windows/Command** key → acts as **Control** (^)
- This means in macOS apps, Physical Ctrl+C/V = Cmd+C/V = Copy/Paste

## Impact on Terminal (Ghostty + Zellij)

Since terminal apps use Ctrl-based shortcuts, Ghostty config explicitly maps
`cmd+key` keybinds to send Ctrl characters to the terminal. This way:

- Physical Ctrl+key → Ghostty intercepts as cmd+key → sends Ctrl char → Zellij works
- Physical Windows+key → macOS sends Ctrl+key → passes through naturally → also works

### Known Limitations (macOS system shortcuts that can't be overridden)

- Physical Ctrl+Q → Cmd+Q → macOS Quit (use Physical Windows+Q for Zellij quit)
- Physical Ctrl+H → Cmd+H → macOS Hide (use Physical Windows+H for Zellij move mode)
- Physical Ctrl+M → Cmd+M → macOS Minimize

### Image Paste in Claude Code

Ghostty's `paste_from_clipboard` only handles text. For image paste in Claude Code:
- Use Physical **Windows+V** (sends raw Ctrl+V to terminal, triggers pngpaste)

## Restore Command (hidutil)

To restore this remapping via command line (for automation):

```bash
# Note: This is per-keyboard and may need the keyboard's vendor/product ID
# The System Settings UI is the recommended way to set this up
# This note is for reference only
```
