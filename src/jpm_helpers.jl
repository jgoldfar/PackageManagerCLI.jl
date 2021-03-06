using ArgParse

function parse_cl_settings(PWD = pwd(), default_pkgname = first(splitext(basename(pwd()))))
    s = ArgParseSettings("jpm - CLI for the Julia Package Management and Development system.\n\nRun any command with the option -h to get help for that command.",
                         version = "0.1",
                         add_version = true,
                         add_help = true,
                         commands_are_required = false,
                         epilog="Copyright (c) 2016 Jonathan Goldfarb",
                         prog="jpm",
                         )
    @add_arg_table s begin
        "develop"
        help = "Generate new package."
        action = :command
        "add"#, "install", "clone"
        help = "Add a registered or unregistered package"
        action = :command
        "build"
        help = "Run Pkg.build for a package"
        action = :command
        "checkout"
        help = "Check out a package (i.e. update to master branch)"
        action = :command
        "link"#, "ln"
        help = "Symlink a package into your Pkg.dir()"
        action = :command
        "links"#, "lns"
        help = "List all packages currently Symlinked into Pkg.dir()"
        action = :command
        "list"#, "ls"
        help = "List installed packages"
        action = :command
        "publish"
        help = "Publish unregistered (but tagged) packages"
        action = :command
        "delete"#, "rm"
        help = "Remove a package"
        action = :command
        "status"
        help = "Print Pkg.status()"
        action = :command
        "search"
        help = "Search from among installed packages"
        action = :command
        "test"
        help = "Run package tests"
        action = :command
        "tag"
        help = "Tag a new package version"
        action = :command
        "unlink"
        help = "Unlink a symlinked package from Pkg.dir()"
        action = :command
        "update"
        help = "Update package metadata and resolve all packages"
        action = :command
        "resolve"
        help = "Install/upgrade packages and dependencies according to your REQUIRE file."
        action = :command
        "pin"
        help = "Pin a package to the current version"
        action = :command
        "free"
        help = "Unpin a package"
        action = :command
        "--verbose"
        help = "verbose output"
        action = :store_true
    end

    @add_arg_table s["add"] begin
        "pkg"
        help = "Package or URL to add"
        required = true
        "ver"
        help = "Version"
        required = false
    end
    @add_arg_table s["build"] begin
        "pkg"
        help = "Package to build"
        required = true
    end
    @add_arg_table s["checkout"] begin
        "pkg"
        help = "Package to checkout"
        required = true
        "branch"
        help = "Branch to checkout"
        required = false
    end
    @add_arg_table s["delete"] begin
        "pkg"
        help = "Package to delete"
        required = true
    end
    @add_arg_table s["search"] begin
        "txt"
        help = "Text to search for"
        required = true
    end
    @add_arg_table s["test"] begin
        "pkg"
        help = "Package to test"
        required = true
    end
    @add_arg_table s["tag"] begin
        "pkg"
        help = "Package to tag"
        required = true
        "ver"
        help = "One of patch, minor, or major"
        required = false
        arg_type = Symbol
        default = :patch
    end
    @add_arg_table s["pin"] begin
        "pkg"
        help = "Package to pin"
        required = true
        "ver"
        help = "Version to pin package at"
        required = false
    end
    @add_arg_table s["free"] begin
        "pkg"
        help = "Package to free"
        required = true
    end
    @add_arg_table s["list"] begin
        "--plain"
        help = "If true, output newline-delimited names of packages."
        action = :store_true
    end
    @add_arg_table s["develop"] begin
        "pkg"
        help = "Package to generate"
        required = false
        default = default_pkgname
        "path"
        help = "Path for generated package"
        required = false
        default = pwd()
        "--license"
        help = "License to give new package"
        arg_type = AbstractString
        default = "MIT"
        required = false
        "--force"
        help = "Force overwriting files in [path]"
        action = :store_true
    end
    @add_arg_table s["link"] begin
        "destpkg"
        help = "Destination package name"
        required = false
        default = default_pkgname
        "srcpath"
        help = "Source folder for link"
        required = false
        default = pwd()
    end
    @add_arg_table s["unlink"] begin
        "pkg"
        help = "Package to unlink"
        required = false
        default = default_pkgname
    end
    s
end

const jpm_cli_settings_default = parse_cl_settings()
usage() = parse_args(["--help"], jpm_cli_settings_default)

export parse_and_run
function parse_and_run(PWD = pwd(), default_pkgname = first(splitext(basename(pwd()))))
    args = parse_args(parse_cl_settings(PWD, default_pkgname))
    cmd = args["%COMMAND%"]

    if cmd == nothing
      usage()
    else
      # dump(args)
      # dump(cmd)
      return exec_cmd(Val{Symbol(cmd)}, args[cmd])
    end
    return 0
end
