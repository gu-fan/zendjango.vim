"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Script: ZenDjango
"    File: plugin/zendjango.vim
" Summary: Zen with Django.
"  Author: Rykka10 <Rykka10(at)gmail.com>
" Last Update: 2012-04-26
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:save_cpo = &cpo
set cpo&vim

let s:py=!exists("s:py") ? 'python' : s:py
function! s:dj_env() "{{{
    " gvim could not display color code.
    let $DJANGO_COLORS = "nocolor"
    
    let py = system("python --version")
    if match(py,"command not found") != -1
        echoe "Could not found python cmd"
        let s:py = ''
        return -1
    endif
    if split(py)[1][0] == "2"
        let s:py = 'python'
    else
        let py = system("python2 --version")
        if match(py,"command not found") != -1
            echoe "Could not found python2 cmd"
            let s:py = ''
            return -1
        elseif split(py)[1][0] == "2"
            let s:py = 'python2'
        endif
    endif
    let g:loaded_dj_env = 1
endfunction "}}}
function! s:dj_admin(action) "{{{
    if !exists("g:dj_loaded_dj_env") | cal s:dj_env() | endif
    exec '!django-admin.py '. a:action
endfunction "}}}
function! s:dj_manage(action) "{{{
    if !exists("g:dj_loaded_dj_env") | cal s:dj_env() | endif
    if s:dj_man_check() != -1
        " if a:action =~ 'runserver'
        "     exec '!sleep 1 && firefox 127.0.0.1:8000 &'
        " endif
        let mdir = g:current_man_dir
        exec '!'.s:py.' "'.mdir.'manage.py" '. a:action
    endif
endfunction "}}}
function! s:dj_man_check() "{{{
    if g:current_man_dir != ''
        " if g:current_man_dir!=fnamemodify(g:current_pro_dir,':h:h').'/'
        " endif
        return
    endif
    let chk = s:check_dir()
    if !empty(chk)
        let [cdir,name] = chk
        " if name == "man"
            " we are only checking it while loading files, so use ':h'
            " let g:current_man_dir=fnamemodify(cdir,':h').'/'
            let g:current_man_dir=fnamemodify(cdir,':h').'/' . s:get_path("man",name)
            echoe g:current_man_dir
            return
        " elseif name == "pro"
        "     let g:current_man_dir=fnamemodify(cdir,':h:h').'/'
        "     return
        " elseif name == "app"
        "     let g:current_man_dir=fnamemodify(cdir,':h:h').'/'
        "     return
        " endif
    endif
    if g:current_pro_dir != ''
        let g:current_man_dir=fnamemodify(g:current_pro_dir,':h:h').'/'
        return
    elseif g:current_app_dir != ''
        let g:current_man_dir=fnamemodify(g:current_app_dir,':h:h').'/'
        return
    endif
    if !empty(g:default_man_dir)
        let g:current_man_dir=g:default_man_dir
    else
        echo "Could not find a valid manage dir."
        return -1
    endif
endfunction "}}}
" the tree of site path
"     - Projects/
"     | + manage.py
"     | + db/
"     | + migration/
"     | + fixture/
"     | - project/
"     | | settings.py
"     | | urls.py
"     | | - apps/
"     | | | models.py
"     | | | views.py
"     | | | - tempates/
"     | | | | base.html
"     | | | | ...
"     | | | - static/
"     | | | | style.css
"     | | | | ...
"     | | | - media/
"     | | | | favicon.ico
"     | | | | ...
"
let s:path_rel = "man/pro/app/tmp,sta,med"
function! s:get_path(from,to) "{{{
    let p = split(s:path_rel,'/')
    let [f0,t0] = [0,0]
    for i in range(len(p))
        if p[i] !~ ','
            if p[i] == a:from
                let f0 = i
            elseif p[i] == a:to
                let t0 = i
            endif
        else
            let q = split(p[i],',')
            for j in range(len(q))
                if q[j] == a:from
                    let f0 = i
                    let f1 = j
                elseif q[j] == a:to
                    let t0 = i
                    let t1 = j
                endif
            endfor
        endif
    endfor
    return s:build_pth(t0-f0)
endfunction "}}}
function! s:build_pth(len) "{{{
    if a:len>=0
        return repeat("../",a:len)
    else
        return repeat("*/",(-a:len))
    endif
endfunction "}}}

nno <leader>51 :call <SID>dj_edit("models.py", "app")<CR>
nno <leader>52 :call <SID>dj_edit("views.py",  "app")<CR>
nno <leader>53 :call <SID>dj_edit("urls.py",   "app")<CR>
nno <leader>54 :call <SID>dj_edit("admin.py",  "app")<CR>
nno <leader>55 :call <SID>dj_edit("tests.py",  "app")<CR>
nno <leader>56 :call <SID>dj_edit("templates/","app" )<cr>
nno <leader>57 :call <SID>dj_edit("templatetags/","app" )<cr>
nno <leader>58 :call <SID>dj_edit("wsgi.py", "pro")<CR>
nno <leader>59 :call <SID>dj_edit("urls.py", "pro")<CR>
nno <leader>50 :call <SID>dj_edit("settings.py", "pro")<CR>
nno <leader>5h :setl ft=htmldjango<CR>

let g:default_man_dir = ''
let g:default_pro_dir = ''
let g:default_app_dir = ''
let g:default_tmp_dir = ''
let g:default_sta_dir = ''

let g:current_man_dir = exists("g:current_man_dir") ? g:current_man_dir : ''
let g:current_pro_dir = exists("g:current_pro_dir") ? g:current_pro_dir : ''
let g:current_app_dir = exists("g:current_app_dir") ? g:current_app_dir : ''
let g:current_tmp_dir = exists("g:current_tmp_dir") ? g:current_tmp_dir : ''
fun! s:dj_edit(file,place) "{{{
    let chk = s:check_dir()
    if !empty(chk)
        " edit and set while in the place
        let [cdir,name] = chk
        if name == a:place
            let g:current_{a:place}_dir = cdir
        endif
    elseif g:current_{a:place}_dir != ''
        " while not in the folder and have current
        " pass
    elseif g:default_{a:place}_dir != ''
        " edit and set if have default
        let g:current_{a:place}_dir = g:default_{a:place}_dir
    else
        echo "Could not find a valid project dir."
        return
    endif
    " if exist dir , open dir
    " else open that file
    let dir = fnamemodify(g:current_{a:place}_dir.a:file,":r")
    if isdirectory(dir)
        exec "edit ". dir
    else
        exec "edit ". g:current_{a:place}_dir.a:file
    endif
endfun "}}}
function! s:check_dir() "{{{
    let cdir = expand("%:p:h").'/'
    if cdir=~'templates/$'
        return [cdir,"tmp"]
    endif
    if cdir=~'static/$'
        return [cdir,"sta"]
    endif
    if cdir=~'models/$'  || cdir=~'views/$'
        return [fnamemodify(cdir,":h:h").'/',"app"]
    endif
    if cdir=~'settings/$'|| cdir=~'urls/$'
        return [fnamemodify(cdir,":h:h").'/',"pro"]
    endif
    let files = split(glob('*.py',1),'\n')
    if index(files,'models.py')!=-1 && index(files,'views.py')!=-1
        return [cdir,"app"]
    endif
    " settings/ and urls/ ?
    if (index(files,'settings.py')!=-1 || isdirectory('settings'))
        \ && ( index(files,'urls.py')!=-1 || isdirectory('urls'))
        return [cdir,"pro"]
    endif

    if index(files,'manage.py')!=-1
        return [cdir,"man"]
    endif
    return []
endfunction "}}}
fun! s:dj_setdir(name) "{{{
    let chk = s:check_dir()
    if !empty(chk)
        if a:name == chk[1]
            let g:current_{a:name}_dir = chk[0]
            return 1
        endif
    endif
    return 0
endfun "}}}
function! s:dj_sethtml() "{{{
    if <SID>dj_setdir("tmp")
        setl ft=htmldjango
    endif
endfunction "}}}
aug django_folder "{{{
    au!
    au! BufEnter {models,views,tests}.py,*/models/*.py,*/views/*.py call <SID>dj_setdir("app")
    au! BufEnter {settings,wsgi}.py,*/settings/*.py call <SID>dj_setdir("pro")
    au! BufEnter manage.py call <SID>dj_setdir("man")
    au! BufWinEnter *templates/**/*.html call <SID>dj_sethtml()
aug END "}}}

com! -complete=customlist,DjAdmList -nargs=* Djadmin  call s:dj_admin(<q-args>)
com! -complete=customlist,DjManList -nargs=* Djmanage call s:dj_manage(<q-args>)
" dj cmds "{{{
let s:dj_cmd_dic = {
    \  'cleanup' : []
    \, 'compilemessages' : ['--locale=']
    \, 'createcachetable' : ['--database=']
    \, 'dbshell' : ['--database=']
    \, 'diffsettings' : []
    \, 'dumpdata'  : ['--database=','--exclude=','--natural','--all',
                    \'--indent=','--format=']
    \, 'flush'  : ['--database=','--noinput']
    \, 'help'  : []
    \, 'inspectdb' : ['--database=']
    \, 'loaddata'  : ['--database=']
    \, 'makemessages' : ['--locale=','--domain=','--all','--extension=',
                    \'--symlinks','--ignore=','--no-default-ignore',
                    \'--no-wrap','--no-location','--no-obsolete']
    \, 'migrate' : []
    \, 'schemamigration' : ['--inital','--auto']
    \, 'reset'  : ['--database=','--noinput']
    \, 'runfcgi'  : ['protocol=', 'host=', 'port=', 'socket=', 'method=',
                    \'maxrequests=', 'maxspare=', 'minspare=' , 'maxchildren'
                    \'daemonize=', 'pidfile=', 'workdir=', 'debug=', 'outlog=',
                    \'errlog=', 'umask=']
    \, 'runserver' : ['--ipv6','--nothreading','--noreload','--nostatic',
                    \'--insecure']
    \, 'shell'  : ['--plain']
    \, 'sql'  : ['--database=']
    \, 'sqlall'  : ['--database=']
    \, 'sqlclear' : ['--database=']
    \, 'sqlcustom'  : ['--database=']
    \, 'sqlflush'  : ['--database=']
    \, 'sqlindexes'  : ['--database=']
    \, 'sqlinitialdata' : ['--database=']
    \, 'sqlreset'  : ['--database=']
    \, 'sqlsequencereset' : ['--database=']
    \, 'startapp'  : ['--template=','--extension==','--name=']
    \, 'startproject' : ['--template=','--extension==','--name=']
    \, 'syncdb' : ['--database=']
    \, 'test'  : ['--noinput','--failfast','--testrunner=','--liveserver=']
    \, 'testserver'  : ['--noinput','--addrport=','--ipv6']
    \, 'validate' : []
    \}
let s:dj_man_dic = {
    \  'changepassword':['--database=']
    \, 'createsuperuser':[]
    \, 'collectstatic' : ['--noinput','--no-post-process','--ignore=',
                    \'--dry-run','--clear','--link','--no-default-ignore']
    \, 'findstatic' : ['--first']
    \}
let s:dj_man_dic = extend(s:dj_man_dic,s:dj_cmd_dic)
 "}}}
fun! DjAdmList(A,L,P) "{{{
    let l = substitute(a:L, 'Dja\%[dmin]\s*','','')
    if match(l,'\w\+\s\+') != -1
        let l = split(l)[0]
        if has_key(s:dj_cmd_dic,l)
            return s:dj_cmd_dic[l]
        endif
    endif
    if !empty(a:A)
        return filter(keys(s:dj_cmd_dic),'v:val[0 : strlen(a:A)-1] ==# a:A')
    else
        return keys(s:dj_cmd_dic)
    endif
endfun "}}}
fun! DjManList(A,L,P) "{{{
    let l = substitute(a:L, 'Djm\%[anage]\s*','','')
    if match(l,'\w\+\s\+') != -1
        let l = split(l)[0]
        if has_key(s:dj_man_dic,l)
            return s:dj_man_dic[l]
        endif
    endif
    if !empty(a:A)
        return filter(keys(s:dj_man_dic),'v:val[0 : strlen(a:A)-1] ==# a:A')
    else
        return keys(s:dj_man_dic)
    endif
endfun "}}}

let s:zen = {}
" TODO: define the project tree.

" TODO: CREATE A DJANGO project window to switch
function! s:win(name) "{{{
    " create window and set it.
endfunction "}}}


" TODO: Create a django site stub , dirs/settings/files
" TODO: fixture and migration
" TODO: Create a template stub
" TODO: deploy it
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let &cpo = s:save_cpo
unlet s:save_cpo
