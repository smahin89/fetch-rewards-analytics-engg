# Fetch Rewards Analytics Engg by Shankar Mahindar
This is the base repository containing the artifacts related to the take-home assessment

// Setting up the data infrastructure & loading into database for data analysis requirements 
1. Clone this repo --> git clone
2. Create a new virtual environment on python 3.11 --> /opt/homebrew/bin/python3.11 -m venv fetch_venv
3. Open terminal and run the command --> pip install -r requirements.txt
4. I have used DBT or "Data Build Tool" for building the sql scripts as data models which can be used as building blocks of data pipeline using an orchestration system like Airflow. If dbt core is already setup, then skip the next steps and move onyo 5, else follow along for DBT setup
    (a) dbt_project.yml file is provided; no additional setup required. Once dbt is installed, the following command need to be executed to point to the project path --> export DBT_PROJECT_DIR=/users/<local user>/fetch-rewards-analytics-engg/fetch-rewards-analytics-engg/dbt/snowstorm/dbt_project.yml
    (b) create a profiles.yml file using the below template in the snowstorm root directory, in the same level as dbt_project.yml. If dbt core is already setup, then skip this set and move to step (c) -->
    snowstorm:
        target: dev
        outputs:
            dev:
            account: <snowflake account>
            database: <database name>
            password: <password>
            role: <database role>
            schema: <database schema like landing>
            threads: 10
            type: snowflake
            user: <database user>
            warehouse: <snowflake warehouse>
            client_session_keep_alive: False
            connect_retries: 0
            connect_timeout: 10
            retry_on_database_errors: False
            retry_all: False
    (c) Run command from terminal --> export DBT_PROJECT_DIR=/users/<local user>/fetch-rewards-analytics-engg/fetch-rewards-analytics-engg/dbt/snowstorm/profiles.yml
    (d) Run command --> dbt deps
    (e) Finally verify installation with command --> dbt debug
5. I have used Snowflake as the choice of data warehouse setting up the data model and schema. For setting up the data loading tables, run the following commands on terminal while setting the working directory as dbt/snowstorm, which can be found --> dbt/snowstorm/macros/*.sql
    (a) dbt run-operation -s ddl_create_ldg_brands -t dev
    (a) dbt run-operation -s ddl_create_ldg_users -t dev
    (c) dbt run-operation -s ddl_create_ldg_receipts -t dev
6. I have used AWS s3 as the file storage option for to mimic a data-lake scenario where the raw files can be dropped into s3 bucket in json format. I have stored the input files into s3 bucket.
7. Using Snowflake's sql worksheet, the input tables can be loaded for each file using the below command -->

COPY INTO ldg_receipts
    FROM (
        SELECT a.$1, sysdate(), 'com.redica.dev-snowflake/'|| METADATA$FILENAME
        FROM '@<enter database>.SHARED_OBJECTS.<enter stage>/' a
    )
    FILES = ('receipts.json')
    FILE_FORMAT = (
        TYPE=JSON
    )
    FORCE = TRUE;

8. Alternatively, execute the python script from path --> fetch-rewards-analytics-engg/scripts/data_loader.py with the required arguments as described in the code for each file to its target table. The script can later be used for automated file loading using Airflow or Dagster. 
9. Next, run the command to setup the raw tables from the landing tables. This step will help to transform the data from semi-structured (non-relational) to structure (relational) format, usable for business intelligence and analytics purposes -->
    (a) dbt run -s raw_user -t dev
    (b) dbt run -s raw_receipt -t dev
    (c) dbt run -s raw_brand -t dev
    (d) dbt run -s raw_receipt_item -t dev
    OR
    (e) dbt run -s models.raw -t dev (executes all models in the raw directory)
10. Finally, run the command to setup the data modelling star schema which will help answer the analytical queries and perform quality checks later. All these scripts can be found --> dbt/snowstorm/models/analytics/*.sql
    (a) dbt run -s models.analytics -t dev
11. After all the above steps are completed, this step is optional but can provide insight into how the data pipeline has been designed to provide an end-to-end view. The lineage can be viewed in the repo path --> fetch-rewards-analytics-engg/design/data_pipeline_lineage/. For this step, run the command --> dbt docs generate and then dbt docs serve. This should open a localhost/8080 on the web browser displaying each model and their lineage.

// Assessment tasks and response documentation 
# First: Review Existing Unstructured Data and Diagram a New Structured Relational Data Model
A star schema data modelling technique has been used pursuant to Kimball's methodology to design the entity relationship diagram. This diagram can be found in the path of this repo --> fetch-rewards-analytics-engg/design/ERD.pdf.
Fact Tables overview:
There are two fact tables, one at receipt header-level (representing transactional level information like create date, scan date, transaction identifier, etc.) while other at receipt detail-level (representing transactional line item level information like items sold, quantity, price, etc.). 
Each fact table has its own primary key (PK) and foreign key (FK). For receipt item fact table, a primary key has been designed considering a MD5 hash of receipt uuid and partner item id. For receipt fact table, the receipt uuid forms the primary key, which can be also considered as a degenerate or "junk" dimension. Fact_receipt has one-to-many relation with fact_receipt_item. 
Conformed Dimension Table overview:
There is one conformed dimension table: dim_cd_user, which has foreign key relationship associated to both fact tables as one-to-many.
Dimension Tables overview:
There are four dimension tables: dim_item, dim_reward_group, dim_brand and dim_fetch_review where each table represents one unique row per attribute. These tables were formed after deduplication and ensuring any nulls have been handled as a dummy key. Each dimension table is uniquely identified with a separate surrogate key built of the business or functional key(s), and forms the primary key of the dimension.
Bridge Tables overview:
There are three bridge tables: br_fetch_review, br_item and br_reward_group. These bridge tables help maintain the many-to-many relationship with the fact tables, ensuring there is only one unique row in the dimension table. These bridge tables hold the surrogate key from the dimension table as the foreign key while associates the fact tables with the business keys like receipt uuid or partner item id.

# Second: Write queries that directly answer predetermined questions from a business stakeholder
All six business questions have been answered with the underlying sql that can be used to obtain the results and can be found in the repo path --> dbt/snowstorm/analyses/business_stakeholder_sql/*.sql. 

# Third: Evaluate Data Quality Issues in the Data Provided
I have captured some of the data quality issues with the help of sql scripts that can be run on the raw or landing tables, along with comments and examples representing the issues. The scripts can be reviewed in the repo path --> dbt/snowstorm/analyses/data_quality_issues_sql/*.sql.
Additionally, from future production implementation standpoint, I have also built a robust data quality check system using dbt data tests. These tests are configured as yaml defining some standard data engineering best practice quality checkers like null, invalid, empty, etc. These can be also customized and scripted to serve unique business use-cases. For example, I have created some custom test scripts which can be found in the repo path --> dbt/snowstorm/tests/generic/*.sql. These can be executed with the help of an orchestration tool like Airflow or from terminal using the command --> dbt build -s models.raw -t dev. 
Alternatively, these tests can be also built into the CI/CD pipeline or configurable as Pytests in the data pipeline, as per technical needs.

# Fourth: Communicate with Stakeholders
An email has been drafted and available in the repo path --> fetch-rewards-analytics-engg/comms/email.md 

<!-- ------------------Thank you ------------------ -->
