<script setup>
import { onMounted, ref } from 'vue';

const sql = ref('Loading compiler…');

onMounted(async () => {
  try {
    const { asLiteral, compile, createExecutionContext, native } = await import('@uwdata/mosaic-sql/native');
    sql.value = compile([
      native.select([native.alias(asLiteral(42), 'value')])
    ], createExecutionContext()).join(';\n');
  } catch (error) {
    sql.value = error.message;
    throw error;
  }
});
</script>

<template>
  <pre data-native-compiler>{{ sql }}</pre>
</template>
