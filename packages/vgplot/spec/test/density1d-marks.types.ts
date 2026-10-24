import type { DensityX, DensityY } from '../src/spec/marks/Density.js';

export const xArea: DensityX = {mark:'densityX',data:{from:'rows'},type:'areaX',y:'value',normalize:false};
export const xLine: DensityX = {mark:'densityX',data:{from:'rows'},type:'lineX',y:'value',markerEnd:'arrow',normalize:'none'};
export const xDot: DensityX = {mark:'densityX',data:{from:'rows'},type:'dotX',y:'value',r:3,normalize:true};
export const xText: DensityX = {mark:'densityX',data:{from:'rows'},type:'textX',y:'value',fontSize:14,normalize:'sum'};
export const yDefault: DensityY = {mark:'densityY',data:{from:'rows'},x:'value',normalize:'max',bandwidth:'$smooth',bins:'$bins'};
export const yArea: DensityY = {...yDefault,type:'areaY',stack:true};
export const yLine: DensityY = {...yDefault,type:'lineY',markerStart:'arrow'};
export const yDot: DensityY = {...yDefault,type:'dotY',r:3};
export const yCircle: DensityY = {...yDefault,type:'circle',symbol:'square'};
export const yText: DensityY = {...yDefault,type:'textY',text:'value',fontWeight:'bold'};
// @ts-expect-error Every densityX declarative branch requires its type.
export const missingXType: DensityX = {mark:'densityX',data:{from:'rows'},y:'value'};
// @ts-expect-error Density endpoints are supplied by the retained smoothing engine.
export const explicitXEndpoint: DensityX = {...xArea,x2:'value'};
// @ts-expect-error One orientation does not admit the other orientation's base mark.
export const wrongYType: DensityY = {...yDefault,type:'dotX'};
// @ts-expect-error Branch-specific dot options are not line options.
export const lineRadius: DensityX = {...xLine,r:3};
// @ts-expect-error Stack belongs to the area branches.
export const dotStack: DensityY = {...yDot,stack:true};
// @ts-expect-error Count is not a declared normalization method.
export const countNormalization: DensityY = {...yDefault,normalize:'count'};
// @ts-expect-error Density type selectors do not take ParamRef.
export const parameterBaseType: DensityY = {...yDefault,type:'$type'};
// @ts-expect-error Native weight channels are outside the strict declarative option unions.
export const weightedWire: DensityY = {...yDefault,weight:'weight'};
