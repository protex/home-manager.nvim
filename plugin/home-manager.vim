if exists('g:loaded_home_manager') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! HomeManagerBuild lua require'home-manager'.homeManager('build', '--no-out-link')
command! HomeManagerSwitch lua require'home-manager'.homeManager('switch')
command! HomeManagerPrefetchSha256 lua require'home-manager'.prefetchSha256()
command! -nargs=+ HomeManager lua require'home-manager'.homeManager(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo


let g:loaded_home_manager = 1
