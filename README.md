# rules_dotnet

attempt to update [https://github.com/bazelbuild/rules_dotnet](https://github.com/bazelbuild/rules_dotnet)

to .net core
see [issue #39](https://github.com/bazelbuild/rules_dotnet/issues/39)


** DO NOT USE (this is a work in progress; doesn't work yet (at all!)) **


   - [build](#build)
   - [Log](#log)
     - [7-10-18](#7-10-18)
     - [7-14-18](#7-14-18)
     - [7-16-18](#7-16-18)          
   - [Appendix](#appendix)
     - [Restore](#restore)
     - [Build](#build)
     - [Publish](#publish)          

# build
```
$ bazel build examples/example_binary:hello
```

# Log

## 7-10-18: 
   - Currently just downloads and restores the dependencies in .csproj file.
   lock files updated to home directory outside of bazel, need to address that:
  [https://gist.github.com/salrashid123/2230042d0789867b6e90d817b609d518](https://gist.github.com/salrashid123/2230042d0789867b6e90d817b609d518)


## 7-14-18:
  - downloads coreclr, restores packages to
    ~examples/example_binary
  - todo: figure out how to emit/track the restore outputs...

## 7-16-18:
  - Got build+restore+publish setup with dotnet and msbuild (see appendix)
  - add config to restore .sln and .csproj files (TODO: figure out how to actually restore .sln files)
  - build dll now restores and installs dependencies.  However, the output .dll isn't detected..

eg, from the output below:

```
 Installed:
      11 package(s) to /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj
  example_binary -> /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/bin/Debug/netcoreapp2.0/example_binary.dll
```

is generated, but the output isn't detected:

```
ERROR: /home/srashid/Desktop/bazel/rules_dotnet/examples/example_binary/BUILD:13:1: output 'examples/example_binary/bin/Debug/netcoreapp2.0/example_binary.dll' was not created.
```



```
$ bazel build examples/example_binary:hello
WARNING: /home/srashid/Desktop/bazel/rules_dotnet/dotnet/csharp.bzl:9:9: Building: examples/example_binary/example_binary.csproj.
WARNING: /home/srashid/Desktop/bazel/rules_dotnet/dotnet/csharp.bzl:18:9: bazel-out/local-fastbuild/bin/examples/example_binary/bin/Debug/netcoreapp2.0/example_binary.dll
.
WARNING: /home/srashid/Desktop/bazel/rules_dotnet/dotnet/csharp.bzl:19:9: bazel-out/local-fastbuild/bin
.
INFO: Found 1 target...
INFO: From Restoring dotnet dependencies:
...

Microsoft (R) Build Engine version 15.3.117.23532
Copyright (C) Microsoft Corporation. All rights reserved.

  Restoring packages for /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj...
  Installing Microsoft.NETCore.DotNetAppHost 2.0.0-preview1-002111-00.
  Installing Microsoft.Packaging.Tools 1.0.0-preview1-25301-01.
  Installing Microsoft.NETCore.App 2.0.0-preview1-002111-00.
  Installing Microsoft.NETCore.DotNetHostResolver 2.0.0-preview1-002111-00.
  Installing NETStandard.Library 2.0.0-preview1-25301-01.
  Installing Microsoft.NETCore.DotNetHostPolicy 2.0.0-preview1-002111-00.
  Installing Microsoft.NETCore.Platforms 2.0.0-preview1-25305-02.
  Installing runtime.linux-x64.Microsoft.NETCore.DotNetAppHost 2.0.0-preview1-002111-00.
  Installing runtime.linux-x64.Microsoft.NETCore.DotNetHostResolver 2.0.0-preview1-002111-00.
  Installing runtime.linux-x64.Microsoft.NETCore.DotNetHostPolicy 2.0.0-preview1-002111-00.
  Installing runtime.linux-x64.Microsoft.NETCore.App 2.0.0-preview1-002111-00.
  Generating MSBuild file /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/example_binary.csproj.nuget.g.props.
  Generating MSBuild file /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/example_binary.csproj.nuget.g.targets.
  Writing lock file to disk. Path: /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/project.assets.json
  Restore completed in 9.53 sec for /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj.
  
  NuGet Config files used:
      /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/bazel-out/local-fastbuild/genfiles/.nuget/NuGet/NuGet.Config
  
  Feeds used:
      https://api.nuget.org/v3/index.json
  
  Installed:
      11 package(s) to /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj
  example_binary -> /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/982368022645920033/execroot/io_bazel_rules_dotnet/examples/example_binary/bin/Debug/netcoreapp2.0/example_binary.dll
ERROR: /home/srashid/Desktop/bazel/rules_dotnet/examples/example_binary/BUILD:13:1: output 'examples/example_binary/bin/Debug/netcoreapp2.0/example_binary.dll' was not created.
ERROR: /home/srashid/Desktop/bazel/rules_dotnet/examples/example_binary/BUILD:13:1: not all outputs were created or valid.
Target //examples/example_binary:hello failed to build
Use --verbose_failures to see the command lines of failed build steps.
INFO: Elapsed time: 26.945s, Critical Path: 26.69s
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
