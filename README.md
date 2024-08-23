# VimFStar

*VimFStar* is a [neovim] plugin for [F*], an ML-like language with a type system for program verification.

## Features

- Syntax highlighting
- Language server support
- Interactive verification of code

## Installation

You can use your favorite [pathogen]-plugin manager to install *VimFStar*. 

If you're using [vim-plug], for example, perform the following steps to install *VimFStar*:

1. Edit your .vimrc and add a `Plug` declaration for VimFStar.

	```vim
	call plug#begin()
	" ...
	Plug 'neovim/nvim-lspconfig'
	Plug 'gebner/VimFStar'
	" ...
	call plug#end()
	```
2. Add the setup code for the F* plugin to your vimrc:
    ```vim
    lua require'fstar'.setup{}
    ```
3. Restart neovim
4. `:PlugInstall` to install the plugin.

## Use of the interactive verification

Make sure that `fstar.exe` and `z3` are in your path.  The first time you open an F* file, VimFStar will download the LSP server.  It will make use of the same `.fst.config.json` files as the official VS Code extension.

To test your code and it to the environment up to the current position of the cursor, call `:FStarVerifyToPoint` (default binding: `<LocalLeader><LocalLeader>`).

You can restart F* with `:FStarRestart` (default binding: `<LocalLeader>r`)

## License

The syntax highlighting file is distributed under the same license as Vim itself. See [LICENSE.VIM] for more details.

The rest of the plugin is licensed under the Apache license.  Large parts of the plugin are adapted from lean.nvim, which is MIT-licensed.  See [LICENSE] for more details.

[ML]: https://en.wikipedia.org/wiki/ML_(programming_language)
[neovim]: https://neovim.org
[F*]: https://fstar-lang.org
[vim-plug]: https://github.com/junegunn/vim-plug
[pathogen]: https://github.com/tpope/vim-pathogen
[LICENSE.VIM]: http://github.com/FStarLang/VimFStar/blob/master/LICENSE.VIM
[LICENSE]: http://github.com/FStarLang/VimFStar/blob/master/LICENSE
