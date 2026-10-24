import { asLiteral, compile, createExecutionContext, native } from '@uwdata/mosaic-sql/native';

const query = native.select([native.alias(asLiteral(42), 'value')]);
const statements = compile([query], createExecutionContext());
document.getElementById('native-query').textContent = statements.join(';\n');
