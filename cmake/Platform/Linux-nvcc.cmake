IF(CMAKE_COMPILER_IS_NVCC)
  SET (CMAKE_CUDA_FLAGS_INIT "")
  SET (CMAKE_CUDA_FLAGS_DEBUG_INIT "-g")
  SET (CMAKE_CUDA_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
  SET (CMAKE_CUDA_FLAGS_RELEASE_INIT "-O3 -DNDEBUG")
  SET (CMAKE_CUDA_FLAGS_RELWITHDEBINFO_INIT "-O2 -g")
  SET (CMAKE_CUDA_CREATE_PREPROCESSED_SOURCE "<CMAKE_CUDA_COMPILER> <DEFINES> <FLAGS> -E <SOURCE> > <PREPROCESSED_SOURCE>")
  SET (CMAKE_CUDA_CREATE_ASSEMBLY_SOURCE "<CMAKE_CUDA_COMPILER> <DEFINES> <FLAGS> -S <SOURCE> -o <ASSEMBLY_SOURCE>")
ENDIF(CMAKE_COMPILER_IS_NVCC)
