const frompath = joinpath(dirname(dirname(@__FILE__)), "src", "jpm")
const installpath = joinpath("/usr", "local", "bin", "jpm")

if isempty(ARGS)
  println("Usage: julia build.jl [install|clean]")
elseif "clean" in ARGS
  if islink(installpath) && (readlink(installpath) == frompath)
      println("Removing jpm from ", installpath)
      rm(installpath)
  else
      println("jpm is not installed.")
  end
elseif "install" in ARGS
  @static if Sys.isunix()
    println("Installing jpm to ", installpath)
    try
      symlink(frompath, installpath)
    catch v
      println("Linking jpm at ", installpath, " failed.")
    end
  else
    println("jpm is available on your system at ", frompath, ".")
  end
end
