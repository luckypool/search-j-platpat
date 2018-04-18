#!/usr/bin/env ruby
# encoding: utf-8

require "csv"
require 'fileutils'
require "optparse"

require "./lib/trademark_searcher"

require "ap"
require "pry-byebug"

options = ARGV.getopts('k:')
key     = options["k"]
fail "ERROR: blank key!" if key.nil? || key.strip == ""

trademarks = TrademarkSearcher.search_by(key) || []

rows = trademarks.map do |tm|
  hash = tm.to_hash
  CSV::Row.new(hash.keys, hash.values)
end

table = CSV::Table.new(rows)

FileUtils::mkdir_p 'results'

File.open("results/#{key}.csv", "w") do |f|
  f.write(table.to_csv)
end

