from datetime import timedelta

import pendulum
import awswrangler as wr
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.amazon.aws.hooks.s3 import S3Hook


default_args = {
    'owner': 'Dima S.',
    'depends_on_past': False,
    'start_date': pendulum.today('UTC').add(days=-1),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
}


def fetch_records():
    query = "SELECT * FROM data"
    db_client = MySqlHook(mysql_conn_id='replica_creds')
    df = db_client.get_pandas_df(sql=query)

    wr.s3.to_csv(
        df=df,
        path="s3://yp-mwaa-source/data/file.csv",
    )

    print(df.head())
    return df.shape


with DAG(dag_id="extract_data",
         default_args=default_args,
         description='Description',
         schedule_interval=None,
         catchup=False) as dag_all:
    extract_task = PythonOperator(task_id="extract_data",
                                  python_callable=fetch_records,
                                  op_kwargs={})

    extract_task
