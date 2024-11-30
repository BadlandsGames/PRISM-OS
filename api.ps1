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

RunExeViaProton -File "hello.exe"