import { DuckDB } from '@uwdata/mosaic-duckdb';
import { describe, expect, it } from 'vitest';
import * as sql from '../src/index.js';
import { parseExpression } from '../src/ingress.js';
import { stubParam } from './util/stub-param.js';

const context = sql.createExecutionContext({ backend: 'native-window-test' });

describe('native aggregate authoring', () => {
  it('executes every public aggregate helper with DuckDB semantics', async () => {
    const x = sql.column('x');
    const y = sql.column('y');
    const cases: readonly [string, () => sql.Aggregate, string][] = [
      ['argmax', () => sql.argmax('label', x), 'arg_max(label,x)'],
      ['argmin', () => sql.argmin('label', x), 'arg_min(label,x)'],
      ['array', () => sql.arrayAgg(x), 'array_agg(x)'],
      ['avg', () => sql.avg(x), 'avg(x)'],
      ['corr', () => sql.corr(x, y), 'corr(x,y)'],
      ['count', () => sql.count(x), 'count(x)'],
      ['all', () => sql.count(), 'count(*)'],
      ['covariance', () => sql.covariance(x, y), 'covar_samp(x,y)'],
      ['covarPop', () => sql.covarPop(x, y), 'covar_pop(x,y)'],
      ['entropy', () => sql.entropy(x), 'entropy(x)'],
      ['first', () => sql.first(x), 'first(x)'],
      ['last', () => sql.last(x), 'last(x)'],
      ['geomean', () => sql.geomean(x), 'geomean(x)'],
      ['kurtosis', () => sql.kurtosis(x), 'kurtosis(x)'],
      ['mad', () => sql.mad(x), 'mad(x)'],
      ['max', () => sql.max(x), 'max(x)'],
      ['median', () => sql.median(x), 'median(x)'],
      ['min', () => sql.min(x), 'min(x)'],
      ['mode', () => sql.mode(x), 'mode(x)'],
      ['product', () => sql.product(x), 'product(x)'],
      ['quantile', () => sql.quantile(x, 0.5), 'quantile(x,0.5)'],
      ['avgX', () => sql.regrAvgX(x, y), 'regr_avgx(x,y)'],
      ['avgY', () => sql.regrAvgY(x, y), 'regr_avgy(x,y)'],
      ['pairs', () => sql.regrCount(x, y), 'regr_count(x,y)'],
      ['intercept', () => sql.regrIntercept(x, y), 'regr_intercept(x,y)'],
      ['r2', () => sql.regrR2(x, y), 'regr_r2(x,y)'],
      ['sxx', () => sql.regrSXX(x, y), 'regr_sxx(x,y)'],
      ['sxy', () => sql.regrSXY(x, y), 'regr_sxy(x,y)'],
      ['syy', () => sql.regrSYY(x, y), 'regr_syy(x,y)'],
      ['slope', () => sql.regrSlope(x, y), 'regr_slope(x,y)'],
      ['skewness', () => sql.skewness(x), 'skewness(x)'],
      ['stddev', () => sql.stddev(x), 'stddev(x)'],
      ['stddevPop', () => sql.stddevPop(x), 'stddev_pop(x)'],
      ['strings', () => sql.stringAgg('label'), 'string_agg(label)'],
      ['sum', () => sql.sum(x), 'sum(x)'],
      ['variance', () => sql.variance(x), 'var_samp(x)'],
      ['varPop', () => sql.varPop(x), 'var_pop(x)']
    ];
    const projections: Record<string, sql.ExprValue> = {};
    for (const [name, create] of cases) projections[name] = create();
    const query = sql.Query.from('data').select(projections);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec("CREATE TABLE data (x DOUBLE,y DOUBLE,label VARCHAR); INSERT INTO data VALUES (1,2,'b'),(2,4,'a'),(2,8,'a'),(NULL,16,NULL),(4,8,'c')");
      const [actual] = await db.query(sql.compile([query], context)[0]);
      const [expected] = await db.query('SELECT ' + cases.map(([name, , expression]) => expression + ' AS "' + name + '"').join(',') + ' FROM data');
      for (const [name] of cases) {
        const value = expected[name];
        if (typeof value === 'number') expect(actual[name]).toBeCloseTo(value, 10);
        else expect(actual[name]).toEqual(value);
      }
      expect(sql.inspectAggregate(sql.geomean(x))?.name).toBe('geometric_mean');
    } finally {
      db.close();
    }
  });

  it('retains filters, DISTINCT and argument ordering without mutating handles', async () => {
    const field = sql.column('x');
    const predicate = sql.gt(field, 1);
    const base = sql.sum(field);
    const derived = base.distinct().where(predicate).argOrder(sql.desc(field));
    const info = sql.inspectAggregate(derived)!;
    expect(info.node).toBe(derived.expression);
    expect(info.args[0]).toBe(field);
    expect(info.filter).toBe(predicate);
    expect(info.distinct).toBe(true);
    expect(sql.inspectAggregate(base)?.distinct).toBe(false);
    const query = sql.Query.from('data').select({
      total: derived,
      rows: sql.int32(sql.count(field).argOrder('n')),
      winner: sql.argmax('label', field).distinct().argOrder(sql.desc(field)).where(predicate),
      tie: sql.argmax('label', field).where(sql.eq(field, 2)).argOrder(sql.desc('n')),
      pair: sql.corr(field, 'y').distinct().where(predicate).argOrder(field),
      q: sql.quantile(field, 0.5).distinct().where(predicate).argOrder(field),
      basic: sql.stringAgg('label'),
      filtered: sql.stringAgg('label').where(sql.gt('n', 1)),
      unique: sql.stringAgg('label').distinct().argOrder('label'),
      ordered: sql.stringAgg('label').argOrder(sql.desc('n')),
      values: sql.arrayAgg(field).argOrder('n')
    });
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec("CREATE TABLE data(x DOUBLE,y DOUBLE,n INTEGER,label VARCHAR); INSERT INTO data VALUES (1,1,1,'b'),(2,2,2,'a'),(2,3,3,'c'),(4,4,4,'a')");
      const [row] = await db.query(sql.compile([query], context)[0]);
      expect(row).toMatchObject({ total: 6, rows: 4, winner: 'a', tie: 'c', q: 2, basic: 'b,a,c,a', filtered: 'a,c,a', unique: 'a,b,c', ordered: 'a,c,a,b', values: [1, 2, 2, 4] });
      expect(row.pair).toBeCloseTo(Math.sqrt(3) / 2, 10);
      const empty = sql.Query.from('data').select({ total: sql.sum(field), count: sql.int32(sql.count(field)), values: sql.arrayAgg(field), strings: sql.stringAgg('label') }).where(sql.literal(false));
      expect(await db.query(sql.compile([empty], context)[0])).toEqual([{ total: null, count: 0, values: null, strings: null }]);
    } finally {
      db.close();
    }
  });
});

describe('native window authoring', () => {
  it('collects original grouping aggregates inside window arguments and definitions', async () => {
    const field = sql.column('x');
    const inner = sql.sum(field);
    const window = sql.sum(inner).window().over('w');
    const query = sql.Query.from('data').select({ g: 'g', total: inner, running: window })
      .groupby('g').window({ w: sql.over().orderby(inner).frame(sql.frameRows([null, 0])) }).orderby('g');
    expect(sql.collectAggregates(window)).toEqual([inner.expression]);
    expect(sql.collectAggregates(query)).toEqual([inner.expression]);
    expect(sql.inspectAggregate(sql.collectAggregates(query)[0])?.args[0]).toBe(field);
    expect(sql.collectAggregates(sql.row_number().orderby(inner))).toEqual([inner.expression]);
    expect(sql.collectAggregates(sql.subquery(sql.Query.select({ n: inner }).from('data')))).toEqual([]);
    const unsupported = parseExpression('count_if(x > 0)');
    expect(sql.collectAggregates(unsupported)[0]).toBe(unsupported);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec("CREATE TABLE data(g VARCHAR,x DOUBLE); INSERT INTO data VALUES ('a',1),('a',2),('b',4)");
      expect(await db.query(sql.compile([query], context)[0])).toEqual([{ g: 'a', total: 3, running: 3 }, { g: 'b', total: 4, running: 7 }]);
    } finally {
      db.close();
    }
  });

  it('executes ranking, offset and value windows with HAVING and QUALIFY', async () => {
    const order = ['x', 'n'];
    const query = sql.Query.from('data').select({
      x: 'x',
      row: sql.int32(sql.row_number().orderby(order)),
      rank: sql.int32(sql.rank().orderby('x')),
      dense: sql.int32(sql.dense_rank().orderby('x')),
      tile: sql.int32(sql.ntile(2).orderby(order)),
      lag: sql.lag('x', 1, sql.literal(-1)).orderby(order),
      lead: sql.lead('x', 1, sql.literal(-1)).orderby(order),
      first: sql.first_value('x').orderby(order),
      nth: sql.nth_value('x', 2).orderby(order).frame(sql.frameRows([null, null])),
      percent: sql.percent_rank().orderby('x'),
      cume: sql.cume_dist().orderby('x')
    }).orderby('x', 'n');
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE data(x DOUBLE,n INTEGER); INSERT INTO data VALUES (1,1),(2,2),(2,3),(4,4),(NULL,5)');
      const rows = await db.query(sql.compile([query], context)[0]);
      expect(rows.map(row => row.row)).toEqual([1, 2, 3, 4, 5]);
      expect(rows.map(row => row.rank)).toEqual([1, 2, 2, 4, 5]);
      expect(rows.map(row => row.dense)).toEqual([1, 2, 2, 3, 4]);
      expect(rows.map(row => row.tile)).toEqual([1, 1, 1, 2, 2]);
      expect(rows.map(row => row.lag)).toEqual([-1, 1, 2, 2, 4]);
      expect(rows.map(row => row.lead)).toEqual([2, 2, 4, null, -1]);
      expect(rows.map(row => row.first)).toEqual([1, 1, 1, 1, 1]);
      expect(rows.map(row => row.nth)).toEqual([2, 2, 2, 2, 2]);
      expect(rows.map(row => row.percent)).toEqual([0, 0.25, 0.25, 0.75, 1]);
      expect(rows.map(row => row.cume)).toEqual([0.2, 0.6, 0.6, 0.8, 1]);
      const filtered = query.clone().setQualify(sql.lte(sql.row_number().orderby(order), 2));
      expect(await db.query(sql.compile([filtered], context)[0])).toHaveLength(2);
      const grouped = sql.Query.from('data').select({ x: 'x', total: sql.sum('x') }).groupby('x').having(sql.gt(sql.sum('x'), 2)).orderby('x');
      expect(await db.query(sql.compile([grouped], context)[0])).toEqual([{ x: 2, total: 4 }, { x: 4, total: 4 }]);
      expect(await db.query(sql.compile([grouped.clone().setHaving()], context)[0])).toHaveLength(4);
    } finally {
      db.close();
    }
  });

  it('clones window handles with live frames and independently derived ordering', async () => {
    let reads = 0;
    let extent: [number | null, number | null] = [1, 0];
    const parameter = { get value() { ++reads; return extent; }, addEventListener() {}, removeEventListener() {} };
    const original = sql.sum('x').orderby('x').frame(sql.frameRows(parameter));
    const clone = original.clone();
    const reversed = clone.orderby(sql.desc('x'));
    expect(clone).not.toBe(original);
    expect(clone.expression).not.toBe(original.expression);
    expect(sql.params(clone)).toEqual([parameter]);
    expect(reads).toBe(0);
    const queries = [original, reversed].map(total => sql.Query.from('numbers').select('x', { total }).orderby('x'));
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE numbers(x DOUBLE); INSERT INTO numbers VALUES (1),(2),(3)');
      const statements = sql.compile(queries, context);
      expect(reads).toBe(1);
      expect((await db.query(statements[0])).map(row => row.total)).toEqual([1, 3, 5]);
      expect((await db.query(statements[1])).map(row => row.total)).toEqual([3, 5, 3]);
      extent = [0, 0];
      const current = sql.compile(queries, context);
      expect(reads).toBe(2);
      for (const statement of current) expect((await db.query(statement)).map(row => row.total)).toEqual([1, 2, 3]);
      extent = [null, null];
      const query = sql.Query.from('numbers').select('x', { total: clone }).orderby('x');
      expect((await db.query(String(query))).map(row => row.total)).toEqual([6, 6, 6]);
      expect(reads).toBe(3);
    } finally { db.close(); }
  });

  it('resolves live frame extents once across independently edited clones and embedded children', async () => {
    let reads = 0;
    let extent: [number | null, number | null] = [1, 0];
    const parameter = { get value() { ++reads; return extent; }, addEventListener() {}, removeEventListener() {} };
    const field = sql.column('x');
    const definition = sql.over().orderby(field).frame(sql.frameRows(parameter));
    const child = sql.Query.from('numbers');
    const outer = sql.Query.from({ c: child }).select({ x: sql.column('x', 'c'), total: sql.column('total', 'c') }).orderby('x');
    child.select({ x: field, total: sql.sum(field).window().over('w') }).window({ w: definition }).orderby('x');
    const first = child.clone().where(sql.gt(field, 1));
    const second = child.clone().select({ flag: sql.literal(7) }).limit(1);
    const keys = new sql.StructuralKeyScope();
    expect(keys.key(first)).not.toBe(keys.key(second));
    expect(sql.params(child)).toEqual([parameter]);
    sql.fields(child);
    expect(reads).toBe(0);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE numbers(x DOUBLE,y DOUBLE); INSERT INTO numbers VALUES (1,10),(2,20),(3,30)');
      const snapshot = sql.snapshotAll([first, second]);
      expect(reads).toBe(1);
      const statements = sql.compileResolved(snapshot, context);
      expect(await db.query(statements[0])).toEqual([{ x: 2, total: 2 }, { x: 3, total: 5 }]);
      expect(await db.query(statements[1])).toEqual([{ x: 1, total: 1, flag: 7 }]);
      for (const [bounds, totals] of [
        [[1, 0], [1, 3, 5]], [[0, 0], [1, 2, 3]], [[null, null], [6, 6, 6]]
      ] as const) {
        extent = [...bounds];
        reads = 0;
        expect((await db.query(sql.compile([outer], context)[0])).map(row => row.total)).toEqual(totals);
        expect(reads).toBe(1);
      }
      extent = [1, 0];
      const rewritten = sql.rewrite(child, new Map([[field, sql.column('y')]]));
      expect((await db.query(sql.compile([rewritten], context)[0])).map(row => row.total)).toEqual([10, 30, 50]);
      child.window({ w: sql.over().orderby('x').frame(sql.frameRows([0, 0])) });
      expect(sql.bindingOf(child.expression)).toBeUndefined();
      reads = 0;
      expect((await db.query(sql.compile([child], context)[0])).map(row => row.total)).toEqual([1, 2, 3]);
      expect(reads).toBe(0);
      expect((await db.query(sql.compile([first], context)[0])).map(row => row.total)).toEqual([2, 5]);
      expect(reads).toBe(1);
    } finally {
      db.close();
    }
  });

  it('preserves explicit frame directions, grouping/exclusions and live scalar frames', async () => {
    const extent = stubParam([1, 0]);
    const query = sql.Query.from('numbers').select({
      x: 'x',
      rows: sql.sum('x').orderby('x').frame(sql.frameRows(extent)),
      next: sql.sum('x').orderby('x').frame(sql.frameRows([sql.following(1), sql.following(1)])),
      range: sql.sum('x').orderby('x').frame(sql.frameRange([1, 0])),
      groups: sql.sum('x').orderby('x').frame(sql.frameGroups([1, 0], 'CURRENT ROW'))
    }).orderby('x');
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE numbers(x DOUBLE); INSERT INTO numbers VALUES (1),(2),(3)');
      expect(await db.query(sql.compile([query], context)[0])).toEqual([
        { x: 1, rows: 1, next: 2, range: 1, groups: null },
        { x: 2, rows: 3, next: 3, range: 3, groups: 1 },
        { x: 3, rows: 5, next: null, range: 5, groups: 2 }
      ]);
      extent.value = [null, 0];
      expect((await db.query(sql.compile([query], context)[0])).map(row => row.rows)).toEqual([1, 3, 6]);
    } finally {
      db.close();
    }
  });
});
