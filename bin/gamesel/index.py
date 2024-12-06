from simple_term_menu import TerminalMenu
import os

def menuloop(folder):
    files_list = []
    for root, directories, files in os.walk(folder):
        for name in files:
            files_list.append(os.path.join(root, name))
    terminal_menu = TerminalMenu(files_list)
    menu_entry_index = terminal_menu.show()
    print(f"You have selected {options[menu_entry_index]}!")

def main(folder):
    menuloop(folder)