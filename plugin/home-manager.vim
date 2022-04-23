if exists('g:loaded_home_manager') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! HomeManagerPrefetchSha256 lua require'home-manager'.prefetchSha256()
lua <<EOF
  vim.api.nvim_create_user_command('HomeManager', require'home-manager'.homeManager, {
    nargs='+',
    complete=require('home-manager.autocomplete')
  })
EOF
command! HomeManagerBuild echoerr 'Depricated, please use HomeManager command (with tab completion) instead'
command! HomeManagerSwitch echoerr 'Depricated, please use HomeManager command (with tab completion) instead'

let &cpo = s:save_cpo
unlet s:save_cpo


let g:loaded_home_manager = 1
