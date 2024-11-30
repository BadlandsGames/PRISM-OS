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

RunExeViaProton -File "hello.exe"