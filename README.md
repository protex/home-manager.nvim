# Home Manager
This neovim plugin provides a few commands to help edit and maintain a nix home-manager environment

# Installation
Vim plug:
```
Plug 'nvim-lua/plenary.nvim'
Plug 'protex/home-manager.nvim'
```

You'll also obviously need nix and home-manager present on your system.

### Other dependencies
This plugin uses `xxd` and `base64` binaries which are standard on most linux operating systems, but if you're using a non-standard linux operating system you'll need to make sure they're installed.

### Why no home-manager installation?
I like home manager a lot. But, my philosophy with it is that a dotfile manager should manage your dotfiles, not replace them. I firmly believe that instead of re-implementing all of the complex and highly customizable configuration that one can accomplish using neovim, home-manager should just help you pull in your existing configuration. Thus, my recommendation is to install neovim as a package and link your existing neovim dotfiles to "~/.config/nvim", relying as little as possible on home-manager to actually influence neovim itself. [Here](https://github.com/protex/home/blob/master/home.nix) is an example of how to do this. I install neovim as a package, add vim plugged, pull in my config, and let neovim do its thing.

That being said, I am not opposed to someone making a PR to add steps to the readme.

# Usage
The plugin provides three commands 

`HomeManagerBuild`:
This command will run `home-manager build`, and print the output in a popup window

`HomeManagerSwitch`:
This command will run `home-manager switch`, and print the output in a popup window

`HomeManagerPrefetchSha256`:

When the cursor is positioned in a fetchFromGithub statement like the following:
```
    source = pkgs.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-autosuggestions";
      rev = "v0.4.0";
      sha256 = "bBqJCkhygrXqAfWBsvUNpXu9IrwLyn/ypmTRKSVP0Xw=";
    };
```
it will prefetch the resource and add/update the sha256 value

# Issues
This is very much a work in progress and has very little error checking. If you run into any problems, or have a suggestion, please submit an issue.



