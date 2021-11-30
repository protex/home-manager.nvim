if exists('g:loaded_home_manager') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! HomeManagerBuild lua require'homemanager'.build()
command! HomeManagerSwitch lua require'homemanager'.switch()
command! HomeManagerPrefetchSha256 lua require'homemanager'.prefetchSha256()
command! -nargs=+ HomeManager lua require'homemanager'.homeManager(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo


let g:loaded_home_manager = 1
