{% macro ddl_create_ldg_receipts() %}

{% call statement(name, fetch_result=true) %}

CREATE OR REPLACE TABLE {{ target.database}}.landing.ldg_receipts
(
    vdt VARIANT,
    created_at TIMESTAMP_NTZ(9),
    SOURCE_FILE_LOCATION VARCHAR(16777216)
)

{% endcall %}

{% endmacro %}