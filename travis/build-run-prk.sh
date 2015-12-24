set -e
set -x

PRK_TARGET="$1"

case "$PRK_TARGET" in
    allserial)
        echo "Serial"
        make $PRK_TARGET
        # widely supported
        ./SERIAL/Synch_p2p/p2p 10 1024 1024
        ./SERIAL/Stencil/stencil 10 1024 32
        ./SERIAL/Transpose/transpose 10 1024 32
        # less support
        ./SERIAL/Reduce/reduce 10 1024
        ./SERIAL/Random/random 64 10 16384
        ./SERIAL/Nstream/nstream 10 16777216 32
        ./SERIAL/Sparse/sparse 10 10 5
        ./SERIAL/DGEMM/dgemm 10 1024 32
        ;;

    allopenmp)
        echo "OpenMP"
        make $PRK_TARGET
        export OMP_NUM_THREADS=4
        # widely supported
        ./OPENMP/Synch_p2p/p2p $OMP_NUM_THREADS 10 1024 1024
        ./OPENMP/Stencil/stencil $OMP_NUM_THREADS 10 1024
        ./OPENMP/Transpose/transpose $OMP_NUM_THREADS 10 1024 32
        # less support
        ./OPENMP/Reduce/reduce $OMP_NUM_THREADS 10 16777216
        ./OPENMP/Nstream/nstream $OMP_NUM_THREADS 10 16777216 32
        ./OPENMP/Sparse/sparse $OMP_NUM_THREADS 10 10 5
        ./OPENMP/DGEMM/dgemm $OMP_NUM_THREADS 10 1024 32
        # random is broken right now it seems
        #./OPENMP/Random/random $OMP_NUM_THREADS 10 16384 32
        # no serial equivalent
        ./OPENMP/Synch_global/global $OMP_NUM_THREADS 10 16384
        ./OPENMP/RefCount_private/private $OMP_NUM_THREADS 16777216
        ./OPENMP/RefCount_shared/shared $OMP_NUM_THREADS 16777216 1024
        ;;
    allmpi1)
        echo "MPI-1"
        make $PRK_TARGET
        export PRK_MPI_PROCS
        # widely supported
        mpirun -n $PRK_MPI_PROCS ./MPI1/Synch_p2p/p2p 10 1024 1024
        mpirun -n $PRK_MPI_PROCS ./MPI1/Stencil/stencil 10 1024
        mpirun -n $PRK_MPI_PROCS ./MPI1/Transpose/transpose 10 1024 32
        # less support
        mpirun -n $PRK_MPI_PROCS ./MPI1/Reduce/reduce 10 16777216
        mpirun -n $PRK_MPI_PROCS ./MPI1/Nstream/nstream 10 16777216 32
        mpirun -n $PRK_MPI_PROCS ./MPI1/Sparse/sparse 10 10 5
        mpirun -n $PRK_MPI_PROCS ./MPI1/DGEMM/dgemm 10 1024 32
        mpirun -n $PRK_MPI_PROCS ./MPI1/Random/random 32 20
        # no serial equivalent
        mpirun -n $PRK_MPI_PROCS ./MPI1/Synch_global/global 10 16384
        ;;
esac
