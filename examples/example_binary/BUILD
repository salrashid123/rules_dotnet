load("//dotnet:csharp.bzl", "dotnet_binary")


filegroup(
    name = "dotnet_srcs",
    srcs = glob([
        "*.csproj",
    ]),
)

dotnet_binary(
    name = "hello",
    srcs = [
        ":dotnet_srcs",
    ],
)


