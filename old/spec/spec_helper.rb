require "rubygems"
require "bundler/setup"
require 'rspec'

spec_directory = File.dirname(__FILE__)
paths =
  [
    "#{spec_directory}/../lib/satone/*.rb",
    "#{spec_directory}/../lib/satone/command/*.rb",
    "#{spec_directory}/../lib/satone/helper/*.rb"
  ]

Dir[*paths].each { |f| load f }
