# spark_bazel

Some of my friends ask me recently how to code a pyspark or spark applications

So I create this tutorial for everyone who want to run spark application easly, these techniques I learned from my leader and I should share to everyone :D.

# Setp-up

- I work on an Ubunutu 16.04 based, it's called elmentary OS - 0.4.1 Loki - https://elementary.io/
- `JDK 8` not 9
- Using miniconda2 `python2` from https://conda.io/miniconda.html
- Install bazel (`0.11.1`) from here https://docs.bazel.build/versions/master/install.html
- Download Spark from http://spark.apache.org/downloads.html, in this tutorial I will use version 2.3.0
- Unzip spark package to somewhere, for examlple : `~/spark/spark-2.3.0-bin-hadoop2.7`
- Update your bashrc with `SPARK_HOME` then run `source path/to/bashprofile`

```
    ...
    # added by Miniconda2 installer
    export PATH="/home/<user-name>/miniconda2/bin:$PATH"
    export SPARK_HOME="/home/<user-name>/spark/spark-2.3.0-bin-hadoop2.7"

```

- Install python packages
```
    pip install pytest click pyspark
```

# How to run

Run test
```
bazel test core/pythontests/sparkel/core:test_nlp_words

```

Run build to check before run on spark
```
bazel build core/python/sparkel/spark_apps:package

```


Run program, `be careful, since the output directory will be overwritten`
```
bazel run core/python/sparkel/spark_apps:package -- core/python/sparkel/spark_apps/demo_spark_app.py --input_path /tmp/text.csv --output_dir /tmp/num_words --text_col content

```

# How to code

Look at the file `core/python/sparkel/spark_apps/demo_spark_app.py`
It imports function from `core/python/sparkel/nlp`
It have a small issue/bug, let figure out by yourself ;)


So you can play around with them, if have any issues, just report here or invite me coffee,tea or tea-milk :D if you live in HCM city.

If I have time, will write a article about this bazel build structure later. 
