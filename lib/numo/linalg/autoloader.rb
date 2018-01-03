require 'fiddle'
require 'rbconfig'
require 'numo/linalg/linalg'

module Numo
  module Linalg
    # Numo::Linalg::Autoloader is a module that has a method loading backend libraries automatically
    # according to an execution environment.
    #
    # @example
    #   requre 'numo/linalg/autoloader'
    module Autoloader
      # @!visibility private
      @@libs = nil

      module_function

      # Return the list of loaded backend libraries.
      #
      # @return [Array<String>] list of loaded backend libraries
      def libs
        @@libs
      end

      # Load backend libraries for Numo::Linalg automatically.
      #
      # @return [String] name of loaded backend library (mkl/openblas/lapack)
      def load_library
        mkl_dirs = ['/opt/intel/lib', '/opt/intel/mkl/lib']
        openblas_dirs = ['/opt/openblas/lib', '/usr/local/opt/openblas/lib']
        atlas_dirs = ['/opt/atlas/lib', '/opt/atlas/lib64',
                      '/usr/lib/atlas', '/usr/lib64/atlas', '/usr/local/opt/atlas/lib']
        lapacke_dirs = ['/opt/lapack/lib', '/usr/local/opt/lapack/lib']
        opt_dirs =  ['/opt/local/lib', '/opt/local/lib64', '/opt/lib', '/opt/lib64']
        base_dirs = ['/usr/local/lib', '/usr/local/lib64', '/usr/lib', '/usr/lib64']
        base_dirs.unshift(*ENV['LD_LIBRARY_PATH'].split(':')) unless ENV['LD_LIBRARY_PATH'].nil?

        mkl_libs = find_mkl_libs([*base_dirs, *opt_dirs, *mkl_dirs])
        openblas_libs = find_openblas_libs([*base_dirs, *opt_dirs, *openblas_dirs])
        atlas_libs = find_atlas_libs([*base_dirs, *opt_dirs, *atlas_dirs])
        lapack_libs = find_lapack_libs([*base_dirs, *opt_dirs, *lapacke_dirs])

        @@libs = nil
        if !mkl_libs.value?(nil)
          open_mkl_libs(mkl_libs)
          @@libs = mkl_libs.values
          'mkl'
        elsif !openblas_libs.value?(nil)
          open_openblas_libs(openblas_libs)
          @@libs = openblas_libs.values
          'openblas'
        elsif !atlas_libs.value?(nil)
          open_atlas_libs(atlas_libs)
          @@libs = atlas_libs.values
          'atlas'
        elsif !lapack_libs.value?(nil)
          open_lapack_libs(lapack_libs)
          @@libs = lapack_libs.values
          'lapack'
        else
          raise 'cannot find MKL/OpenBLAS/ATLAS/BLAS-LAPACK library'
        end
      end

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

      def find_atlas_libs(lib_dirs)
        lib_names = %w[tatlas atlas satlas cblas lapacke]
        atlas_libs = find_libs(lib_names, lib_dirs)
        atlas_libs[:atlas] = atlas_libs[:tatlas] unless atlas_libs[:tatlas].nil?
        atlas_libs[:atlas] = atlas_libs[:satlas] if atlas_libs[:atlas].nil?
        atlas_libs[:cblas] = atlas_libs[:atlas] if atlas_libs[:cblas].nil?
        atlas_libs.delete(:tatlas)
        atlas_libs.delete(:satlas)
        atlas_libs
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

      def open_atlas_libs(atlas_libs)
        Fiddle.dlopen(atlas_libs[:atlas])
        Numo::Linalg::Blas.dlopen(atlas_libs[:cblas])
        Numo::Linalg::Lapack.dlopen(atlas_libs[:lapacke])
      end

      def open_lapack_libs(lapack_libs)
        Fiddle.dlopen(lapack_libs[:blas])
        Fiddle.dlopen(lapack_libs[:lapack])
        Numo::Linalg::Blas.dlopen(lapack_libs[:blas])
        Numo::Linalg::Lapack.dlopen(lapack_libs[:lapacke])
      end

      private_class_method :detect_library_extension,
                           :find_libs, :find_mkl_libs, :find_openblas_libs, :find_atlas_libs, :find_lapack_libs,
                           :open_mkl_libs, :open_openblas_libs, :open_atlas_libs, :open_lapack_libs
    end
  end
end

Numo::Linalg::Autoloader.load_library
