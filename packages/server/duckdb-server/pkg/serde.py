from __future__ import annotations

from decimal import Decimal

import msgspec

serialize_json = msgspec.json.Encoder().encode
deserialize_json = msgspec.json.Decoder(float_hook=Decimal).decode
