" yakiudon.vim - metarw plugin: post diary into your yakiudon diary system.
"
" Author: Shota Fukumori (sora_h)
" Licence: The MIT Licence {{{
"     Permission is hereby granted, free of charge, to any person obtaining a copy
"     of this software and associated documentation files (the "Software"), to deal
"     in the Software without restriction, including without limitation the rights
"     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
"     copies of the Software, and to permit persons to whom the Software is
"     furnished to do so, subject to the following conditions:
" 
"     The above copyright notice and this permission notice shall be included in
"     all copies or substantial portions of the Software.
" 
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
"     THE SOFTWARE.
" }}}

if !exists('g:yakiudon_root')
  let g:yakiudon_root = "http://localhost:4567"
endif

if exists('g:yakiudon_ruby')
  let s:yakiudon_ruby = g:yakiudon_ruby
else
  let s:yakiudon_ruby = 'ruby'
endif

if exists('g:yakiudon_rbfile')
  let s:yakiudon_rb = g:yakiudon_rbfile
else
  let s:yakiudon_rb = expand('<sfile>:p:h')."/yakiudon_api.rb"
endif

function! metarw#yakiudon#complete(arglead, cmdline, cursorpos)
  " TODO: Implment this.
endfunction

function! metarw#yakiudon#read(fakepath)
  if a:fakepath == "yakiudon:list"
    let l:browse = []
    let l:entries = split(system(printf("%s %s list %s",
                                       \ shellescape(s:yakiudon_ruby),
                                       \ shellescape(s:yakiudon_rb),
                                       \ shellescape(g:yakiudon_root))),"\n")
    for entry in l:entries
      let l:id = split(entry,": ")[0]
      let l:browse = add(l:browse, {"label": entry,
                                 \  "fakepath": "yakiudon:".l:id})
    endfor
    return ["browse",l:browse]
  else
    return ["read",printf("!%s %s get %s %s", shellescape(s:yakiudon_ruby),
                                         \ shellescape(s:yakiudon_rb),
                                         \ shellescape(g:yakiudon_root),
                                         \ shellescape(s:getid(a:fakepath)))]
  endif
endfunction

function! metarw#yakiudon#write(fakepath, line1, line2, append_p)
  if a:fakepath == "yakiudon:list"
    return ["error", "this is list"]
  else
    if exists('g:yakiudon_user')
      let l:user = g:yakiudon_user
    else
      let l:user = input("Yakiudon username: ")
    endif

    if exists('g:yakiudon_pass')
      let l:pass = g:yakiudon_pass
    else
      let l:pass = inputsecret("Yakiudon password: ")
    endif

    return ["write",printf("!%s %s edit %s %s %s %s",
                           \ shellescape(s:yakiudon_ruby),
                           \ shellescape(s:yakiudon_rb),
                           \ shellescape(g:yakiudon_root),
                           \ shellescape(l:user),
                           \ shellescape(l:pass),
                           \ shellescape(s:getid(a:fakepath)))]
  endif
endfunction

function! s:getid(fakepath)
  let l:suf = substitute(a:fakepath,"^fakepath:","","")
  if l:suf == "yakiudon:today"
    return strftime("%Y%m%d")
  else
    return l:suf   
  endif
endfunction
