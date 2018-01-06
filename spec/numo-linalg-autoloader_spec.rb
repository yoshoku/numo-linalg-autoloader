require 'spec_helper'

RSpec.describe Numo::Linalg::Autoloader do
  it 'succeses loading backend libraries' do
    expect { described_class.load_library }.to_not raise_error
    expect(described_class.libs).to_not be_nil
  end

  describe 'methods finding backend libraries' do
    let(:autoloader) do
      class DummyLoader
        include Numo::Linalg::Autoloader
      end
      DummyLoader.new
    end

    it 'finds OpenBLAS libraries' do
      openblas_libs = autoloader.send(:find_openblas_libs, ['/usr/local/opt/openblas/lib'])
      expect(openblas_libs[:openblas]).to_not be_nil
      expect(openblas_libs[:lapacke]).to_not be_nil
    end

    it 'finds ATLAS libraries' do
      atlas_libs = autoloader.send(:find_atlas_libs, ['/opt/local/lib'])
      expect(atlas_libs[:atlas]).to_not be_nil
      expect(atlas_libs[:cblas]).to_not be_nil
      expect(atlas_libs[:lapacke]).to_not be_nil
    end

    it 'finds BLAS/LAPACK libraries' do
      lapack_libs = autoloader.send(:find_lapack_libs, ['/usr/lib', '/usr/local/opt/lapack/lib'])
      expect(lapack_libs[:blas]).to_not be_nil
      expect(lapack_libs[:cblas]).to_not be_nil
      expect(lapack_libs[:lapack]).to_not be_nil
      expect(lapack_libs[:lapacke]).to_not be_nil
    end
  end

  describe 'BLAS/LAPACK methods' do
    let(:mat) { Numo::DFloat.new(5,3).rand }
    before { described_class.load_library }

    it 'can perform matrix multiplication' do
      expect { mat.dot(mat.transpose) }.to_not raise_error
    end

    it 'can perform singular value decomposition' do
      expect { Numo::Linalg::svd(mat) }.to_not raise_error
    end
  end
end
