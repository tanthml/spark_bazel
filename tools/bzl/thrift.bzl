_thrift_filetype = FileType([".thrift"])
_thriftlib_tar_filetype = FileType([".thriftlib.tar"])


def _get_target_genfiles_root(ctx):
    return ctx.label.package + ":" + ctx.label.name


def _mkdir_command_string(path):
    return "mkdir -p \"" + path + "\""


def _ls_command_string(path):
    return "ls -l \"" + path + "\"/"


def _cp_command_string(from_path, to_path):
    return ("cp \"" + from_path + "\" " +
            "\"" + to_path + "\"/")


def _fix_timestamps_command_string(root):
    return ("find \"" + root + "\" -mindepth 1" +
            " -exec touch -t 198001010000 \"{}\" +")


def _tar_extract_command_string(filename, to_path):
    return "tar -xC \"" + to_path + "\"" + " -f \"" + filename + "\""


def _thrift_java_compile_command_string(include_dir, java_root, src):
    return ("thrift -strict -gen java -out \"" + java_root + "\"" +
            " -I \"" + include_dir + "\" \"" + src.path + "\"")


def _get_full_remove_prefix(ctx):
    remove_prefix = ctx.attr.remove_prefix
    if remove_prefix != "":
        remove_prefix_label = ctx.label.relative(remove_prefix)
        if remove_prefix == ".":
            remove_prefix = ctx.label.package
        else:
            remove_prefix = "/".join([ctx.label.package,
                                      remove_prefix])
        for src in ctx.files.srcs:
            if not src.path.startswith(remove_prefix):
                fail("All srcs must be under remove_prefix path")
            elif (len(src.path) != len(remove_prefix) and 
                    src.path[len(remove_prefix)] != "/"):
                fail("Remove_prefix must be a directory")

    return remove_prefix


def _thrift_library_impl(ctx):
    target_genfiles_root = _get_target_genfiles_root(ctx)

    transitive_archive_files = set(order="compile")
    for dep in ctx.attr.deps:
        transitive_archive_files = transitive_archive_files.union(
            dep._transitive_archive_files)
        transitive_archive_files = transitive_archive_files.union(dep.files)

    commands = [
        _mkdir_command_string(target_genfiles_root),
    ]

    remove_prefix = _get_full_remove_prefix(ctx)
    for f in ctx.files.srcs:
        file_dirname = f.dirname[len(remove_prefix):]
        target_path = (target_genfiles_root + "/" + file_dirname)
        commands.append(_mkdir_command_string(target_path))
        commands.append(_cp_command_string(f.path, target_path))
    commands.extend([
        _fix_timestamps_command_string(target_genfiles_root),
        "tar -cf \"" + ctx.outputs.libarchive.path + "\"" +
        " -C \"" + target_genfiles_root + "\"" +
        " .",
    ])
    ctx.action(
        inputs = ctx.files.srcs,
        outputs = [ctx.outputs.libarchive],
        command = " && ".join(commands),
    )
    return struct(
        srcs=ctx.files.srcs,
        _transitive_archive_files=transitive_archive_files,
    )


thrift_library = rule(
    _thrift_library_impl,
    attrs={
        "srcs": attr.label_list(allow_files=_thrift_filetype),
        "deps": attr.label_list(allow_files=_thriftlib_tar_filetype),
        "remove_prefix": attr.string(),
        "_transitive_archive_files": attr.label_list(),
    },
    outputs={"libarchive": "lib%{name}.thriftlib.tar"},
)


def _gen_thrift_srcjar_impl(ctx):
    target_genfiles_root = _get_target_genfiles_root(ctx)
    thrift_includes_root = "/".join(
        [ target_genfiles_root, "thrift_includes"])
    gen_java_dir = "/".join([target_genfiles_root, "gen-java"])

    commands = []
    commands.append(_mkdir_command_string(target_genfiles_root))
    commands.append(_mkdir_command_string(thrift_includes_root))

    thrift_lib_archive_files = ctx.attr.thrift_library._transitive_archive_files
    for f in thrift_lib_archive_files:
        commands.append(
            _tar_extract_command_string(f.path, thrift_includes_root))

    commands.append(_mkdir_command_string(gen_java_dir))
    thrift_lib_srcs = ctx.attr.thrift_library.srcs
    for src in thrift_lib_srcs:
        commands.append(_thrift_java_compile_command_string(
            thrift_includes_root, gen_java_dir, src))
        commands.append(_fix_timestamps_command_string(gen_java_dir))

    out = ctx.outputs.srcjar
    commands.append(ctx.file._jar.path + " cMf \"" + out.path + "\"" +
                    " -C \"" + gen_java_dir + "\" .")

    inputs = (
        list(thrift_lib_archive_files) + thrift_lib_srcs + [ctx.file._jar] + ctx.files._jdk)

    ctx.action(
        inputs = inputs,
        outputs = [ctx.outputs.srcjar],
        command = " && ".join(commands),
    )


thrift_java_srcjar = rule(
    _gen_thrift_srcjar_impl,
    attrs={
        "thrift_library": attr.label(
            mandatory=True, providers=['srcs', '_transitive_archive_files']),
        "_jar": attr.label(
            default=Label("@bazel_tools//tools/jdk:jar"),
            allow_files=True,
            single_file=True),
        "_jdk": attr.label(
            default=Label("@bazel_tools//tools/jdk:jdk"),
            allow_files=True),
    },
    outputs={"srcjar": "lib%{name}.srcjar"},
)


def thrift_java_library(name, thrift_library, deps=[], visibility=None):
    thrift_java_srcjar(
        name=name + '_srcjar',
        thrift_library=thrift_library,
        visibility=visibility,
    )
    native.java_library(
        name=name,
        srcs=[name + '_srcjar'],
        deps=deps + [
            "//external:jar/org/apache/thrift/libthrift",
            "//external:jar/org/slf4j/slf4j_api",
        ],
        visibility=visibility,
    )
