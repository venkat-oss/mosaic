from __future__ import annotations

from datetime import date

import pyarrow as pa
import vgplot as vg
from vgplot._types import (
    UNSET,
    AttrValue,
    ChannelValue,
    MarkData,
    MimeBundle,
    TransformArg,
)

source: MarkData = pa.table({"value": [1, 2]})
channel: ChannelValue = vg.param(date(2020, 1, 2))
attribute: AttrValue = None
transform: TransformArg = "value"
mime: MimeBundle = {"text/plain": "Python native value adapters"}

view = vg.spec(
    view=vg.plot(
        vg.dot(source, x=transform, y=channel, stroke=UNSET),
        vg.color_label(attribute),
    )
)
