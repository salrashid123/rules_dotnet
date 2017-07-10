
def restore_impl(ctx):

    ctx.action(
        env = {'HOME': str(ctx.files._dotnet_exe[0].short_path), 'DOTNET_CLI_TELEMETRY_OPTOUT': "1"  },
        progress_message="Restoring dotnet dependencies",
        arguments=[
            'restore',
            '--runtime',
            ctx.attr.runtime,
            ctx.attr.srcs[0].files.to_list()[0].short_path,
        ],        
        executable = ctx.executable._dotnet_exe,
        outputs = [ctx.outputs.asset_file]
    )
    

dotnet_restore = rule(
    implementation=restore_impl,
    attrs={        
      "_dotnet_exe": attr.label(default=Label("@dotnet//:dotnet_exe"), single_file=True, executable=True, cfg="host"),
      "runtime":  attr.string(default="ubuntu.14.04-x64"),     
      "srcs": attr.label_list(allow_files = FileType([".cs", ".csproj"])),
    },
    outputs = {"asset_file": "obj/project.assets.json"},    
    )


def _find_and_symlink(repository_ctx, binary, env_variable):
  repository_ctx.file("bin/empty")
  if env_variable in repository_ctx.os.environ:
    return repository_ctx.path(repository_ctx.os.environ[env_variable])
  else:
    found_binary = repository_ctx.which(binary)
    if found_binary == None:
      fail("Cannot find %s. Either correct your path or set the " % binary +
           "%s environment variable." % env_variable)
    repository_ctx.symlink(found_binary, "bin/%s" % binary)

def _csharp_autoconf(repository_ctx):
  _find_and_symlink(repository_ctx, "dotnet", "DOTNET")
  toolchain_build = """\
package(default_visibility = ["//visibility:public"])
exports_files(["dotnet", "DOTNET"])
"""
  repository_ctx.file("bin/BUILD", toolchain_build)

def _coreclr_repository_impl(repository_ctx):
  #dotnet_bin_path = repository_ctx.os.environ.get("DOTNET_BIN_PATH", repository_ctx.attr.dotnet_bin_path)
  _csharp_autoconf(repository_ctx)
  return

coreclr_package = repository_rule(
  implementation = _coreclr_repository_impl,
  attrs = {
  },
  local = True,
)

def csharp_repositories():
  native.new_http_archive(
          name = "dotnet",
          build_file = str(Label("//dotnet:BUILD.dotnet")),
          sha256 = "1774a15ae12dd1786d14397c691411e936cb0937d59add08cc16c89e80aa65c1",
          type = "tgz",
          url = "https://download.microsoft.com/download/0/6/5/0656B047-5F2F-4281-A851-F30776F8616D/dotnet-dev-linux-x64.2.0.0-preview1-005977.tar.gz",
  )

  coreclr_package(name="coreclr")
