from __future__ import annotations

from typing import Any

from .._types import UNSET, TransformArg
from .aggregate import (
    argmax,
    argmin,
    avg,
    count,
    first,
    last,
    max,
    median,
    min,
    mode,
    product,
    quantile,
    stddev,
    stddev_pop,
    sum,
    var_pop,
    variance,
)
from .column import (
    bin,
    centroid,
    centroid_x,
    centroid_y,
    column,
    date_day,
    date_month,
    date_month_day,
    geojson,
)


def _transform(
    name: str, args: tuple[Any, ...], options: dict[str, Any]
) -> dict[str, Any]:
    vals = [a for a in args if a is not UNSET]
    value: Any = vals[0] if len(vals) == 1 else vals or ""
    return {name: value, **options}


def cume_dist(**options: Any) -> dict[str, Any]:
    """Compute the cumulative distribution value over an ordered window partition."""
    return {"cume_dist": None, **options}


def dense_rank(**options: Any) -> dict[str, Any]:
    """Compute the dense row rank (no gaps) over an ordered window partition."""
    return {"dense_rank": None, **options}


def first_value(col: TransformArg, **options: Any) -> dict[str, Any]:
    """Get the first value of the given column in the current window frame."""
    return _transform("first_value", (col,), options)


def lag(
    col: TransformArg,
    offset: TransformArg | UNSET = UNSET,
    default: TransformArg | UNSET = UNSET,
    **options: Any,
) -> dict[str, Any]:
    """Compute lagging values in a column."""
    return _transform("lag", (col, offset, default), options)


def last_value(col: TransformArg, **options: Any) -> dict[str, Any]:
    """Get the last value of the given column in the current window frame."""
    return _transform("last_value", (col,), options)


def lead(
    col: TransformArg,
    offset: TransformArg | UNSET = UNSET,
    default: TransformArg | UNSET = UNSET,
    **options: Any,
) -> dict[str, Any]:
    """Compute leading values in a column."""
    return _transform("lead", (col, offset, default), options)


def nth_value(
    col: TransformArg, offset: TransformArg, **options: Any
) -> dict[str, Any]:
    """Get the nth value of the given column in the current window frame, counting from one."""
    return _transform("nth_value", (col, offset), options)


def ntile(buckets: TransformArg, **options: Any) -> dict[str, Any]:
    """Compute an n-tile integer ranging from 1 to the provided argument (num_buckets), dividing the partition as equally as possible."""
    return _transform("ntile", (buckets,), options)


def percent_rank(**options: Any) -> dict[str, Any]:
    """Compute the percentage rank over an ordered window partition."""
    return {"percent_rank": None, **options}


def rank(**options: Any) -> dict[str, Any]:
    """Compute the row rank over an ordered window partition."""
    return {"rank": None, **options}


def row_number(**options: Any) -> dict[str, Any]:
    """Compute the 1-based row number over an ordered window partition."""
    return {"row_number": None, **options}


__all__ = [
    "argmax",
    "argmin",
    "avg",
    "bin",
    "centroid",
    "centroid_x",
    "centroid_y",
    "column",
    "count",
    "cume_dist",
    "date_day",
    "date_month",
    "date_month_day",
    "dense_rank",
    "first",
    "first_value",
    "geojson",
    "lag",
    "last",
    "last_value",
    "lead",
    "max",
    "median",
    "min",
    "mode",
    "nth_value",
    "ntile",
    "percent_rank",
    "product",
    "quantile",
    "rank",
    "row_number",
    "stddev",
    "stddev_pop",
    "sum",
    "var_pop",
    "variance",
]
