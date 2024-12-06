from simple_term_menu import TerminalMenu
import os
import subprocess
import json

chosen_index = ""

def menuloop(folder):
    files_list = []
    for root, directories, files in os.walk(folder):
        for name in files:
            process = subprocess.Popen(
                ['unzip', '-q', '-p', os.path.join(root, name), 'tempname.txt', '|', 'cat'],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True)
            stdout = json.loads(process.communicate())["name"]
            files_list.append(stdout + ", " + os.path.join(root, name))
            os.system("rm tempname.txt")
    terminal_menu = TerminalMenu(files_list)
    menu_entry_index = terminal_menu.show()
    chosen_index = str(files_list[menu_entry_index])

def main(folder):
    newfldr = folder
    menuloop(newfldr)
    if newfldr.endswith("/"):
        newfldr = newfldr[:-1]
    os.system("psmapp --execute " + newfldr + "/" + chosen_index)