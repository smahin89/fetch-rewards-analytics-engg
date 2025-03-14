{{
    config(
        materialized='table'
        ,transient=false
        ,description='Transformation from semi-structured to relational-structured format'
    )
}}
select 
    vdt:"_id":"$oid"::varchar as id
    ,vdt:"active"::string as active
    ,TO_TIMESTAMP_NTZ(vdt:"createdDate":"$date"::string) as createdDate
    ,TO_TIMESTAMP_NTZ(vdt:"lastLogin":"$date"::string) as lastLogin
    ,vdt:"role"::string as role
    ,vdt:"signUpSource"::string as signUpSource
    ,vdt:"state"::string as state
from {{ source('landing','ldg_users') }}