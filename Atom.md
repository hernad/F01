emacs.json izbaciti alt+ shortcutove:

    "alt-b": "editor:move-to-beginning-of-word",
    "alt-B": "editor:select-to-beginning-of-word",

    "alt-f": "editor:move-to-end-of-word",
    "alt-F": "editor:select-to-end-of-word",
    "alt-h": "editor:delete-to-beginning-of-word",
    "alt-d": "editor:delete-to-end-of-word"



# https://discuss.atom.io/t/disable-default-keybindings/1077/20
keyboard.json:

    '.editor':
      'alt-g': 'native!'
      'alt-G': 'native!'
