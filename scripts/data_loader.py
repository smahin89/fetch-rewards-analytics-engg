from snowflake.connector import connect
import boto3
import json
import os
import argparse

def load_to_db(stage_name, s3_bucket, s3_key, table_name, snowflake_config):
    """ Load sample dataset files from data lake (s3) into 
        data-warehouse (Snowflake) 
        Note: This script is being used for one-time data loader. For a more
        productionized version, it can be built into a data pipeline whether 
        config values are not hard-coded, rather managed in AWS Secrets and 
        a function can be added to this script to invoke Secrets Manager and 
        retrieve all the necessary information.
    """
    try:
        conn = connect(
            account=snowflake_config["account"],
            user=snowflake_config["user"],
            role=snowflake_config["role"],
            password=snowflake_config["password"],
            warehouse=snowflake_config["warehouse"],
            database=snowflake_config["database"],
            schema=snowflake_config["schema"],
        )
        cursor = conn.cursor()

        aws_access_key_id = snowflake_config["aws_access_key_id"]
        aws_secret_access_key = snowflake_config["aws_secret_access_key"]
        aws_region = snowflake_config.get("aws_region")

        cursor.execute(f"""
            CREATE OR REPLACE STAGE {stage_name}
            URL='s3://{s3_bucket}/'
            CREDENTIALS=(AWS_KEY_ID='{aws_access_key_id}' AWS_SECRET_KEY='{aws_secret_access_key}')
            FILE_FORMAT=(TYPE='JSON', STRIP_OUTER_ARRAY=TRUE);
        """)

        # Copy data from the S3 stage into the Snowflake table
        cursor.execute(f"
                       COPY INTO {snowflake_config.database}.{snowflake_config.schema}.{table_name} 
                       FROM (
                            SELECT a.$1, sysdate(), '{s3_bucket}/'|| METADATA$FILENAME
                            FROM '@{snowflake_config.database}.SHARED_OBJECTS.{stage_name}/{s3_key}' a
                        ) 
                       FILE_FORMAT=(
                            TYPE='JSON', 
                            STRIP_OUTER_ARRAY=TRUE,
                            COMPRESSION=NONE
                        )
                       FORCE=TRUE;"
                    )

    except Exception as e:
        print(f"Error loading data into Snowflake: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Copy data from s3 to snowflake db"
    )
    parser.add_argument("--s3_bucket", help="Provide s3 bucket name")
    parser.add_argument("--s3_key", help="Provide s3 file name like brands.json or receipts.json or users.json")
    parser.add_argument("--table_name", help="Provide target table name like ldg_brands or ldg_receipts or ldg_users")
    parser.add_argument("--stage_name", help="Provide Snowflake s3 stage name preferred like fetch_stage")
    parser.add_argument("--account", help="Provide Snowflake account")
    parser.add_argument("--user", help="Provide Snowflake login user")
    parser.add_argument("--password", help="Provide Snowflake login password")
    parser.add_argument("--warehouse", help="Provide Snowflake warehouse for running scripts")
    parser.add_argument("--database", help="Provide Snowflake target load database like dev_snwflk")
    parser.add_argument("--schema", help="Provide Snowflake target schema like landing")
    parser.add_argument("--aws_access_key_id", help="Provide AWS access key id")
    parser.add_argument("--aws_secret_access_key", help="Provide AWS access key")
    parser.add_argument("--aws_region", help="Provide AWS region")
    
    args = parser.parse_args()
     
    snowflake_config = {
        "account": args.account, 
        "user": args.user,
        "password": args.password,
        "warehouse": args.warehouse,
        "database": args.database,
        "schema": args.schema,
        "aws_access_key_id": args.aws_access_key_id,
        "aws_secret_access_key": args.aws_secret_access_key,
        "aws_region": args.aws_region 
    }

    load_to_db(
        args.s3_bucket, 
        args.s3_key, 
        args.table_name,
        args.stage_name,
        snowflake_config
    )