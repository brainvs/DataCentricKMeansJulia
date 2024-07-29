module DataCentricKMeans

export KMeansResult, run_lloyd_kmeans, run_geokmeans, run_elkan_kmeans, run_hamerly_kmeans, run_annulus_kmeans, run_exponion_kmeans

mutable struct KMeansResult
    loop_counter::Int
    num_dists::Int
    assignments::Vector{Int}
    centroids::Vector{Vector{Float64}}
    sse::Float64
end

# Define the run functions for each algorithm
function run_lloyd_kmeans(num_iterations::Int, threshold::Float64, num_clusters::Int; seed::Union{Int, Nothing}=nothing, file_paths::Vector{String}=String[])
    if seed === nothing
        seed = 42  # Default seed value
    end
    run_cpp_program("lloyd_kmeans", num_iterations, threshold, num_clusters, seed, file_paths)
end

function run_geokmeans(num_iterations::Int, threshold::Float64, num_clusters::Int; seed::Union{Int, Nothing}=nothing, file_paths::Vector{String}=String[])
    if seed === nothing
        seed = 42  # Default seed value
    end
    run_cpp_program("geokmeans", num_iterations, threshold, num_clusters, seed, file_paths)
end

function run_elkan_kmeans(num_iterations::Int, threshold::Float64, num_clusters::Int; seed::Union{Int, Nothing}=nothing, file_paths::Vector{String}=String[])
    if seed === nothing
        seed = 42  # Default seed value
    end
    run_cpp_program("elkan", num_iterations, threshold, num_clusters, seed, file_paths)
end

function run_hamerly_kmeans(num_iterations::Int, threshold::Float64, num_clusters::Int; seed::Union{Int, Nothing}=nothing, file_paths::Vector{String}=String[])
    if seed === nothing
        seed = 42  # Default seed value
    end
    run_cpp_program("hamerly", num_iterations, threshold, num_clusters, seed, file_paths)
end

function run_annulus_kmeans(num_iterations::Int, threshold::Float64, num_clusters::Int; seed::Union{Int, Nothing}=nothing, file_paths::Vector{String}=String[])
    if seed === nothing
        seed = 42  # Default seed value
    end
    run_cpp_program("annulus", num_iterations, threshold, num_clusters, seed, file_paths)
end

function run_exponion_kmeans(num_iterations::Int, threshold::Float64, num_clusters::Int; seed::Union{Int, Nothing}=nothing, file_paths::Vector{String}=String[])
    if seed === nothing
        seed = 42  # Default seed value
    end
    run_cpp_program("exponion", num_iterations, threshold, num_clusters, seed, file_paths)
end

function run_cpp_program(algorithm::String, num_iterations::Int, threshold::Float64, num_clusters::Int, seed::Int, file_paths::Vector{String}=String[])
    if !(num_iterations isa Integer) || num_iterations < 1
        throw(ArgumentError("Number of iterations must be >= 1."))
    end
    
    if !(threshold isa Float64) || threshold < 0
        throw(ArgumentError("Threshold must be >= 0."))
    end
    
    if !(num_clusters isa Integer) || num_clusters < 2
        throw(ArgumentError("Number of clusters must be >= 2."))
    end
    
    if !(seed isa Integer) || seed <= 0
        throw(ArgumentError("Seed must be a positive integer."))
    end
    
    if !(file_paths isa Array{String,1}) || any(path -> !isfile(path), file_paths)
        throw(ArgumentError("File paths must be a list of strings and files must exist."))
    end

    executable = ""
    if Sys.isapple()
        executable = "DataCentricKMeans_universal.out"
    elseif Sys.islinux()
        executable = "DataCentricKMeans_linux.out"
    elseif Sys.iswindows()
        executable = "DataCentricKMeans_windows.exe"
    else
        throw(ErrorException("Unsupported operating system"))
    end

    executable_path = joinpath(@__DIR__, executable)
    file_paths_str = join(file_paths, ",")
    command = `$executable_path $algorithm $num_iterations $threshold $num_clusters $seed $file_paths_str`
    
    try
        output = read(command, String)  # Capture the command output and don't print it to the console
        outputs = []
        for path in file_paths
            base_path, ext = splitext(path)
            output_path = joinpath(dirname(abspath(path)), "$(basename(base_path))-solution-$algorithm.txt")
            push!(outputs, read_output_file(output_path))
        end
        return outputs
    catch e
        throw(ErrorException("Error occurred while running the program: $(e)"))
    end
end

function read_output_file(filepath::String)
    lines = readlines(filepath)
    
    result_data = KMeansResult(
        0, # Initial value for loop_counter
        0, # Initial value for num_dists
        Int[], # Initial value for assignments
        Vector{Vector{Float64}}[], # Initial value for centroids
        0.0 # Initial value for SSE
    )
    
    centroid_section = false
    
    for line in lines
        if startswith(line, "Loop Counter:")
            result_data.loop_counter = parse(Int, split(line, ":")[2])
        elseif startswith(line, "Number of Distances:")
            result_data.num_dists = parse(Int, split(line, ":")[2])
        elseif startswith(line, "Assignments:")
            assignments_index = findfirst(x -> startswith(x, "Assignments:"), lines) + 1
            while assignments_index <= length(lines) && !startswith(lines[assignments_index], "Centroids:") && !isempty(strip(lines[assignments_index]))
                assignments = split(lines[assignments_index])
                result_data.assignments = vcat(result_data.assignments, parse.(Int, assignments))
                assignments_index += 1
            end
        elseif startswith(line, "Centroids:")
            centroid_section = true
        elseif startswith(line, "SSE:")
            result_data.sse = parse(Float64, split(line, ":")[2])
        elseif centroid_section && !isempty(strip(line)) && !startswith(line, "SSE:")
            centroid_values = parse.(Float64, split(line))
            push!(result_data.centroids, centroid_values)
        end
    end
    
    return result_data
end

end # module
