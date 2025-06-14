#!/usr/bin/python3

import subprocess
import json

indexMap = {
        "1": "一",
        "2": "二",
        "3": "三",
        "4": "四",
        "5": "五",
        "6": "六",
        "7": "七",
        "8": "八",
        "9": "九",
        "10": "十",
        "11": "十一",
        "12": "十二",
        "13": "十三",
        "14": "十四",
        "15": "十五",
        "16": "十六",
        "17": "十七",
        "18": "十八",
        "19": "十九",
        "20": "二十"
}
result = subprocess.run(
    ["hyprctl", "workspaces", "-j"],
    stdout=subprocess.PIPE
)
workspaces = json.loads(result.stdout)

output = {
    "text": " ".join(
        f"[{indexMap.get(str(ws['id']), str(ws['id']))}]" if ws.get("focused")
        else indexMap.get(str(ws["id"]), str(ws["id"]))
        for ws in sorted(workspaces, key=lambda x: x["id"])
    ),
    "class": "workspaces"
}

print(json.dumps(output))

