require 'cucumber/rspec/doubles'
require 'rspec'
require 'conjur/api'
require 'conjur/config'

Conjur::Config.merge JSON.parse(File.read('conjur.json'))
Conjur::Config.apply
