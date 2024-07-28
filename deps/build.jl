using Pkg

executables = [
    joinpath(@__DIR__, "src", "DataCentricKMeans_linux.out"),
    joinpath(@__DIR__, "src", "DataCentricKMeans_universal.out"),
    joinpath(@__DIR__, "src", "DataCentricKMeans_windows.exe")
]

for exe in executables
    if isfile(exe)
        println("Setting executable permissions for $exe")
        run(`chmod +x $exe`)
    end
end

