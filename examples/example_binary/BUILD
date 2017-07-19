load("//dotnet:csharp.bzl", "dotnet_library")


filegroup(
    name = "dotnet_srcs",
    srcs = glob([
        "*.csproj",
        "*.cs",
    ]),
)

dotnet_library(
    name = "hello",
    srcs = [
        ":dotnet_srcs",
    ],
    runtime = "ubuntu.14.04-x64",
    configuration = "Debug",
    out =  "bin/example_binary.dll",
)


