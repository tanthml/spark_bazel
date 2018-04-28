load("//tools/bzl:more_python_rules.bzl", "py_zip", "pylint_test")

package(default_visibility = ["//visibility:public"])

py_binary(
    name = "demo_spark_app",
    srcs = ["demo_spark_app.py"],
    deps = [
        "//core/python",
        "//core/python:nlp_lib",
        "//utils/python",
    ],
)

py_zip(
    name = "package",
    srcs = glob(["*.py"]),
    deps = [
        "//core/python",
        "//core/python:nlp_lib",
        "//utils/python",
    ],
)

py_library(
    name = "spark_apps",
    srcs = glob(["*.py"]),
    deps = [
        "//core/python",
        "//utils/python",
    ],
)
