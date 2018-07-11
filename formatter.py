import sys
import json

def format(doc):
    print("Subject: Form")
    print("")

    keys = doc.keys()
    for key in keys:
        spacer = ":" + (12 - len(key)) * " "
        print(key.capitalize() + spacer + doc[key])

doc = json.load(sys.stdin)

if isinstance(doc, list):
    for entry in doc:
        format(entry)
else:
    format(doc)

