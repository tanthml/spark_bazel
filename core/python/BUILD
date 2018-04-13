package(default_visibility = ["//visibility:public"])

py_library(
    name = "python",
    srcs = glob(["*.py"]),
    imports = ["."],
    deps = [
        "//core/python/sparkel",
    ],
)

py_library(
    name = "nlp_lib",
    srcs = glob(["*.py"]),
    imports = ["."],
    deps = [
        "//core/python/sparkel",
        "//core/python/sparkel/nlp",
    ],
)
