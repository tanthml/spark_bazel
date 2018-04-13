def get_transitive_srcs(srcs, deps):
  """Obtain the source files for a target and its transitive dependencies.

  Args:
    srcs: a list of source files
    deps: a list of targets that are direct dependencies
  Returns:
    a collection of the transitive sources
  """
  trans_srcs = depset()
  for dep in deps:
    trans_srcs += dep.data_runfiles.files
  trans_srcs += srcs
  return trans_srcs

def _py_zip_binary_impl(ctx):
  pyzip = ctx.executable._pyzip
  out = ctx.outputs.zip
  trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
  srcs_list = trans_srcs.to_list()
  cmd_string = (pyzip.path + " " + out.path + " " +
                " ".join([src.path for src in srcs_list]))
  ctx.action(command=cmd_string,
             inputs=srcs_list + [pyzip],
             outputs=[out])
  ctx.template_action(
      # Access the executable output file using ctx.outputs.executable.
      output=ctx.outputs.executable,
      template=ctx.file._template,
      substitutions={
        "%zip_file%": out.short_path,
      },
      executable=True
  )
  return struct(runfiles=ctx.runfiles([ctx.outputs.zip] + ctx.files.srcs))

py_zip = rule(
    implementation = _py_zip_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files=True),
        "deps": attr.label_list(),
        "_pyzip": attr.label(default=Label("//tools/bzl:pyzip"),
                             allow_files=True, executable=True, cfg="host"),
        "_template": attr.label(
          default=Label("//tools/bzl:pyzip_template"),
          allow_files=True, single_file=True)
    },
    outputs = {"zip": "%{name}.zip"},
    executable=True
)

def _pylint_test_impl(ctx):
  # The command may only access files declared in inputs.
  srcs = " ".join([src.path for src in ctx.files.srcs])
  ctx.file_action(
      output=ctx.outputs.executable,
      content="pylint --rcfile='%s' %s" % (ctx.file._rcfile.path, srcs),
      executable=True)
  return struct(runfiles=ctx.runfiles([ctx.file._rcfile]))

pylint_test = rule(
    implementation=_pylint_test_impl,
    attrs = {
        "srcs": attr.label_list(allow_files=True),
        "_rcfile": attr.label(
          default=Label("//tools/bzl:pylint_rcfile"),
          allow_files=True, single_file=True)
    },
    executable=True,
    test=True
)
