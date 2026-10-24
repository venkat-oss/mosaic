import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';

const cue = process.env.CUE_BIN;
const native = resolve('packages/vgplot/spec/src/generated/common-marks.cue');
const cases = [
  ['ChannelName', ['x', 'fill'], ['unknown', 1]],
  ['ChannelScale', ['color', null], ['bogus', 3]],
  ['ChannelDomainName', ['data', 'width', 'fill'], ['unknown', 2]],
  ['ChannelDomainValue', ['-width', '-x', null], ['--x', '-color']],
  ['ChannelDomainOptions', [{limit:[0,2],order:null,reduce:'mean'}], [{limit:[]},{limit:[1]},{bogus:1}]],
  ['ChannelDomainValueSpec', [{value:'y',limit:[0,2]}], [{},{value:'y',bogus:1}]],
  ['ChannelDomainSort', [{color:{value:'fill',reduce:'mean',limit:[0,2]}}], [{bogus:'x'},{x:{limit:[1]}}]],
  ['ChannelReducers', [{x:'sum',y:{reduce:'max',scale:'y'}}], [{x:'custom'},{bogus:'mean'}]],
  ['ChannelStates', [{x:{value:[1],scale:'x'}}], [{unknown:{value:[],scale:'x'}},{x:{value:[]}}]],
  ['ChannelValues', [{x:[1],channels:{x:{value:[1],scale:'x'}}}], [{x:[1]},{channels:{unknown:{value:[],scale:'x'}}}]],
  ['TipPointer', ['x','xy'], ['both',null]],
  ['SelectFilter', ['nearest','nearestX'], ['other',3]],
  ['MarkData', [{data:[{x:1}]},{data:{from:'rows',filterBy:'$selection'}}], [{},{data:3}]],
  ['MarkDataOptional', [{},{data:[{x:1}]}], [{data:3},{unknown:true}]],
  ['InsetOptions', [{inset:2,insetLeft:0},{inset:'$inset'}], [{inset:false},{unknown:2}]],
  ['Curve', ['linear','catmull-rom'], ['auto','custom']],
  ['CurveOptions', [{curve:'linear'},{curve:'auto'}], [{curve:3},{unknown:1}]],
  ['CurveAutoOptions', [{curve:'auto'},{tension:0.5},{tension:'$tension'}], [{tension:false},{unknown:true}]],
  ['StackOffsetName', ['normalize','center'], ['zero',null]],
  ['StackOffset', ['normalize','wiggle'], ['$offset',null,2,{}]],
  ['StackOrderName', ['inside-out','value'], ['-value','custom']],
  ['StackOrder', ['-value','custom',[1,2]], [3,{}]],
  ['MarkerName', ['arrow','dot'], ['unknown',false]],
  ['MarkerOptions', [{markerEnd:'arrow',markerStart:true}], [{markerEnd:3},{unknown:true}]],
];
function vet(name, value) {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-common-native-'));
  try {
    const input = join(directory, 'input.json');
    writeFileSync(input, JSON.stringify(value));
    execFileSync(cue, ['vet', '-c', native, input, '-d', '#' + name], { stdio:'pipe' });
  } finally { rmSync(directory, { recursive:true, force:true }); }
}
for (const [name, accepted, rejected] of cases) {
  test(`${name} standalone admission preserves independent boundaries`, () => {
    for (const value of accepted) assert.doesNotThrow(() => vet(name,value), JSON.stringify(value));
    for (const value of rejected) assert.throws(() => vet(name,value), JSON.stringify(value));
  });
}
