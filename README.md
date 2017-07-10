# rules_dotnet

attempt to update [https://github.com/bazelbuild/rules_dotnet](https://github.com/bazelbuild/rules_dotnet)

to .net core
see [issue #39](https://github.com/bazelbuild/rules_dotnet/issues/39)


** DO NOT USE (this is a work in progress; doesn't work yet (at all!)) **

```
$ bazel build examples/example_binary:hello
```
- 7/10/18: currently just downloads and restores the dependencies in .csproj file.
   lock files updated to home directory outside of bazel, need to address that:
  [https://gist.github.com/salrashid123/2230042d0789867b6e90d817b609d518](https://gist.github.com/salrashid123/2230042d0789867b6e90d817b609d518)


