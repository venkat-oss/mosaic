import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable("annotation_data", "SELECT * FROM (VALUES (1,2,'First',3.5,90,'https://example.com/image.png'),(2,3,'Second',5.5,180,'https://example.com/other.png')) AS t(x,y,label,value,angle,src)"));

export default vg.plot(
  vg.text(vg.from("annotation_data"), {"x": "x", "y": "y", "text": "label", "fontSize": 14, "textAnchor": "start", "lineAnchor": "top", "lineWidth": 5, "textOverflow": "ellipsis", "rotate": 15}),
  vg.width(360),
  vg.height(220)
);
