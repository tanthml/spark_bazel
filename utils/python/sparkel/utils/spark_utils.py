import pytest
from pyspark.sql import SparkSession


# Default Spark configs
_DEFAULT_CONFIGS = {
    "spark.hadoop.validateOutputSpecs": "false",
    "spark.sql.orc.filterPushdown": "true",
}


def get_spark_session(app_name, configs=_DEFAULT_CONFIGS):
    """
    Get Spark session with provided configuration.

    Args:
        app_name (str): app name
        configs (dict): config spark

    Returns:
        (SparkSession): SparkSession
    """
    spark_builder = SparkSession.builder.appName(app_name)
    for config_name, config_value in configs.items():
        spark_builder.config(config_name, config_value)
    spark = spark_builder.getOrCreate()
    spark.sparkContext.setLogLevel('ERROR')
    return spark


@pytest.fixture(scope="session")
def get_test_spark_session(app_name):
    """
    Get Spark session for running test application.

    Args:
        app_name (str):

    Returns:
        (SparkSession)
    """
    spark_builder = SparkSession.builder \
        .appName(app_name) \
        .master('local[*]')
    spark = spark_builder.getOrCreate()
    spark.sparkContext.setLogLevel('ERROR')
    return spark
