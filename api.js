import { initCppJs } from './shared.hpp';

document.addEventListener('DOMContentLoaded', function() {
    let withProperty = [],
    els = document.querySelectorAll('[type="text/powershell"]'),
    i = 0;
    for (i = 0; i < els.length; i += 1) {
        let scriptContent = els[i].textContent.split("\n");
        for(let a = 0; a < scriptContent.length; a += 1) {
            exec_cmd(`pwsh -Command '` + scriptContent[a] + `'`);
        }
    }
});