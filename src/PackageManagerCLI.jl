module PackageManagerCLI
import PkgDev
@static if VERSION >= v"0.7-"
    using Pkg
    # Assume PackageManagerCLI is installed in a Depot location
    const pkgdir = dirname(dirname(dirname(Base.pathof(PackageManagerCLI))))
else
    const pkgdir = Pkg.dir()
end
export exec_cmd



function exec_cmd(::Type{Val{:list}}, args)
    pkginstalled = Pkg.installed()
    if args["plain"]
        for (name, v) in pkginstalled
            println(name)
        end
    else
        for (name, v) in pkginstalled
            println(name, " => ", v)
        end
    end
    return 0
end
function exec_cmd(::Type{Val{:status}}, args)
    Pkg.status()
    return 0
end

function exec_cmd(::Type{Val{:develop}}, args)
  thispkg = args["pkg"]
  destpath = args["path"]
  tmppath = tempdir()
  frompath = joinpath(tmppath, thispkg)
  rm(frompath, force=true, recursive=true)
  PkgDev.generate(thispkg, args["license"], path = tmppath)
  mkpath(destpath)
  for genfile in readdir(frompath)
    mv(joinpath(frompath, genfile), joinpath(destpath, genfile), remove_destination=args["force"])
  end
  return 0
end

function exec_cmd(::Type{Val{:add}}, args)
  thispkg = args["pkg"]
  thisver = args["ver"]
  print("Adding ", thispkg)
  if thisver == nothing
    print("\n")
  else
    print(" version", thisver)
  end
  if haskey(Pkg.installed(), thispkg)
    try
      if thisver == nothing
        Pkg.add(thispkg)
      else
        Pkg.add(thispkg, thisver)
      end
      return 0
    catch
      return -1
    end
  else
    try
      Pkg.clone(thispkg)
      return 0
    catch
      return -1
    end
  end
end

function exec_cmd(::Type{Val{:update}}, args)
  try
    Pkg.update()
    return 0
  catch
    return -1
  end
  # "update"
  #   help = "Update package metadata and resolve all packages"
  #   action = :command

end


function exec_cmd(::Type{Val{:build}}, args)
  thispkg = args["pkg"]
  @assert haskey(Pkg.installed(), thispkg)
  try
    Pkg.build(thispkg)
    return 0
  catch
    return -1
  end
end

function exec_cmd(::Type{Val{:checkout}}, args)
  thispkg = args["pkg"]
  thisbranch = args["branch"]
  @assert haskey(Pkg.installed(), thispkg)
  try
    if thisbranch != nothing
      Pkg.checkout(thispkg, thisbranch)
    else
      Pkg.checkout(thispkg)
    end
    return 0
  catch
    return -1
  end
end
function exec_cmd(::Type{Val{:link}}, args)
  frompath = args["srcpath"]
  installpath = joinpath(pkgdir, args["destpkg"])
  if !isdir(frompath)
    println("Source path ", frompath, " does not exist.")
    return -1
  end
  if isdir(installpath)
    println("Destination path ", installpath, " exists.")
    return -1
  end
  println("Linking ", args["destpkg"], " from ", frompath)
  symlink(frompath, installpath)
  return 0
end
function exec_cmd(::Type{Val{:links}}, args)
  for subdir in readdir(pkgdir)
    thisdir = joinpath(pkgdir, subdir)
    if subdir == ".cache"
      continue
    end
    if islink(thisdir)
      println(subdir, "=>", readlink(thisdir))
    end
  end
  return 0
end
function exec_cmd(::Type{Val{:delete}}, args)
  thispkg = args["pkg"]
  if !haskey(Pkg.installed(), thispkg)
    println("Package ", thispkg, " is not installed.")
    return 0
  end
  try
    Pkg.rm(thispkg)
    return 0
  catch
    return -1
  end
end
function exec_cmd(::Type{Val{:search}}, args)
  warn("Sorry, search command not implemented.")
  return -1
  # "txt"
  #   help = "Text to search for."
  #   required = true
end
function exec_cmd(::Type{Val{:test}}, args)
  thispkg = args["pkg"]
  @assert haskey(Pkg.installed(), thispkg)
  try
    Pkg.test(thispkg)
    return 0
  catch
    return -1
  end
end
function exec_cmd(::Type{Val{:tag}}, args)
  thispkg = args["pkg"]
  thisver = args["ver"]
  @assert haskey(Pkg.installed(), thispkg)
  @assert in(thisver, (:patch, :minor, :major))
  println("Tagging ", thisver, " version of ", thispkg)
  try
    PkgDev.tag(thispkg, thisver)
    return 0
  catch
    return -1
  end
end
function exec_cmd(::Type{Val{:unlink}}, args)
  installpath = joinpath(pkgdir, args["pkg"])
  @assert islink(installpath)
  println("Unlinking ", args["pkg"])
  rm(installpath)
  return 0
end
function exec_cmd(::Type{Val{:pin}}, args)
  thispkg = args["pkg"]
  thisver = args["ver"]
  @assert haskey(Pkg.installed(), thispkg)
  try
    if thisver == nothing
      Pkg.pin(thispkg)
    else
      @assert in(thisver, Pkg.available(thispkg))
      Pkg.pin(thispkg, thisver)
    end
    return 0
  catch
    return -1
  end
end
function exec_cmd(::Type{Val{:free}}, args)
  thispkg = args["pkg"]
  @assert haskey(Pkg.installed(), thispkg)
  try
    Pkg.free(thispkg)
    return 0
  catch
    return -1
  end
end

include("jpm_helpers.jl")
end # module
