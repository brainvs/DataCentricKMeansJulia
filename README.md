```julia

using Pkg

# Paketi yükleyin
Pkg.add(PackageSpec(url="https://github.com/brainvs/DataCentricKMeansJulia.git"))

# Paketi kullanın
using DataCentricKMeans

# Paketin yerini bulmak için Julia'nın package metadatasını kullanın
package_path = Base.pathof(DataCentricKMeans)
package_dir = dirname(dirname(package_path))

# Doğru dosya yolunu belirleyin
file_path = joinpath(package_dir, "test", "birch.csv")

println("File path: ", file_path)

# Test example
result = run_lloyd_kmeans(10, 0.01, 3; file_paths=[file_path])
println(result)


```
