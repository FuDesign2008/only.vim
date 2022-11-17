" edit.vim
"
" available for windows, mac, unix/linux
"
"



if &compatible || exists(':E')
    finish
endif
let s:save_cpo = &cpoptions
set cpoptions&vim


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


"@param {string} fileName
"@return {string}
function! s:FuzzyFindFile(baseFolder, fileName)
    let shellCmd = 'cd ' . shellescape(a:baseFolder) . ' && ls -R'
    let result = system(shellCmd)
    let files = s:ParseToFiles(result)

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

" function! s:FindFileCwd(fileName)
    " let folder = getcwd()
    " let found = s:FuzzyFindFile(folder, a:fileName)
    " return found
" endfunction

function! s:EditFile(filePath)
    if filereadable(a:filePath) || isdirectory(a:filePath)
        execute ':e ' . a:filePath
    else
        echoerr 'Failed to find file: ' . a:filePath
    endif
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
            let filePath = s:FindFileRelative(fileName)
            if empty(filePath)
                call s:EditFolder(1)
            else
                call s:EditFile(filePath)
            endif
        endif
    endif
endfunction


" function! s:CwdEdit(...)
    " let argsCount = a:0
    " if argsCount == 0
        " call s:EditFolder(0)
    " else
        " let fileName = a:1
        " if fileName ==# '.'
            " call s:EditFolder(0)
        " else
            " let filePath = s:FindFileCwd(fileName)
            " if empty(filePath)
                " call s:EditFolder(0)
            " else
                " call s:EditFile(filePath)
            " endif
        " endif
    " endif
" endfunction


" :E {fileName}
command! -nargs=? -complete=file E call s:RelativeEdit(<f-args>)
" :Ex {fileName}
" command! -nargs=? -complete=file Ex call s:CwdEdit(<f-args>)

let &cpoptions = s:save_cpo
