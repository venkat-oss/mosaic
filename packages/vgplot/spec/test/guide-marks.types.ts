
import type {AxisX,AxisY,AxisFx,AxisFy,GridX,GridY,GridFx,GridFy,Frame,Hexgrid} from '../src/index.js';
export const axes:[AxisX,AxisY,AxisFx,AxisFy]=[{mark:'axisX',interval:2,ticks:[0,5,10],tickFormat:null,labelArrow:true},{mark:'axisY',anchor:'right'},{mark:'axisFx'},{mark:'axisFy'}];
export const grids:[GridX,GridY,GridFx,GridFy]=[{mark:'gridX',y1:0,y2:10},{mark:'gridY',x1:0,x2:10},{mark:'gridFx'},{mark:'gridFy'}];
export const frame:Frame={mark:'frame',anchor:null,fill:'red'};
export const hexgrid:Hexgrid={mark:'hexgrid',binWidth:24,fill:'red'};
// @ts-expect-error Decorative wire contracts do not declare data.
export const data:AxisX={mark:'axisX',data:[]};
// @ts-expect-error Native formatter functions exceed the public declarative type.
export const callback:AxisX={mark:'axisX',tickFormat:(value:number)=>String(value)};
// @ts-expect-error GridY inherits horizontal x endpoints rather than y endpoints.
export const endpoints:GridY={mark:'gridY',y1:0};
// @ts-expect-error The frame anchor type excludes objects.
export const anchor:Frame={mark:'frame',anchor:{}};
