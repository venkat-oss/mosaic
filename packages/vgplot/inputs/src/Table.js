/**
 * @import { Selection } from '@uwdata/mosaic-core'
 */
import { clausePoints, isArrowTable, isParam, isSelection, NativeSqlContext, queryFieldInfo, toDataColumns } from '@uwdata/mosaic-core';
import { Type } from '@uwdata/flechette';
import { Query, desc } from '@uwdata/mosaic-sql';
import * as nativeSQL from '@uwdata/mosaic-sql/native';
import { formatDate, formatLocaleAuto, formatLocaleNumber } from './util/format.js';
import { Input, input } from './input.js';
import { TABLE_DEFAULT_COLUMNS, TABLE_DEFAULT_HEIGHT, TABLE_DEFAULT_ROW_BATCH } from './generated/table.js';

let _id = -1;

/**
 * Create a new table input instance.
 * @param {object} options Options object
 * @param {HTMLElement} [options.element] The parent DOM element in which to
 *  place the table element. If undefined, a new `div` element is created.
 * @param {Selection<import('@uwdata/mosaic-core').SelectionExpression>} [options.filterBy] A selection to filter the database
 *  table indicated by the *from* option.
 * @param {Selection<import('@uwdata/mosaic-core').SelectionExpression>} [options.as] The output selection. A selection
 *  clause is added for the currently selected table row.
 * @param {{ [name: string]: 'left' | 'right' | 'center' }} [options.align]
 *  An object that maps column names to horizontal text alignment values. If
 *  unspecified, alignment is determined based on the column data type.
 * @param {{ [name: string]: (value: any) => string | HTMLElement }} [options.format] An
 *  object that maps column names to format functions to use for that
 *  column's data. Each format function takes a value as input and generates
 *  formatted text or an HTML element to show in the table.
 * @param {string} [options.from] The name of a database table to use as a data
 *  source for this widget. Used in conjunction with the *columns* option.
 * @param {string[]} [options.columns] The name of database columns to include
 *  in the table component. If unspecified, all columns are included.
 *  Used in conjunction with the *from* option.
 * @param {number | { [name: string]: number }} [options.width] If a number,
 *  sets the desired width of the table, in pixels. If an object, is used to
 *  set explicit pixel widths for each named column included in the object.
 * @param {number} [options.maxWidth] The maximum width of the table, in pixels.
 * @param {number} [options.height] The desired height of the table, in pixels.
 * @param {number} [options.rowBatch] The number of rows to request per query
 *  batch. The batch size will be used to prefetch data beyond the currently
 *  visible range.
 * @returns {HTMLElement} The container element for a table component.
 */
export const table = options => input(Table, options);

/**
 * A HTML table based table component.
 * @extends {Input<import('@uwdata/mosaic-core').SelectionExpression>}
 */
export class Table extends Input {
  /**
   * Create a new Table instance.
   * @param {object} options Options object
   * @param {HTMLElement} [options.element] The parent DOM element in which to
   *  place the table element. If undefined, a new `div` element is created.
   * @param {Selection<import('@uwdata/mosaic-core').SelectionExpression>} [options.filterBy] A selection to filter the database
   *  table indicated by the *from* option.
   * @param {Selection<import('@uwdata/mosaic-core').SelectionExpression>} [options.as] The output selection. A selection
   *  clause is added for the currently selected table row.
   * @param {{ [name: string]: 'left' | 'right' | 'center' }} [options.align]
   *  An object that maps column names to horizontal text alignment values. If
   *  unspecified, alignment is determined based on the column data type.
   * @param {{ [name: string]: (value: any) => string | HTMLElement }} [options.format] An
   *  object that maps column names to format functions to use for that
   *  column's data. Each format function takes a value as input and generates
   *  formatted text or an HTML element to show in the table.
   * @param {string} [options.from] The name of a database table to use as a data
   *  source for this widget. Used in conjunction with the *columns* option.
   * @param {string[]} [options.columns] The name of database columns to include
   *  in the table component. If unspecified, all columns are included.
   *  Used in conjunction with the *from* option.
   * @param {number | { [name: string]: number }} [options.width] If a number,
   *  sets the desired width of the table, in pixels. If an object, is used to
   *  set explicit pixel widths for each named column included in the object.
   * @param {number} [options.maxWidth] The maximum width of the table, in pixels.
   * @param {number} [options.height] The desired height of the table, in pixels.
   * @param {number} [options.rowBatch] The number of rows to request per query
   *  batch. The batch size will be used to prefetch data beyond the currently
   *  visible range.
   * @param {NativeSqlContext} [nativeContext] The native SQL context.
   */
  constructor({
    element,
    filterBy,
    from,
    columns = [...TABLE_DEFAULT_COLUMNS],
    align = {},
    format,
    width,
    maxWidth,
    height = TABLE_DEFAULT_HEIGHT,
    rowBatch = TABLE_DEFAULT_ROW_BATCH,
    as
  } = {}, nativeContext) {
    const owner = nativeContext ?? (isSelection(as) ? as.owner : filterBy?.owner);
    super(filterBy, element, null, owner ?? undefined);

    this.id = `table-${++_id}`;
    this.element.setAttribute('id', this.id);

    this.from = from;
    this.columns = columns;
    /** @type {import('@uwdata/mosaic-core').FieldInfo[]} */
    this.schema = [];
    this.format = format;
    this.align = align;
    this.widths = typeof width === 'object' ? width : {};

    this._bindSource(from);

    this.offset = 0;
    this.limit = +rowBatch;
    this.isPending = false;
    /** @type {Promise<unknown> | null} */
    this.prefetch = null;
    /** @type {(import('@uwdata/flechette').Schema | undefined)[]} */
    this.dataSchemas = [];

    this.selection = as;
    this.currentRow = -1;

    this.sortHeader = null;
    this.sortColumn = null;
    this.sortDesc = false;

    if (typeof width === 'number') this.element.style.width = `${width}px`;
    if (maxWidth) this.element.style.maxWidth = `${maxWidth}px`;
    this.element.style.maxHeight = `${height}px`;
    this.element.style.overflow = 'auto';

    let prevScrollTop = -1;
    this.element.addEventListener('scroll', evt => {
      const { isPending, loaded } = this;
      // @ts-expect-error unpack event
      const { scrollHeight, scrollTop, clientHeight } = evt.target;

      const back = scrollTop < prevScrollTop;
      prevScrollTop = scrollTop;
      if (back || isPending || loaded) return;

      if (scrollHeight - scrollTop < 2 * clientHeight) {
        this.isPending = true;
        this.requestData(this.offset + this.limit);
      }
    });

    this.tbl = document.createElement('table');
    this.element.appendChild(this.tbl);

    this.head = document.createElement('thead');
    this.tbl.appendChild(this.head);

    this.body = document.createElement('tbody');
    this.tbl.appendChild(this.body);

    if (this.selection) {
      this.body.addEventListener('pointerover', evt => {
        const row = resolveRow(evt.target, this.body);
        if (row > -1 && row !== this.currentRow) {
          this.currentRow = row;
          this.selection.update(this.clause([row]));
        }
      });
      this.body.addEventListener('pointerleave', () => {
        this.currentRow = -1;
        this.selection.update(this.clause());
      });
    }

    this.style = document.createElement('style');
    this.element.appendChild(this.style);
  }

  sourceTable() {
    return isParam(this.from) ? this.from.value : this.from;
  }

  get filterStable() {
    return false;
  }

  _cancelQuery() {
    super._cancelQuery();
    if (this.prefetch) this.coordinator?.cancel([this.prefetch]);
    this.prefetch = null;
  }

  initialize() {
    this.offset = 0;
    this.isPending = false;
    return super.initialize();
  }

  clause(rows = null) {
    const { data, limit, schema } = this;
    const fields = schema.map(s => s.column);
    const values = rows == null ? null : rows.map(row => {
      const batch = ~~(row / limit);
      const { columns } = data[batch];
      const schema = this.dataSchemas[batch];
      return fields.map((field, index) => selectionValue(columns[field][row % limit], schema?.fields[index]?.type));
    });
    return this.sqlOwner instanceof NativeSqlContext
      ? this.sqlOwner.points(fields, values, { source: this })
      : clausePoints(fields, values, { source: this });
  }

  /** @returns {Promise<unknown> | null} */
  requestData(offset = 0) {
    const mc = this.coordinator;
    if (!mc || !this.enabled) return this.requestQuery();

    // request next data batch
    const query = this.query(this.filterBy?.predicate(this), offset);
    const pending = this.requestQuery(query);

    // prefetch subsequent data batch
    this.prefetch = mc.prefetch(query.clone().offset(offset + this.limit));
    this.prefetch.catch(() => {});
    return pending;
  }

  async prepare() {
    // query for column schema information
    const pending = this.pending;
    const mc = this.coordinator;
    const table = this.sourceTable();
    const fields = this.columns.map(column => ({ column, table }));
    const schema = await queryFieldInfo(mc, fields);
    if (this.pending !== pending || this.coordinator !== mc) return;
    this.schema = schema;

    // create table header row
    const thead = this.head;
    thead.innerHTML = '';
    const tr = document.createElement('tr');
    for (const { column } of schema) {
      const th = document.createElement('th');
      th.addEventListener('click', evt => this.sort(evt, column));
      th.appendChild(document.createElement('span'));
      th.appendChild(document.createTextNode(column));
      tr.appendChild(th);
    }
    thead.appendChild(tr);

    // get column formatters
    this.formats = formatof(this.format, schema);

    // get column alignment style
    this.style.innerText = tableCSS(
      this.id,
      alignof(this.align, schema),
      widthof(this.widths, schema)
    );
  }

  /**
   * @param {*} [filter]
   * @param {number} [offset]
   */
  query(filter = [], offset = 0) {
    this._cancelQuery();
    this.offset = offset;
    this.isPending = offset > 0;
    const { limit, schema, sortColumn, sortDesc } = this;
    if (this.sqlOwner instanceof NativeSqlContext) {
      return nativeSQL.Query.from(nativeSQL.from(this.sourceTable()))
        .select(schema.map(s => s.column))
        .where(filter)
        .orderby(sortColumn ? (sortDesc ? nativeSQL.desc(sortColumn) : sortColumn) : [])
        .limit(limit).offset(offset);
    }
    return Query.from(this.sourceTable())
      .select(schema.map(s => s.column))
      .where(filter)
      .orderby(sortColumn ? (sortDesc ? desc(sortColumn) : sortColumn) : [])
      .limit(limit)
      .offset(offset);
  }

  queryResult(data) {
    if (!this.isPending) {
      // data is not from an internal request, so reset table
      this.loaded = false;
      this.data = [];
      this.dataSchemas = [];
      this.body.replaceChildren();
      this.offset = 0;
    }
    this.data.push(toDataColumns(data));
    this.dataSchemas.push(isArrowTable(data) ? data.schema : undefined);
    return this;
  }

  update() {
    const { body, formats, data, schema, limit } = this;
    const nf = schema.length;
    const n = data.length - 1;
    const rowCount = limit * n;

    const { numRows, columns } = data[n];
    const cols = schema.map(s => columns[s.column]);
    for (let i = 0; i < numRows; ++i) {
      const tr = document.createElement('tr');
      Object.assign(tr, { __row__: rowCount + i });
      for (let j = 0; j < nf; ++j) {
        const value = cols[j][i];
        const td = document.createElement('td');
        const formatted = value == null ? '' : formats[j](value);
        if (formatted instanceof HTMLElement || formatted instanceof SVGElement) {
          td.appendChild(formatted);
        } else {
          td.innerText = formatted;
        }
        
        tr.appendChild(td);
      }
      body.appendChild(tr);
    }

    if (numRows < limit) {
      // data table has been fully loaded
      this.loaded = true;
    }

    this.isPending = false;
    return this;
  }

  activate() {
    if (isSelection(this.selection)) {
      this.selection.activate(this.clause([]));
    }
  }

  sort(event, column) {
    if (column === this.sortColumn) {
      this.sortDesc = !this.sortDesc;
    } else {
      this.sortColumn = column;
      this.sortDesc = false;
    }

    const th = event.currentTarget;
    const currentHeader = this.sortHeader;
    if (currentHeader === th && event.metaKey) {
      currentHeader.firstChild.textContent = '';
      this.sortHeader = null;
      this.sortColumn = null;
    } else {
      if (currentHeader) currentHeader.firstChild.textContent = '';
      this.sortHeader = th;
      th.firstChild.textContent = this.sortDesc ? '▾'  : '▴';
    }

    // issue query for sorted data
    this.requestData();
  }
}

/**
 * @param {unknown} value
 * @param {import('@uwdata/flechette').DataType} [type]
 * @returns {unknown}
 */
function selectionValue(value, type) {
  if (value == null || !type) return value;
  if (type.typeId === Type.Dictionary) return selectionValue(value, type.dictionary);
  switch (type.typeId) {
    case Type.List:
    case Type.LargeList:
    case Type.FixedSizeList:
    case Type.ListView:
    case Type.LargeListView:
      return Array.from(/** @type {ArrayLike<unknown>} */ (value), item => selectionValue(item, type.children[0].type));
    case Type.Struct: {
      const record = /** @type {Record<string, unknown>} */ (value);
      return Object.fromEntries(type.children.map(field => [field.name, selectionValue(record[field.name], field.type)]));
    }
    default:
      return value;
  }
}

/**
 * Resolve a table row number from an event target within its body.
 * @param {any} element An HTML element.
 * @param {HTMLTableSectionElement} body The table body.
 * @returns {number} The resolved row, or -1 if not a row.
 */
function resolveRow(element, body) {
  for (let row = element; row && row !== body; row = row.parentElement) {
    if (row.parentElement === body && Object.hasOwn(row, '__row__')) return +row.__row__;
  }
  return -1;
}

function formatof(base = {}, schema, locale) {
  return schema.map(({ column, type }) => {
    if (Object.hasOwn(base, column)) {
      return base[column];
    } else {
      switch (type) {
        case 'number': return formatLocaleNumber(locale);
        case 'date': return formatDate;
        default: return formatLocaleAuto(locale);
      }
    }
  });
}

function alignof(base = {}, schema) {
  return schema.map(({ column, type }) => {
    if (Object.hasOwn(base, column)) {
      return base[column];
    } else if (type === 'number') {
      return 'right';
    } else {
      return 'left';
    }
  });
}

function widthof(base = {}, schema) {
  return schema.map(({ column }) => Object.hasOwn(base, column) ? base[column] : undefined);
}

function tableCSS(id, aligns, widths) {
  const styles = [];
  aligns.forEach((a, i) => {
    const w = +widths[i];
    if (a !== 'left' || w) {
      const align = a !== 'left' ? `text-align:${a};` : '';
      const width = w ? `width:${w}px;max-width:${w}px;` : '';
      styles.push(`#${id} tr>:nth-child(${i+1}) {${align}${width}}`);
    }
  });
  return styles.join(' ');
}
