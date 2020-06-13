# frozen_string_literal: true

require 'rubygems'
require 'date'
require 'json'
require 'forwardable'
require 'stringio'

module ADT
  class Error < StandardError; end
  # Your code goes here...
end

require 'adt/version'
require 'adt/table'
require 'adt/header'
require 'adt/column_type'
require 'adt/column'
require 'adt/record'
