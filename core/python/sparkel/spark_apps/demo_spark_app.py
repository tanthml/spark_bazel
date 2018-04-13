# -*- coding: utf-8 -*-
"""

How to run:

bazel run core/python/sparkel/spark_apps:package \
-- core/python/sparkel/spark_apps/demo_spark_app.py \
--input_path /tmp/text.csv --output_dir /tmp/num_words.csv --text_col content

"""
import click
from pyspark.sql.functions import udf  # pylint: disable-msg=E0611
from pyspark.sql.types import IntegerType, StringType

from sparkel.utils import spark_utils
from sparkel.nlp.words import word_count


@click.command()
@click.option('--input_path', required=True, help='Input directory/file')
@click.option('--output_dir', required=True, help='Output directory ')
@click.option(
    '--text_col',
    default='content',
    type=str,
    help='Text column name'
)
def main(input_path, output_dir, text_col):
    """
    Demo application load an csv file and count number of words
    Args:
        input_path (str):
        output_dir (str):
        text_col (str):

    Returns:

    """
    spark = spark_utils.get_spark_session("GET DOCUMENT LENGTH")

    df = spark.read \
    .format("csv") \
    .option("inferSchema", "true") \
    .option("header", "true").load(input_path.rstrip("/"))

    print(df.show())

    # define a udf function apply on a single text/ row data
    get_count = udf(lambda text: word_count(text), IntegerType())

    # convert text column to string
    df = df.withColumn(text_col, df[text_col].cast(StringType()))

    # apply th udf function and add result to new colum
    new_col = 'doc_length'
    data_df = df.withColumn(new_col, get_count(text_col))

    (data_df.coalesce(1).write.format('com.databricks.spark.json')
        .mode('overwrite')
        .option("header", "true")
        .json(output_dir)
    )
    print(data_df.show())
    print("======== DONE ++++++++")


if __name__ == '__main__':
    main()
