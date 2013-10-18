require 'cucumber/rspec/doubles'
require 'rspec'

$config = YAML.load(File.read('config.yml'))

ENV['CONJUR_ENV'] = $config[:env]
ENV['CONJUR_STACK'] = $config[:stack]
ENV['CONJUR_ACCOUNT'] = $config[:account]
