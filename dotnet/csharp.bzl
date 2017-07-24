
def library_impl(ctx):

    args = [f.path for f in ctx.files.srcs]
     
    for f in args:     
      if (f.endswith(".csproj")):
        print("Building: " + f)

        dir_arr = ctx.outputs.out.dirname.split('/')[3:]
        prefix = ''
        for i in dir_arr:
          prefix = prefix + '../'

        ctx.action(
            env = {'HOME': ctx.genfiles_dir.path, 'DOTNET_CLI_TELEMETRY_OPTOUT': "1"  },                 
            progress_message="Restoring dotnet dependencies",
            inputs=ctx.files.srcs,
            arguments=[
                'msbuild',
                '/m',
                '/t:Restore,Build',
                '/p:OutputPath={prefix}{output_dir}'.format(prefix=prefix,output_dir = ctx.outputs.out.dirname),
                '/p:RuntimeIdentifiers=' + ctx.attr.runtime,
                '/p:Configuration=' + ctx.attr.configuration,
                '/v:m',
                f
            ],     
            executable = ctx.executable._dotnet_exe, 
            outputs = [ ctx.outputs.out ],
        )

def binary_impl(ctx):

    args = [f.path for f in ctx.files.srcs]
     
    for f in args:     
      if (f.endswith(".csproj")):
        print("Building: " + f)

        dir_arr = ctx.outputs.out.dirname.split('/')[4:]
        prefix = ''
        for i in dir_arr:
          prefix = prefix + '../'

        publish_path = '{prefix}{output_dir}/'.format(prefix=prefix,output_dir = ctx.outputs.out.dirname).replace("publish/","")

        f1 = ctx.new_file(ctx.outputs.out,"libhostfxr.so")

        ctx.action(
            env = {'HOME': ctx.genfiles_dir.path, 'DOTNET_CLI_TELEMETRY_OPTOUT': "1"  },                 
            progress_message="Restoring dotnet dependencies",
            inputs=ctx.files.srcs,
            arguments=[
                'msbuild',
                '/t:Restore,Build,Publish',
                '/p:OutputPath=' + publish_path,
                '/p:RuntimeIdentifier=' + ctx.attr.runtime,
                '/p:Configuration=' + ctx.attr.configuration,
                f
            ],     
            executable = ctx.executable._dotnet_exe, 
            outputs = [ ctx.outputs.out, f1 ],
        )
  
        #transitive_runfiles = depset()
        #for dep in ctx.outputs:
        #  transitive_runfiles += dep.transitive_runtime_files

        runfiles = ctx.runfiles(
          files = [ctx.outputs.out, f1 ],
          #transitive_files = transitive_runfiles,
          collect_default = True,
        )
        return struct(runfiles = runfiles)


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

dotnet_binary = rule(
    implementation=binary_impl,
    executable=True,
    attrs={        
      "_dotnet_exe": attr.label(default=Label("@dotnet//:dotnet_exe"), single_file=True, executable=True, cfg="host"),
      "runtime":  attr.string(default="ubuntu.14.04-x64"),     
      "configuration":  attr.string(default="Debug"),      
      "srcs": attr.label_list(allow_files = FileType([".sln", ".cs", ".csproj"])),
      "out": attr.output(mandatory=True),             
    },    
)

def csharp_repositories(use_local_dotnet=False):
  native.new_http_archive(
          name = "dotnet",
          build_file = str(Label("//dotnet:BUILD.dotnet")),
          sha256 = "1774a15ae12dd1786d14397c691411e936cb0937d59add08cc16c89e80aa65c1",
          type = "tgz",
          url = "https://download.microsoft.com/download/0/6/5/0656B047-5F2F-4281-A851-F30776F8616D/dotnet-dev-linux-x64.2.0.0-preview1-005977.tar.gz",
  )