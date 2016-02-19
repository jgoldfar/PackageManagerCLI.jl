__precompile__()

module PackageManagerCLI
import PkgDev

export exec_cmd

const pkgdir = Pkg.dir()
const pkglist = Pkg.installed()
const pkgavail = Pkg.available()

function exec_cmd(::Type{Val{:develop}}, args)
  warn("Sorry, develop command not yet implemented.")
  exit(-1)
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
  if haskey(pkglist, thispkg)
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

function exec_cmd(::Type{Val{:build}}, args)
  thispkg = args["pkg"]
  @assert haskey(pkglist, thispkg)
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
  @assert haskey(pkglist, thispkg)
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
  @assert isdir(frompath) && !isdir(installpath)
  println("Linking ", args["destpkg"], " from ", frompath)
  symlink(frompath, installpath)
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
  if !haskey(pkglist, thispkg)
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
  @assert haskey(pkglist, thispkg)
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
  @assert haskey(pkglist, thispkg)
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
end
function exec_cmd(::Type{Val{:pin}}, args)
  thispkg = args["pkg"]
  thisver = args["ver"]
  @assert haskey(pkglist, thispkg)
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
  @assert haskey(pkglist, thispkg)
  try
    Pkg.free(thispkg)
    return 0
  catch
    return -1
  end
end

end # module
