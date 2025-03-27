# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "httpx>=0.28.1",
#   "rich>=13.9.4",
#   "truststore>=0.10.1",
# ]
# ///
from __future__ import annotations

import re
from datetime import datetime
from itertools import chain
from operator import itemgetter
from ssl import PROTOCOL_TLS_CLIENT

import httpx
from rich.console import Console
from rich.text import Text
from truststore import SSLContext

resp = httpx.get("https://peps.python.org/api/peps.json", verify=SSLContext(PROTOCOL_TLS_CLIENT))
resp.raise_for_status()
data = resp.json()
date_fmt = "%d-%b-%Y"
hist = re.compile(r"(/d+-[a-zA-Z]{3}-[0-9]{4})(<.*>`__)?")
peps = [
    (
        int(nr),
        val["title"],
        max(
            chain(
                (datetime.strptime(val["created"], date_fmt),),
                (
                    datetime.strptime(i, date_fmt)
                    for i in (hist.match(j).groups(1) for j in (val["post_history"] or "").split(", ") if hist.match(j))
                ),
            ),
        ),
    )
    for nr, val in data.items()
]

console = Console()
for at, (nr, title, date) in enumerate(sorted(peps, key=itemgetter(2), reverse=True)[:15], start=1):
    console.print(
        Text(f"{at:2}.", style="gray"),
        Text(date.strftime("%Y-%b-%d"), style="cyan"),
        f"[link=https://peps.python.org/pep-{nr:04}/]{nr}[/link]",
        Text("-"),
        Text(title, style="green"),
    )
