import type { Geo, Sphere, Graticule, DelaunayLink, Voronoi } from '../src/index.js';
export const geo: Geo={mark:'geo',data:[{shape:{type:'Point',coordinates:[0,0]}}],geometry:'shape',r:4};
export const values: Geo={mark:'geo',data:[{}],geometry:[{type:'Point',coordinates:[0,0]}]};
export const sphere: Sphere={mark:'sphere',stroke:'steelblue'};
export const graticule: Graticule={mark:'graticule',fill:null};
export const link: DelaunayLink={mark:'delaunayLink',data:[],x:'x',y:'y',z:'group',curve:'linear'};
export const voronoi: Voronoi={mark:'voronoi',data:[],x:0,y:1};
// @ts-expect-error Sphere has no declarative data channel.
export const dataSphere: Sphere={mark:'sphere',data:[]};
// @ts-expect-error GeoJSON objects are not declarative MarkData.
export const collection: Geo={mark:'geo',data:{type:'FeatureCollection',features:[]}};
// @ts-expect-error Geo requires declarative data.
export const absent: Geo={mark:'geo'};
// @ts-expect-error Native geometry callbacks are outside ChannelValue.
export const callback: Geo={mark:'geo',data:[],geometry:()=>({type:'Point',coordinates:[0,0]})};
