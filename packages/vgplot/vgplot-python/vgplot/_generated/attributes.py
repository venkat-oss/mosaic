from __future__ import annotations

from typing import TYPE_CHECKING

from ..plot import Directive
from .cartesian_attributes import (
    x_align,
    x_aria_description,
    x_aria_label,
    x_axis,
    x_base,
    x_clamp,
    x_constant,
    x_domain,
    x_exponent,
    x_font_variant,
    x_grid,
    x_inset,
    x_inset_left,
    x_inset_right,
    x_label,
    x_label_anchor,
    x_label_arrow,
    x_label_offset,
    x_line,
    x_nice,
    x_padding,
    x_padding_inner,
    x_padding_outer,
    x_percent,
    x_range,
    x_reverse,
    x_round,
    x_scale,
    x_tick_format,
    x_tick_padding,
    x_tick_rotate,
    x_tick_size,
    x_tick_spacing,
    x_ticks,
    x_zero,
    xy_domain,
    y_align,
    y_aria_description,
    y_aria_label,
    y_axis,
    y_base,
    y_clamp,
    y_constant,
    y_domain,
    y_exponent,
    y_font_variant,
    y_grid,
    y_inset,
    y_inset_bottom,
    y_inset_top,
    y_label,
    y_label_anchor,
    y_label_arrow,
    y_label_offset,
    y_line,
    y_nice,
    y_padding,
    y_padding_inner,
    y_padding_outer,
    y_percent,
    y_range,
    y_reverse,
    y_round,
    y_scale,
    y_tick_format,
    y_tick_padding,
    y_tick_rotate,
    y_tick_size,
    y_tick_spacing,
    y_ticks,
    y_zero,
)
from .color_attributes import (
    color_base,
    color_clamp,
    color_constant,
    color_domain,
    color_exponent,
    color_interpolate,
    color_label,
    color_n,
    color_nice,
    color_percent,
    color_pivot,
    color_range,
    color_reverse,
    color_scale,
    color_scheme,
    color_symmetric,
    color_tick_format,
    color_zero,
    opacity_base,
    opacity_clamp,
    opacity_constant,
    opacity_domain,
    opacity_exponent,
    opacity_label,
    opacity_nice,
    opacity_percent,
    opacity_range,
    opacity_reverse,
    opacity_scale,
    opacity_tick_format,
    opacity_zero,
    symbol_domain,
    symbol_range,
    symbol_scale,
)
from .plot_attributes import (
    align,
    aria_description,
    aria_label,
    aspect_ratio,
    axis,
    clip,
    grid,
    height,
    inset,
    margin,
    margin_bottom,
    margin_left,
    margin_right,
    margin_top,
    name,
    padding,
    style,
    width,
)
from .projection_attributes import (
    projection_clip,
    projection_domain,
    projection_inset,
    projection_inset_bottom,
    projection_inset_left,
    projection_inset_right,
    projection_inset_top,
    projection_parallels,
    projection_precision,
    projection_rotate,
    projection_type,
)
from .size_attributes import (
    length_base,
    length_clamp,
    length_constant,
    length_domain,
    length_exponent,
    length_nice,
    length_percent,
    length_range,
    length_scale,
    length_zero,
    r_base,
    r_clamp,
    r_constant,
    r_domain,
    r_exponent,
    r_label,
    r_nice,
    r_percent,
    r_range,
    r_scale,
    r_zero,
)

if TYPE_CHECKING:
    from .._types import AttrValue


def facet_grid(value: AttrValue = True) -> Directive:
    """Default axis grid for fx and fy scales; typically set to true to enable."""
    return Directive("facetGrid", value)


def facet_label(value: AttrValue) -> Directive:
    """Default axis label for fx and fy scales; typically set to null to disable."""
    return Directive("facetLabel", value)


def facet_margin(value: AttrValue) -> Directive:
    """Shorthand to set the same default for all four facet margins: marginTop, marginRight, marginBottom, and marginLeft."""
    return Directive("facetMargin", value)


def facet_margin_bottom(value: AttrValue) -> Directive:
    """The right facet margin; the (minimum) distance in pixels between the right edges of the inner and outer plot area."""
    return Directive("facetMarginBottom", value)


def facet_margin_left(value: AttrValue) -> Directive:
    """The bottom facet margin; the (minimum) distance in pixels between the bottom edges of the inner and outer plot area."""
    return Directive("facetMarginLeft", value)


def facet_margin_right(value: AttrValue) -> Directive:
    """The left facet margin; the (minimum) distance in pixels between the left edges of the inner and outer plot area."""
    return Directive("facetMarginRight", value)


def facet_margin_top(value: AttrValue) -> Directive:
    """The top facet margin; the (minimum) distance in pixels between the top edges of the inner and outer plot area."""
    return Directive("facetMarginTop", value)


def fx_align(value: AttrValue) -> Directive:
    """How to distribute unused space in the **range** for *point* and *band* scales."""
    return Directive("fxAlign", value)


def fx_aria_description(value: AttrValue) -> Directive:
    """A textual description for the axis in the accessibility tree."""
    return Directive("fxAriaDescription", value)


def fx_aria_label(value: AttrValue) -> Directive:
    """A short label representing the axis in the accessibility tree."""
    return Directive("fxAriaLabel", value)


def fx_axis(value: AttrValue = True) -> Directive:
    """The side of the frame on which to place the implicit axis: *top* or *bottom* for *fx*."""
    return Directive("fxAxis", value)


def fx_domain(value: AttrValue) -> Directive:
    """The extent of the scale’s inputs (abstract values)."""
    return Directive("fxDomain", value)


def fx_font_variant(value: AttrValue) -> Directive:
    """The font-variant attribute for axis ticks; defaults to *tabular-nums* for quantitative axes."""
    return Directive("fxFontVariant", value)


def fx_grid(value: AttrValue = True) -> Directive:
    """Whether to show a grid aligned with the scale’s ticks."""
    return Directive("fxGrid", value)


def fx_inset(value: AttrValue) -> Directive:
    """Shorthand to set the same default for all four insets: **insetTop**, **insetRight**, **insetBottom**, and **insetLeft**."""
    return Directive("fxInset", value)


def fx_inset_left(value: AttrValue) -> Directive:
    """Insets the left edge by the specified number of pixels."""
    return Directive("fxInsetLeft", value)


def fx_inset_right(value: AttrValue) -> Directive:
    """Insets the right edge by the specified number of pixels."""
    return Directive("fxInsetRight", value)


def fx_label(value: AttrValue) -> Directive:
    """A textual label to show on the axis or legend; if null, show no label."""
    return Directive("fxLabel", value)


def fx_label_anchor(value: AttrValue) -> Directive:
    """Where to place the axis **label** relative to the plot’s frame."""
    return Directive("fxLabelAnchor", value)


def fx_label_offset(value: AttrValue) -> Directive:
    """The axis **label** position offset (in pixels); default depends on margins and orientation."""
    return Directive("fxLabelOffset", value)


def fx_line(value: AttrValue = True) -> Directive:
    """If true, draw a line along the axis; if false (default), do not."""
    return Directive("fxLine", value)


def fx_padding(value: AttrValue) -> Directive:
    """For *band* scales, how much of the **range** to reserve to separate adjacent bands; defaults to 0.1 (10%)."""
    return Directive("fxPadding", value)


def fx_padding_inner(value: AttrValue) -> Directive:
    """For a *band* scale, how much of the range to reserve to separate adjacent bands."""
    return Directive("fxPaddingInner", value)


def fx_padding_outer(value: AttrValue) -> Directive:
    """For a *band* scale, how much of the range to reserve to inset first and last bands."""
    return Directive("fxPaddingOuter", value)


def fx_range(value: AttrValue) -> Directive:
    """The extent of the scale’s outputs (visual values)."""
    return Directive("fxRange", value)


def fx_reverse(value: AttrValue = True) -> Directive:
    """Whether to reverse the scale’s encoding; equivalent to reversing either the **domain** or **range**."""
    return Directive("fxReverse", value)


def fx_round(value: AttrValue = True) -> Directive:
    """If true, round the output value to the nearest integer (pixel); useful for crisp edges when rendering."""
    return Directive("fxRound", value)


def fx_tick_format(value: AttrValue) -> Directive:
    """How to format inputs (abstract values) for axis tick labels; one of: - a d3-format string for numeric scales - a d3-time-format string for temporal scales : https://d3js.org/d3-time : https://d3js.org/d3-time-format"""
    return Directive("fxTickFormat", value)


def fx_tick_padding(value: AttrValue) -> Directive:
    """The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **fxTickSize** and **fxTickRotate**."""
    return Directive("fxTickPadding", value)


def fx_tick_rotate(value: AttrValue) -> Directive:
    """The rotation angle of axis tick labels in degrees clocksize; defaults to 0."""
    return Directive("fxTickRotate", value)


def fx_ticks(value: AttrValue) -> Directive:
    """The desired approximate number of axis ticks, or an explicit array of tick values, or an interval such as *day* or *month*."""
    return Directive("fxTicks", value)


def fx_tick_size(value: AttrValue) -> Directive:
    """The length of axis tick marks in pixels; negative values extend in the opposite direction."""
    return Directive("fxTickSize", value)


def fx_tick_spacing(value: AttrValue) -> Directive:
    """The desired approximate spacing between adjacent axis ticks, affecting the default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels for *y* and *fy*."""
    return Directive("fxTickSpacing", value)


def fy_align(value: AttrValue) -> Directive:
    """How to distribute unused space in the **range** for *point* and *band* scales."""
    return Directive("fyAlign", value)


def fy_aria_description(value: AttrValue) -> Directive:
    """A textual description for the axis in the accessibility tree."""
    return Directive("fyAriaDescription", value)


def fy_aria_label(value: AttrValue) -> Directive:
    """A short label representing the axis in the accessibility tree."""
    return Directive("fyAriaLabel", value)


def fy_axis(value: AttrValue = True) -> Directive:
    """The side of the frame on which to place the implicit axis: *left* or *right* for *fy*."""
    return Directive("fyAxis", value)


def fy_domain(value: AttrValue) -> Directive:
    """The extent of the scale’s inputs (abstract values)."""
    return Directive("fyDomain", value)


def fy_font_variant(value: AttrValue) -> Directive:
    """The font-variant attribute for axis ticks; defaults to *tabular-nums* for quantitative axes."""
    return Directive("fyFontVariant", value)


def fy_grid(value: AttrValue = True) -> Directive:
    """Whether to show a grid aligned with the scale’s ticks."""
    return Directive("fyGrid", value)


def fy_inset(value: AttrValue) -> Directive:
    """Shorthand to set the same default for all four insets: **insetTop**, **insetRight**, **insetBottom**, and **insetLeft**."""
    return Directive("fyInset", value)


def fy_inset_bottom(value: AttrValue) -> Directive:
    """Insets the bottom edge by the specified number of pixels."""
    return Directive("fyInsetBottom", value)


def fy_inset_top(value: AttrValue) -> Directive:
    """Insets the top edge by the specified number of pixels."""
    return Directive("fyInsetTop", value)


def fy_label(value: AttrValue) -> Directive:
    """A textual label to show on the axis or legend; if null, show no label."""
    return Directive("fyLabel", value)


def fy_label_anchor(value: AttrValue) -> Directive:
    """Where to place the axis **label** relative to the plot’s frame."""
    return Directive("fyLabelAnchor", value)


def fy_label_offset(value: AttrValue) -> Directive:
    """The axis **label** position offset (in pixels); default depends on margins and orientation."""
    return Directive("fyLabelOffset", value)


def fy_line(value: AttrValue = True) -> Directive:
    """If true, draw a line along the axis; if false (default), do not."""
    return Directive("fyLine", value)


def fy_padding(value: AttrValue) -> Directive:
    """For *band* scales, how much of the **range** to reserve to separate adjacent bands; defaults to 0.1 (10%)."""
    return Directive("fyPadding", value)


def fy_padding_inner(value: AttrValue) -> Directive:
    """For a *band* scale, how much of the range to reserve to separate adjacent bands."""
    return Directive("fyPaddingInner", value)


def fy_padding_outer(value: AttrValue) -> Directive:
    """For a *band* scale, how much of the range to reserve to inset first and last bands."""
    return Directive("fyPaddingOuter", value)


def fy_range(value: AttrValue) -> Directive:
    """The extent of the scale’s outputs (visual values)."""
    return Directive("fyRange", value)


def fy_reverse(value: AttrValue = True) -> Directive:
    """Whether to reverse the scale’s encoding; equivalent to reversing either the **domain** or **range**."""
    return Directive("fyReverse", value)


def fy_round(value: AttrValue = True) -> Directive:
    """If true, round the output value to the nearest integer (pixel); useful for crisp edges when rendering."""
    return Directive("fyRound", value)


def fy_tick_format(value: AttrValue) -> Directive:
    """How to format inputs (abstract values) for axis tick labels; one of: - a d3-format string for numeric scales - a d3-time-format string for temporal scales : https://d3js.org/d3-time : https://d3js.org/d3-time-format"""
    return Directive("fyTickFormat", value)


def fy_tick_padding(value: AttrValue) -> Directive:
    """The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **fyTickSize** and **fyTickRotate**."""
    return Directive("fyTickPadding", value)


def fy_tick_rotate(value: AttrValue) -> Directive:
    """The rotation angle of axis tick labels in degrees clocksize; defaults to 0."""
    return Directive("fyTickRotate", value)


def fy_ticks(value: AttrValue) -> Directive:
    """The desired approximate number of axis ticks, or an explicit array of tick values, or an interval such as *day* or *month*."""
    return Directive("fyTicks", value)


def fy_tick_size(value: AttrValue) -> Directive:
    """The length of axis tick marks in pixels; negative values extend in the opposite direction."""
    return Directive("fyTickSize", value)


def fy_tick_spacing(value: AttrValue) -> Directive:
    """The desired approximate spacing between adjacent axis ticks, affecting the default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels for *y* and *fy*."""
    return Directive("fyTickSpacing", value)


__all__ = [
    "align",
    "aria_description",
    "aria_label",
    "aspect_ratio",
    "axis",
    "clip",
    "color_base",
    "color_clamp",
    "color_constant",
    "color_domain",
    "color_exponent",
    "color_interpolate",
    "color_label",
    "color_n",
    "color_nice",
    "color_percent",
    "color_pivot",
    "color_range",
    "color_reverse",
    "color_scale",
    "color_scheme",
    "color_symmetric",
    "color_tick_format",
    "color_zero",
    "facet_grid",
    "facet_label",
    "facet_margin",
    "facet_margin_bottom",
    "facet_margin_left",
    "facet_margin_right",
    "facet_margin_top",
    "fx_align",
    "fx_aria_description",
    "fx_aria_label",
    "fx_axis",
    "fx_domain",
    "fx_font_variant",
    "fx_grid",
    "fx_inset",
    "fx_inset_left",
    "fx_inset_right",
    "fx_label",
    "fx_label_anchor",
    "fx_label_offset",
    "fx_line",
    "fx_padding",
    "fx_padding_inner",
    "fx_padding_outer",
    "fx_range",
    "fx_reverse",
    "fx_round",
    "fx_tick_format",
    "fx_tick_padding",
    "fx_tick_rotate",
    "fx_tick_size",
    "fx_tick_spacing",
    "fx_ticks",
    "fy_align",
    "fy_aria_description",
    "fy_aria_label",
    "fy_axis",
    "fy_domain",
    "fy_font_variant",
    "fy_grid",
    "fy_inset",
    "fy_inset_bottom",
    "fy_inset_top",
    "fy_label",
    "fy_label_anchor",
    "fy_label_offset",
    "fy_line",
    "fy_padding",
    "fy_padding_inner",
    "fy_padding_outer",
    "fy_range",
    "fy_reverse",
    "fy_round",
    "fy_tick_format",
    "fy_tick_padding",
    "fy_tick_rotate",
    "fy_tick_size",
    "fy_tick_spacing",
    "fy_ticks",
    "grid",
    "height",
    "inset",
    "length_base",
    "length_clamp",
    "length_constant",
    "length_domain",
    "length_exponent",
    "length_nice",
    "length_percent",
    "length_range",
    "length_scale",
    "length_zero",
    "margin",
    "margin_bottom",
    "margin_left",
    "margin_right",
    "margin_top",
    "name",
    "opacity_base",
    "opacity_clamp",
    "opacity_constant",
    "opacity_domain",
    "opacity_exponent",
    "opacity_label",
    "opacity_nice",
    "opacity_percent",
    "opacity_range",
    "opacity_reverse",
    "opacity_scale",
    "opacity_tick_format",
    "opacity_zero",
    "padding",
    "projection_clip",
    "projection_domain",
    "projection_inset",
    "projection_inset_bottom",
    "projection_inset_left",
    "projection_inset_right",
    "projection_inset_top",
    "projection_parallels",
    "projection_precision",
    "projection_rotate",
    "projection_type",
    "r_base",
    "r_clamp",
    "r_constant",
    "r_domain",
    "r_exponent",
    "r_label",
    "r_nice",
    "r_percent",
    "r_range",
    "r_scale",
    "r_zero",
    "style",
    "symbol_domain",
    "symbol_range",
    "symbol_scale",
    "width",
    "x_align",
    "x_aria_description",
    "x_aria_label",
    "x_axis",
    "x_base",
    "x_clamp",
    "x_constant",
    "x_domain",
    "x_exponent",
    "x_font_variant",
    "x_grid",
    "x_inset",
    "x_inset_left",
    "x_inset_right",
    "x_label",
    "x_label_anchor",
    "x_label_arrow",
    "x_label_offset",
    "x_line",
    "x_nice",
    "x_padding",
    "x_padding_inner",
    "x_padding_outer",
    "x_percent",
    "x_range",
    "x_reverse",
    "x_round",
    "x_scale",
    "x_tick_format",
    "x_tick_padding",
    "x_tick_rotate",
    "x_tick_size",
    "x_tick_spacing",
    "x_ticks",
    "x_zero",
    "xy_domain",
    "y_align",
    "y_aria_description",
    "y_aria_label",
    "y_axis",
    "y_base",
    "y_clamp",
    "y_constant",
    "y_domain",
    "y_exponent",
    "y_font_variant",
    "y_grid",
    "y_inset",
    "y_inset_bottom",
    "y_inset_top",
    "y_label",
    "y_label_anchor",
    "y_label_arrow",
    "y_label_offset",
    "y_line",
    "y_nice",
    "y_padding",
    "y_padding_inner",
    "y_padding_outer",
    "y_percent",
    "y_range",
    "y_reverse",
    "y_round",
    "y_scale",
    "y_tick_format",
    "y_tick_padding",
    "y_tick_rotate",
    "y_tick_size",
    "y_tick_spacing",
    "y_ticks",
    "y_zero",
]
