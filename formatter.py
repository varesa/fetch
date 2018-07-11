import sys
import json

def format(doc):
    keys = doc.keys()
    for key in keys:
        spacer = ":" + (12 - len(key)) * " "
        print(key.capitalize() + spacer + doc[key].encode('utf-8'))

doc = json.load(sys.stdin)

if isinstance(doc, list):
    for entry in doc:
        format(entry)
else:
    format(doc)

