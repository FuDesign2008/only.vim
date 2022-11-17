"
" openUrl.vim
"
" available for windows, mac, unix/linux
"
" 1. Open the url under the cursor: <leader>u
" 2. Open the github bundle under the cursor: <leader>b
"
"



if &compatible || exists(':Only')
    finish
endif
let s:save_cpo = &cpoptions
set cpoptions&vim


" @params {0|1} isOnly
" @params {number|string} columns
function s:LayoutWindows(isOnly, columns)
    if a:isOnly
        execute 'silent tabonly | silent only'
    else
        execute 'silent only'
    endif

    let l:columnTotal = str2nr(a:columns)

    if l:columnTotal < 2
        return
    endif

    let l:count = 1
    while l:count < l:columnTotal
        execute 'vsplit'
        let l:count = l:count + 1
    endwhile

    execute 'wincmd ='

endfunction


"@params {number|string} columns
function! s:Only(...)
    if a:0 == 0
        call s:LayoutWindows(1, 1)
    else
        call s:LayoutWindows(1, a:1)
    endif
endfunction

"@params {number|string} columns
function! s:OnlyWin(...)
    if a:0 == 0
        call s:LayoutWindows(0, 1)
    else
        call s:LayoutWindows(0, a:1)
    endif
endfunction



function! s:EditFolder(isRelative)
    let folder = a:isRelative ? expand('%:p:h') : getcwd()
    execute ':e ' . folder
endfunction

" convert `./after/plugin:` to folder `after/plugin`
"@param {string} str
"@return {string}
function! s:DetectFolder(str)
    let start = './'
    let end=':'

    let length = strlen(a:str)
    let startIndex = stridx(a:str, start)
    let endIndex=stridx(a:str, end)

    let isDirectory = startIndex == 0 && endIndex == (length -1)
    if isDirectory
        let folder = strpart(a:str, 2, endIndex - 2)
        return folder
    else
        return ''
    endif
endfunction


"@param {string} result
"@return {array}
"@interface FileItem{
"   name: string
"   path: string
"}
function! s:ParseToFiles(result)
    let resultList = split(a:result, '\n')

    let files = []
    let prefixPath = ''
    for item in resultList
        let folder = s:DetectFolder(item)

        if strlen(folder) == 0
            let fileItem = {
                        \ 'name': item,
                        \ 'path': prefixPath . item,
                        \}
            call add(files, fileItem)
        else
            let prefixPath = folder . '/'
        endif
    endfor

    return files
endfunction

function FileProbabilityCompare(a, b)
    let probabilityA = get(a:a, 'probability', 0)
    let probabilityB = get(a:b, 'probability', 0)
    if probabilityA == probabilityB
        return 0
    endif

    return probabilityA > probabilityB ? -1 : 1
endfunction

"@param {array} files
"@param {string} fileName
"@return {string}
function! s:FuzzyFind(files, fileName)
    let probabilityList = []
    let lowerFileName = tolower(a:fileName)
    let length = strlen(lowerFileName)

    for item in a:files
        let name = get(item, 'name')
        " top
        if name ==# a:fileName
            let filePath = get(item, 'path')
            return filePath
        endif
        if name ==? a:fileName
            let theItem = {
                        \ 'name': name,
                        \ 'path': get(item, 'path'),
                        \ 'probability': 1000
                        \}
            call add(probabilityList, theItem)
        else
            let lowerName = tolower(name)
            if stridx(lowerName, lowerFileName) > -1
                let probability = 1000 *length / strlen(lowerName)
                let theItem = {
                            \ 'name': name,
                            \ 'path': get(item, 'path'),
                            \ 'probability': probability
                            \}
                call add(probabilityList, theItem)
            endif
        endif
    endfor

    call sort(probabilityList, 'FileProbabilityCompare')

    let first = get(probabilityList, 0, {})
    return get(first, 'path', '')
endfunction

"@param {string} baseFolder
"@return {FileItem[]}
function! s:GetFiles(baseFolder)
    let shellCmd = 'cd ' . shellescape(a:baseFolder) . ' && ls -R'
    let result = system(shellCmd)
    let files = s:ParseToFiles(result)
    return files
endfunction


"@param {string} fileName
"@return {string}
function! s:FuzzyFindFile(baseFolder, fileName)
    let files = s:GetFiles(a:baseFolder)
    let found = s:FuzzyFind(files, a:fileName)
    return found
endfunction

"@param {string} fileName
"@return {string}
function! s:FindFileRelative(fileName)
    let folder = expand('%:p:h')
    let found = s:FuzzyFindFile(folder, a:fileName)

    if empty(found)
        return ''
    endif

    let fullPath = folder . '/' . found
    let cwd = getcwd() . '/'

    if stridx(fullPath, cwd) == 0
        let startIndex = strlen(cwd)
        return strpart(fullPath, startIndex)
    endif

    return fullPath
endfunction


function! s:RelativeEdit(...)
    let argsCount = a:0
    if argsCount == 0
        call s:EditFolder(1)
    else
        let fileName = a:1
        if fileName ==# '.'
            call s:EditFolder(1)
        else
            let foundFilePath = s:FindFileRelative(fileName)
            if empty(foundFilePath)
                let dirBaseCurrentFile = expand('%:h')
                let newFilePath = dirBaseCurrentFile . '/' . fileName
                execute ':e ' . newFilePath
            else
                execute ':e ' . foundFilePath
            endif
        endif
    endif
endfunction


function! EditFileComplete(A, L, P)
    let trimed = trim(a:A)
    let length = len(trimed)

    let folder = expand('%:p:h')
    let files = s:GetFiles(folder)

    if length == 0
        let pathList = mapnew(files, {index, item -> item.path})
        return pathList
    else
        let matchFiles = []
        for item in files
            if stridx(item.path, trimed) > -1 && len(item.path) > length
                call add(matchFiles, item.path)
            endif
        endfor
        return matchFiles
    endif
endfunction





command! -nargs=? Only call s:Only(<f-args>)
command! -nargs=? OnlyWin call s:OnlyWin(<f-args>)
" :E {fileName}
command! -nargs=? -complete=customlist,EditFileComplete E call s:RelativeEdit(<f-args>)

let &cpoptions = s:save_cpo
