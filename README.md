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
     - [7-19-17](#7-19-17)    
     - [7-19-17-2](#7-19-17-2)
     - [7-23-17](#7-23-17)                    
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


## 7-14-17:
  - downloads coreclr, restores packages to
    ~examples/example_binary
  - todo: figure out how to emit/track the restore outputs...

## 7-16-17:
  - Got build+restore+publish setup with dotnet and msbuild (see appendix)
  - add config to restore .sln and .csproj files (TODO: figure out how to actually restore .sln files)
  - build dll now restores and installs dependencies.  However, the output .dll isn't detected..


## 7-19-17:

- Removed unecessary donet cli initializatoin
- Added /p:OutputDire=bin  to msbuild
- Still unable to map  generated file

to the declared output....


### 7-19-17-2:

Added prefix to output directory (atleast now it builds and finds the output)


### 7-23-17:

- Binary created at  _bazel-bin/examples/example_binary/publish/example_binary_


```
$ bazel build examples/example_binary:publish/example_binary

INFO: Found 1 target...
INFO: From Restoring dotnet dependencies:

  Restoring packages for /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj...
  Installing System.Runtime.Handles 4.0.1.
  Installing Microsoft.NETCore.DotNetAppHost 2.0.0-preview1-002111-00.
  ...
  ...
  Installing runtime.any.System.Collections 4.0.11.
  Generating MSBuild file /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/example_binary.csproj.nuget.g.props.
  Generating MSBuild file /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/example_binary.csproj.nuget.g.targets.
  Writing lock file to disk. Path: /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/examples/example_binary/obj/project.assets.json
  Restore completed in 15.74 sec for /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj.
  
  Installed:
      70 package(s) to /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/examples/example_binary/example_binary.csproj
  example_binary -> /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/bazel-out/local-fastbuild/bin/examples/example_binary/example_binary.dll
  example_binary -> /home/srashid/.cache/bazel/_bazel_srashid/c94c7f44f11e0c40e1f52ac7b1d3db00/bazel-sandbox/3504825734647556254/execroot/io_bazel_rules_dotnet/bazel-out/local-fastbuild/bin/examples/example_binary/publish/

Target //examples/example_binary:publish/example_binary up-to-date:
  bazel-bin/examples/example_binary/publish/example_binary
INFO: Elapsed time: 35.268s, Critical Path: 33.98s

```

- msbuild Publish always created a ~/publish folder so had to play games with directories
- TODO:

  - Figure out how to copy all the files created in the following folder over as runfiless
    ```
    execroot/io_bazel_rules_dotnet/bazel-out/local-fastbuild/bin/examples/example_binary/publish/
    ```
   

  - Fix  BUILD name
    ```
    dotnet_binary(
      name = "publish/example_binary",
    ```

# Appendix

  - msbuild reserved propeties:
      - [https://msdn.microsoft.com/en-us/library/ms164309(v=vs.100).aspx](https://msdn.microsoft.com/en-us/library/ms164309(v=vs.100).aspx)
      - [https://docs.microsoft.com/en-us/aspnet/core/hosting/directory-structure](https://docs.microsoft.com/en-us/aspnet/core/hosting/directory-structure)
      - [https://msdn.microsoft.com/en-us/library/bb629394.aspx](https://msdn.microsoft.com/en-us/library/bb629394.aspx)

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
