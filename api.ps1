function RunExeViaProton {
    param (
        [string]$File
    )
    eval "$PROTON_FOLDER_PRISM/proton run /fs/$File"
}

function RunExeViaWine {
    param (
        [string]$File
    )
    eval "wine /fs/$File"
}

function RunExeViaWineMono {
    param (
        [string]$File
    )
    eval "wine-mono /fs/$File"
}

function RenderHTMLFile {
    param (
        [string]$Page
        [string]$Font
    )
    ./html_view.elf $Page $Font
}

RenderHTMLFile -Page "index.html" -Font "index.ttf"