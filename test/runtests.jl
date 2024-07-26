using DataCentricKMeans
using Test

@testset "DataCentricKMeans Tests" begin
    result = run_lloyd_kmeans(10, 0.01, 3; file_paths=["birch.csv"])
    @test !isempty(result)
end

