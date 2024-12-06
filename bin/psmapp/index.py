import os
import json

def run_psmapp(filename_in):
    json_content = {}
    json_content_string = """"""
    os.system("unzip " + filename_in + " -d ./temp_zip")
    f = open("./temp_zip/app.json", "r")
    for x in f:
        json_content_string += x
    f.close()
    json_content = json.loads(json_content_string)
    os.system(json_content["cmd"])
    os.system("rm -r ./temp_zip")