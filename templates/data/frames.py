from __future__ import annotations

import pyarrow as pa
import vgplot as vg

frame = pa.table({"bill_length": [39.1, 39.5], "flipper_length": [181, 186]})
view = vg.plot(vg.dot(frame, x="bill_length", y="flipper_length"))
