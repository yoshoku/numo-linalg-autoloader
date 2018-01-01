require 'fiddle'
require 'rbconfig'
require 'numo/linalg/linalg'

module Numo
  module Linalg
    # Numo::Linalg::Autoloader is a class that loads backend libraries automatically
    # according to an execution environment.
    #
    # @example
    #   requre 'numo/linalg/autoloader'
    class Autoloader
      class << self
        # Load backend libraries for Numo::Linalg automatically.
        #
        # @return [String] name of loaded backend library (mkl/openblas/lapack)
        def load_library
          mkl_dirs = ['/opt/intel/lib', '/opt/intel/mkl/lib']
          openblas_dirs = ['/opt/openblas/lib', '/usr/local/opt/openblas/lib']
          lapacke_dirs = ['/opt/lapack/lib', '/usr/local/opt/lapack/lib']
          opt_dirs =  ['/opt/local/lib', '/opt/local/lib64', '/opt/lib', '/opt/lib64']
          base_dirs = ['/usr/local/lib', '/usr/local/lib64', '/usr/lib', '/usr/lib64']
          base_dirs.unshift(*ENV['LD_LIBRARY_PATH'].split(':')) unless ENV['LD_LIBRARY_PATH'].nil?

          mkl_libs = find_mkl_libs([*base_dirs, *opt_dirs, *mkl_dirs])
          openblas_libs = find_openblas_libs([*base_dirs, *opt_dirs, *openblas_dirs])
          lapack_libs = find_lapack_libs([*base_dirs, *opt_dirs, *lapacke_dirs])

          if !mkl_libs.value?(nil)
            open_mkl_libs(mkl_libs)
            'mkl'
          elsif !openblas_libs.value?(nil)
            open_openblas_libs(openblas_libs)
            'openblas'
          elsif !lapack_libs.value?(nil)
            open_lapack_libs(lapack_libs)
            'lapack'
          else
            raise 'cannot find MKL/OpenBLAS/ATLAS/BLAS-LAPACK library'
          end
        end

        private

        def detect_library_extension
          case RbConfig::CONFIG['host_os']
          when /mswin|msys|mingw|cygwin/
            'dll'
          when /darwin|mac os/
            'dylib'
          else
            'so'
          end
        end

        def find_libs(lib_names, lib_dirs)
          lib_ext = detect_library_extension
          lib_arr = lib_names.map do |l|
            [l.to_sym, lib_dirs.map { |d| "#{d}/lib#{l}.#{lib_ext}" }
                               .keep_if { |f| File.exist?(f) }.first]
          end
          Hash[*lib_arr.flatten]
        end

        def find_mkl_libs(lib_dirs)
          lib_names = %w[iomp5 mkl_core mkl_intel_thread mkl_intel_lp64]
          find_libs(lib_names, lib_dirs)
        end

        def find_openblas_libs(lib_dirs)
          lib_names = %w[openblas]
          find_libs(lib_names, lib_dirs)
        end

        def find_lapack_libs(lib_dirs)
          lib_names = %w[blas lapack lapacke]
          find_libs(lib_names, lib_dirs)
        end

        def open_mkl_libs(mkl_libs)
          Fiddle.dlopen(mkl_libs[:iomp5])
          Fiddle.dlopen(mkl_libs[:mkl_core])
          Fiddle.dlopen(mkl_libs[:mkl_intel_thread])
          Fiddle.dlopen(mkl_libs[:mkl_intel_lp64])
          Numo::Linalg::Blas.dlopen(mkl_libs[:mkl_intel_lp64])
          Numo::Linalg::Lapack.dlopen(mkl_libs[:mkl_intel_lp64])
        end

        def open_openblas_libs(openblas_libs)
          Numo::Linalg::Blas.dlopen(openblas_libs[:openblas])
          Numo::Linalg::Lapack.dlopen(openblas_libs[:openblas])
        end

        def open_lapack_libs(lapack_libs)
          Fiddle.dlopen(lapack_libs[:blas])
          Fiddle.dlopen(lapack_libs[:lapack])
          Numo::Linalg::Blas.dlopen(lapack_libs[:blas])
          Numo::Linalg::Lapack.dlopen(lapack_libs[:lapacke])
        end
      end
    end
  end
end

Numo::Linalg::Autoloader.load_library
