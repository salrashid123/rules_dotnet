
def library_impl(ctx):

    args = [f.path for f in ctx.files.srcs]
     
    for f in args:     
      if (f.endswith(".csproj")):
        print("Building: " + f)

        #obj = ctx.actions.declare_directory("obj")
        #obj = ctx.new_file(ctx.genfiles_dir, "obj")
        #pkg = ctx.new_file(ctx.genfiles_dir, "pkg")

        #print(obj.path + '\n')
        #print(pkg.path + '\n') 

        print(ctx.outputs.out.path + '\n')    
        print(ctx.bin_dir.path + '\n')
        
        ctx.action(
            env = {'HOME': ctx.genfiles_dir.path, 'DOTNET_CLI_TELEMETRY_OPTOUT': "1"  },                 
            progress_message="Restoring dotnet dependencies",
            inputs=ctx.files.srcs,
            arguments=[
                'msbuild',
                '/m',
                '/t:Restore,Build', 
                '/p:RuntimeIdentifiers=' + ctx.attr.runtime,
                '/p:Configuration=' + ctx.attr.configuration,
                '/v:m',
                f
            ],     
            executable = ctx.executable._dotnet_exe, 
            outputs = [ ctx.outputs.out ],
        )
        #ctx.file_action(output=pkg, content="blah", executable=False)
        #return struct(runfiles=ctx.runfiles([obj]))     


dotnet_library = rule(
    implementation=library_impl,
    attrs={        
      "_dotnet_exe": attr.label(default=Label("@dotnet//:dotnet_exe"), single_file=True, executable=True, cfg="host"),
      "runtime":  attr.string(default="ubuntu.14.04-x64"),     
      "configuration":  attr.string(default="Debug"),      
      "srcs": attr.label_list(allow_files = FileType([".sln", ".cs", ".csproj"])),
      "out": attr.output(mandatory=True),             
    },    
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
  use_local = repository_ctx.os.environ.get(
    "RULES_DOTNET_USE_LOCAL_DOTNET", repository_ctx.attr.use_local)
  _csharp_autoconf(repository_ctx)
  return

coreclr_package = repository_rule(
  implementation = _coreclr_repository_impl,
  attrs = {
    "use_local": attr.bool(default=False),
  },
  local = True,
)

def csharp_repositories(use_local_mono=False):
  native.new_http_archive(
          name = "dotnet",
          build_file = str(Label("//dotnet:BUILD.dotnet")),
          sha256 = "1774a15ae12dd1786d14397c691411e936cb0937d59add08cc16c89e80aa65c1",
          type = "tgz",
          url = "https://download.microsoft.com/download/0/6/5/0656B047-5F2F-4281-A851-F30776F8616D/dotnet-dev-linux-x64.2.0.0-preview1-005977.tar.gz",
  )

  coreclr_package(name="coreclr")
