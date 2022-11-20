# only.vim

Enhance vim native commands

## Commands

### 1. `Only`

Inspired by `:only` command

-   `Only` : only keep 1 window in current tab and close others tabs
-   `Only n`: only keep n vertical windows in current tab and close others tabs
-   `OnlyWin ` : like `Only`, but not close others tabs
-   `OnlyWin n`: like `Only n`, but not close others tabs

### 2. `E`

Inspired by `:e` command

-   `E`: edit the folder that contains current file
-   `E fileName`: edit/create the file that is relative with current file, support fuzzy find

### 3. `Cfdo`/`Cdo`/`Ldo`/`Lfdo`/`Bufdo`/`Tabdo`/`Argdo`/`Windo`

Inspired by `:cfdo` command

The fowlloing commands is supported.

| wrapper command | original command |
| :-------------- | :--------------- |
| `Cdo`           | `cdo`            |
| `Cfdo`          | `cfdo`           |
| `Ldo`           | `ldo`            |
| `Lfdo`          | `lfdo`           |
| `Bufdo`         | `bufdo`          |
| `Tabdo`         | `tabdo`          |
| `Argdo`         | `argdo`          |
| `Windo`         | `windo`          |

For better performance, before calling `cfdo`/`cdo`/..., the fowlloing status will be set:

```viml
set eventignore=all
let g:ale_fix_on_save=0
let g:ale_enabled=0
```

After calling `cfdo`/`cfo`/..., the status should be restored as before calling.
