import * as vg from '@uwdata/vgplot';

export const brush = vg.Selection.crossfilter();
export const offset = vg.Param.value(0);
await vg.coordinator().exec(vg.createTable('dashboard_rows', "SELECT * FROM (VALUES (1,10,'A'),(2,12,'B'),(3,15,'A'),(4,18,'B'),(5,14,'C'),(6,20,'C')) AS t(day,value,category)"));

export default vg.vconcat(
  vg.slider({as: offset, label: "Vertical offset", min: -5, max: 5, step: 1}),
  vg.hconcat(
    vg.plot(
      vg.dot(vg.from('dashboard_rows', {filterBy: brush}), {x: "day", y: vg.sql`value + ${offset}`, fill: "category"}),
      vg.intervalX({as: brush}), vg.colorLegend(),
      vg.xLabel("Day"), vg.yLabel("Value + offset"),
      vg.width(360), vg.height(220)
    ),
    vg.plot(
      vg.barY(vg.from('dashboard_rows', {filterBy: brush}), {x: "category", y: vg.count(), fill: "category"}),
      vg.xLabel("Category"), vg.yLabel("Selected rows"),
      vg.width(360), vg.height(220)
    )
  ),
  vg.table({from: 'dashboard_rows', columns: ["day","value","category"], filterBy: brush, rowBatch: 10})
);
