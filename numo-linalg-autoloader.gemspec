
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'numo-linalg-autoloader'
  spec.version       = '0.1.5'
  spec.authors       = ['yoshoku']
  spec.email         = ['yoshoku@outlook.com']
  spec.summary       = <<MSG
Numo::Linalg::Autoloader is a module that has a method
loading backend libraries automatically
according to an execution environment.
MSG
  spec.description   = <<MSG
Numo::Linalg::Autoloader is a module that has a method
loading backend libraries automatically
according to an execution environment.
The library is confirmed to work with
Intel MKL and OpenBLAS (installed from source)
on macOS, Ubuntu, and CentOS.
Note that the library is merged in Numo::Linalg now.
The Numo::Linalg version on which the library works is only 0.1.0.
MSG
  spec.homepage      = 'https://github.com/yoshoku/numo-linalg-autoloader'
  spec.license       = 'BSD-3-Clause'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_runtime_dependency 'numo-linalg', '= 0.1.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
