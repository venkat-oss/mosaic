import type { BarX, Circle, DotX, Hexagon, RuleY } from '../src/index.js';
export const bar: BarX = {mark:'barX',data:[{x:1}],x:'x'};
export const circle: Circle = {mark:'circle',data:[{x:1}],symbol:'square'};
export const hexagon: Hexagon = {mark:'hexagon',data:[{x:1}],symbol:'diamond'};
export const dot: DotX = {mark:'dotX',data:[{y:1}],y:{value:'y',interval:2}};
export const rule: RuleY = {mark:'ruleY',y:2,y1:0,y2:4,insetTop:2};
// @ts-expect-error The retained RuleY declaration inherits RuleXOptions.
export const ruleEnds: RuleY = {mark:'ruleY',x1:1};
// @ts-expect-error BarX requires declarative data.
export const emptyBar: BarX = {mark:'barX'};
// @ts-expect-error The retained RuleY inset omission follows RuleXOptions.
export const ruleInset: RuleY = {mark:'ruleY',insetLeft:2};
