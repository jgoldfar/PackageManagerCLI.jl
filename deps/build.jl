const frompath = joinpath(dirname(dirname(@__FILE__)), "src", "jpm")
const installpath = joinpath("/usr", "local", "bin", "jpm")

if isempty(ARGS) # Install
  @unix? begin
    println("Installing jpm to ", installpath)
    try
      symlink(frompath, installpath)
    catch v
      println("Linking jpm at ", installpath, " failed.")
    end
  end : begin
    println("jpm is available on your system at ", frompath, ".")
  end
elseif in("--clean", ARGS) && islink(installpath) && readlink(installpath) == frompath
  println("Removing jpm from ", installpath)
  rm(installpath)
else
  println("Usage: julia build.jl [--clean]")
end