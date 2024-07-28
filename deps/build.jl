import Pkg

println("Running build.jl")

if !haskey(Pkg.installed(), "Pkg")
    Pkg.add("Pkg")
end

executables = [
    joinpath(@__DIR__, "..", "src", "DataCentricKMeans_linux.out"),
    joinpath(@__DIR__, "..", "src", "DataCentricKMeans_universal.out"),
    joinpath(@__DIR__, "..", "src", "DataCentricKMeans_windows.exe")
]

for exe in executables
    if isfile(exe)
        println("Setting executable permissions for $exe")
        run(`chmod +x $exe`)
    else
        println("Executable $exe not found")
    end
end

println("Finished build.jl")

