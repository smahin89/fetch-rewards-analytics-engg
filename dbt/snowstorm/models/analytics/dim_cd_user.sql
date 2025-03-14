{{
    config(
        materialized='table'
        ,transient=false
        ,description='User conformed dimension table with user_id representing unique record'
    )
}}
select 
    distinct 
    id as user_id
    ,active as active_flag
    ,createdDate as created_date
    ,lastLogin as last_login_date
    ,role as role
    ,signUpSource as signup_source
    ,state as state
from {{ ref('raw_user') }}
