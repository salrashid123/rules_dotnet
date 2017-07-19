# rules_dotnet

attempt to update [https://github.com/bazelbuild/rules_dotnet](https://github.com/bazelbuild/rules_dotnet)

to .net core
see [issue #39](https://github.com/bazelbuild/rules_dotnet/issues/39)


** DO NOT USE (this is a work in progress; doesn't work yet (at all!)) **


   - [build](#build)
   - [Log](#log)
     - [7-10-17](#7-10-17)
     - [7-14-17](#7-14-17)
     - [7-16-17](#7-16-17)
     - [7-17-17](#7-17-17)
     - [7-19-17](#7-19-17)    
     - 7-19-17_2(#7-19-17_2)               
   - [Appendix](#appendix)
     - [Restore](#restore)
     - [Build](#build)
     - [Publish](#publish)          

# build
```
$ bazel build examples/example_binary:hello
```

# Log

## 7-10-17: 
   - Currently just downloads and restores the dependencies in .csproj file.
   lock files updated to home directory outside of bazel, need to address that:
  [https://gist.github.com/salrashid123/2230042d0789867b6e90d817b609d518](https://gist.github.com/salrashid123/2230042d0789867b6e90d817b609d518)


## 7-14-17:
  - downloads coreclr, restores packages to
    ~examples/example_binary
  - todo: figure out how to emit/track the restore outputs...

## 7-16-17:
  - Got build+restore+publish setup with dotnet and msbuild (see appendix)
  - add config to restore .sln and .csproj files (TODO: figure out how to actually restore .sln files)
  - build dll now restores and installs dependencies.  However, the output .dll isn't detected..

## 7-17-17:

```
bazel build examples/example_binary:hello
.
INFO: Found 1 target...
INFO: From Restoring dotnet dependencies:

Configuring...
Microsoft (R) Build Engine version 15.3.117.23532
...
  Restoring packages for /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj...
  Installing System.Runtime.Handles 4.0.1.
  Installing Microsoft.NETCore.DotNetAppHost 2.0.0-preview1-002111-00.
  Installing System.IO.FileSystem 4.0.1.
  Installing System.IO.FileSystem.Primitives 4.0.1.
  Installing System.Threading.Tasks.Extensions 4.0.0.
  Installing System.Runtime.InteropServices 4.1.0.
  Installing Microsoft.NETCore.App 2.0.0-preview1-002111-00.
...
...
  Generating MSBuild file /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/example_binary.csproj.nuget.g.props.
  Generating MSBuild file /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/example_binary.csproj.nuget.g.targets.
  Writing lock file to disk. Path: /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/project.assets.json
  Restore completed in 6.71 sec for /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj.
  
  NuGet Config files used:
      /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/bazel-out/local-fastbuild/genfiles/.nuget/NuGet/NuGet.Config
  
  Feeds used:
      https://api.nuget.org/v3/index.json
  
  Installed:
      70 package(s) to /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj
  example_binary -> /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/2212679950424302319/execroot/io_bazel_rules_dotnet/examples/example_binary/bin/Debug/netcoreapp2.0/example_binary.dll
ERROR: /home/srashid/Desktop/bazel/rules_dotnet/examples/example_binary/BUILD:12:1: output 'examples/example_binary/bin/Debug/netcoreapp2.0/example_binary.dll' was not created.
ERROR: /home/srashid/Desktop/bazel/rules_dotnet/examples/example_binary/BUILD:12:1: not all outputs were created or valid.
Target //examples/example_binary:hello failed to build
Use --verbose_failures to see the command lines of failed build steps.
INFO: Elapsed time: 27.968s, Critical Path: 27.42s

```

TODO: figure out if its ok to keep dependency directly inside

example_binary.csproj: 

```xml
<ItemGroup>
  <PackageReference Include="Newtonsoft.Json" Version="9.0.1" />
</ItemGroup>
```

## 7-19-17:

- Removed unecessary donet cli initializatoin
- Added /p:OutputDire=bin  to msbuild
- Still unable to map  generated file

```
/home/srashid/.cache/bazel/_bazel_srashid/074efdfd083fa382423f186b413a3f8a/bazel-sandbox/4615100056060896496/execroot/io_bazel_rules_dotnet/examples/example_binary/bin/example_binary.dll
```

to the declared output....

```
/home/srashid/Desktop/rules_dotnet/examples/example_binary/BUILD:12:1: output 'examples/example_binary/bin/example_binary.dll' was not created.
```

### 7-19-17_2:

Added prefix to output directory (atleast now it builds and finds the output)

```
        dir_arr = ctx.outputs.out.dirname.split('/')[4:]
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
```

# Appendix

  - msbuild reserved propeties:
      - [https://msdn.microsoft.com/en-us/library/ms164309(v=vs.100).aspx](https://msdn.microsoft.com/en-us/library/ms164309(v=vs.100).aspx)
      
## Restore

```
        dotnet restore -r ubuntu.14.04-x64
        dotnet msbuild /t:Restore /p:RuntimeIdentifiers=ubuntu.14.04-x64
           --> obj/
```

## Build

```
        dotnet build -r ubuntu.14.04-x64
        dotnet msbuild /t:Build /p:RuntimeIdentifier=ubuntu.14.04-x64
         -->   bin/Debug/netcoreapp2.0/ubuntu.14.04-x64/standalone.dll
```

## Publish

```
        dotnet publish -c Release -r ubuntu.14.04-x64
        dotnet msbuild /t:Publish /p:Configuration=Release /p:RuntimeIdentifier=ubuntu.14.04-x64 /p:OutputPath=bin/        
          -->    bin/%{name}.dll
          -->    bin/publish/%{name}
```
