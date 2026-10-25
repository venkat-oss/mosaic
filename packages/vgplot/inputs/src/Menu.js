/** @import { Param, Selection } from '@uwdata/mosaic-core' */
import { isParam, isSelection, clausePoint, clauseList, NativeSqlContext } from '@uwdata/mosaic-core';
import { Query, unnest } from '@uwdata/mosaic-sql';
import * as nativeSQL from '@uwdata/mosaic-sql/native';
import { Input, input } from './input.js';

const isObject = v => {
  return v && typeof v === 'object' && !Array.isArray(v);
};

/**
 * Create a new menu input instance.
 * @param {object} [options] Options object
 * @param {HTMLElement} [options.element] The parent DOM element in which to
 *  place the menu elements. If undefined, a new `div` element is created.
 * @param {Selection<import('@uwdata/mosaic-core').SelectionExpression>} [options.filterBy] A selection to filter the database
 *  table indicated by the *from* option.
 * @param {Param} [options.as] The output param or selection. A selection
 *  clause is added for the currently selected menu option.
 * @param {string} [options.field] The database column name to use within
 *  generated selection clause predicates. Defaults to the *column* option.
 * @param {(any | { value: any, label?: string })[]} [options.options] An
 *  array of menu options, as literal values or option objects. Option
 *  objects have a `value` property and an optional `label` property. If no
 *  label or *format* function is provided, the string-coerced value is used.
 * @param {(value: any) => string} [options.format] A format function that
 *  takes an option value as input and generates a string label. The format
 *  function is not applied when an explicit label is provided in an option
 *  object.
 * @param {*} [options.value] The initial selected menu value.
 * @param {string} [options.from] The name of a database table to use as a data
 *  source for this widget. Used in conjunction with the *column* option.
 * @param {string} [options.column] The name of a database column from which
 *  to pull menu options. The unique column values are used as menu options.
 *  Used in conjunction with the *from* option.
 * @param {string} [options.label] A text label for this input.
 * @param {'any' | 'all'} [options.listMatch] The list match mode.
 * @returns {HTMLElement} The container element for a menu input.
 */
export const menu = options => input(Menu, options);

/**
 * A HTML <select>-based dropdown menu input.
 * @extends {Input<import('@uwdata/mosaic-core').SelectionExpression>}
 */
export class Menu extends Input {
  /**
   * Create a new menu input.
   * @param {object} [options] Options object
   * @param {HTMLElement} [options.element] The parent DOM element in which to
   *  place the menu elements. If undefined, a new `div` element is created.
   * @param {Selection<import('@uwdata/mosaic-core').SelectionExpression>} [options.filterBy] A selection to filter the database
   *  table indicated by the *from* option.
   * @param {Param} [options.as] The output param or selection. A selection
   *  clause is added for the currently selected menu option.
   * @param {string} [options.field] The database column name to use within
   *  generated selection clause predicates. Defaults to the *column* option.
   * @param {(any | { value: any, label?: string })[]} [options.options] An
   *  array of menu options, as literal values or option objects. Option
   *  objects have a `value` property and an optional `label` property. If no
   *  label or *format* function is provided, the string-coerced value is used.
   * @param {(value: any) => string} [options.format] A format function that
   *  takes an option value as input and generates a string label. The format
   *  function is not applied when an explicit label is provided in an option
   *  object.
   * @param {*} [options.value] The initial selected menu value.
   * @param {string} [options.from] The name of a database table to use as a data
   *  source for this widget. Used in conjunction with the *column* option.
   * @param {string} [options.column] The name of a database column from which
   *  to pull menu options. The unique column values are used as menu options.
   *  Used in conjunction with the *from* option.
   * @param {string} [options.label] A text label for this input.
   * @param {'any' | 'all'} [options.listMatch] The list match mode.
   * @param {NativeSqlContext} [nativeContext] The native SQL context.
   */
  constructor({
    element,
    filterBy,
    as,
    from,
    column,
    label = column,
    format = x => x, // TODO
    options,
    value,
    field = column,
    listMatch,
  } = {}, nativeContext) {
    const owner = nativeContext ?? (isSelection(as) ? as.owner : filterBy?.owner);
    super(filterBy, element, 'input', owner ?? undefined);
    this.from = from;
    this.column = column;
    this.format = format;
    this.field = field;
    this.listMatch = listMatch;
    this.initialValue = value;
    this.data = [];
    const selection = this.selection = as;
    this._bindSource(from);

    const lab = document.createElement('label');
    lab.innerText = label || column;
    this.element.appendChild(lab);

    this.select = document.createElement('select');
    this.element.appendChild(this.select);

    // if provided, populate menu options
    if (options) {
      this.data = options.map(opt => isObject(opt) ? opt : { value: opt });
      this.update();
    }

    // initialize selection or param bindings
    if (selection) {
      const isParam = !isSelection(selection);

      // publish any initial menu value to the selection/param
      // later updates propagate this back to the menu element
      // do not publish if using a param that already has a value
      if (value != null && (!isParam || selection.value === undefined)) {
        this.publish(value);
      }

      // publish selected value upon menu change
      this.select.addEventListener('input', () => {
        this.publish(this.selectedValue() ?? null);
      });

      // if bound to a scalar param, respond to value updates
      if (isParam) {
        this.selection.addEventListener('value', value => {
          if (value !== this.select.value) {
            this.selectedValue(value);
          }
        });
      } else {
        // trigger selection activation
        this.select.addEventListener('pointerenter', evt => {
          if (!evt.buttons) this.activate();
        });
        this.select.addEventListener('focus', () => this.activate());
      }
    }
  }

  selectedValue(value) {
    if (arguments.length === 0) {
      const index = this.select.selectedIndex;
      return this.data[index].value;
    } else {
      const index = this.data?.findIndex(opt => opt.value === value);
      if (index >= 0) {
        this.select.selectedIndex = index;
      } else {
        this.select.value = String(value);
      }
    }
  }

  reset() {
    this.select.selectedIndex = this.from ? 0 : -1;
  }

  activate() {
    if (isSelection(this.selection)) {
      this.selection.activate(this.sqlOwner instanceof NativeSqlContext
        ? this.sqlOwner.point(this.field, 0, { source: this })
        : clausePoint(this.field, 0, { source: this }));
    }
  }

  publish(value) {
    const { selection, field, listMatch } = this;
    if (isSelection(selection)) {
      if (value === '') value = undefined; // 'All' option
      const clause = this.sqlOwner instanceof NativeSqlContext
        ? listMatch ? this.sqlOwner.list(field, value, { source: this, listMatch }) : this.sqlOwner.point(field, value, { source: this })
        : listMatch ? clauseList(field, value, { source: this, listMatch }) : clausePoint(field, value, { source: this });
      selection.update(clause);
    } else if (isParam(selection)) {
      selection.update(value);
    }
  }

  query(filter = []) {
    const { from, column, listMatch } = this;
    const table = isParam(from) ? from.value : from;
    if (!table) return null;
    if (this.sqlOwner instanceof NativeSqlContext) {
      return nativeSQL.Query.from(nativeSQL.from(table))
        .select({ value: listMatch ? nativeSQL.unnest(column) : column })
        .distinct().where(filter).orderby('value');
    }
    return Query
      .from(table)
      .select({ value: listMatch ? unnest(column) : column })
      .distinct()
      .where(filter)
      .orderby(column)
  }

  queryResult(data) {
    // column option values, with an inserted 'All' value
    this.data = [{ value: '', label: 'All' }, ...data];
    return this;
  }

  update() {
    const { data, format, select, selection } = this;

    // generate menu item options
    select.replaceChildren();
    for (const { value, label } of data) {
      const opt = document.createElement('option');
      opt.setAttribute('value', value);
      opt.innerText = label ?? format(value);
      this.select.appendChild(opt);
    }

    // update menu value based on param/selection
    const value = isSelection(selection)
      ? selection.valueFor(this)
      : selection ? selection.value : this.initialValue;
    if (selection || value !== undefined) {
      this.selectedValue(value === undefined ? '' : value);
    }

    return this;
  }
}
