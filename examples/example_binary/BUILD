load(
    "//dotnet:csharp.bzl", 
    "dotnet_library",
    "dotnet_binary",
)


filegroup(
    name = "dotnet_srcs",
    srcs = glob([
        "*.csproj",
        "*.cs",
    ]),
)

dotnet_library(
    name = "example_library",
    srcs = [
        ":dotnet_srcs",
    ],
    runtime = "ubuntu.14.04-x64",
    configuration = "Debug",
    out =  "example_library.dll",
)


dotnet_binary(
    name = "publish/example_binary",
    srcs = [
        ":dotnet_srcs",
    ],
    runtime = "ubuntu.14.04-x64",
    configuration = "Debug",
    out =  "publish/example_binary",
)