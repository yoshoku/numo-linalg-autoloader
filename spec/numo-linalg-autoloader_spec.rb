require 'spec_helper'

RSpec.describe Numo::Linalg::Autoloader do
  it 'succeses loading backend libraries' do
    expect { described_class.load_library }.to_not raise_error
    expect(described_class.libs).to_not be_nil
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
