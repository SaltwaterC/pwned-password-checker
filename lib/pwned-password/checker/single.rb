require 'benchmark'
require 'io/console'

require_relative 'helpers'

module PwnedPassword
  module Checker
    # search single passwords in the pwned list
    class Single
      include Helpers

      def initialize(options)
        @options = options
      end

      def prompt
        print 'password> '
        if @options[:echo]
          pwd = gets.strip
        else
          pwd = STDIN.noecho(&:gets).strip
          puts
        end

        query(pwd)
      end

      private

      def query(pwd)
        hash = sha1(pwd)
        puts "Hash: #{hash}"

        count = nil
        bm = Benchmark.measure do
          count = hash_count(@options[:pwn], pwd)
        end

        results(bm, count)
      end

      def results(benchm, count)
        if count
          puts "This password has been seen #{count} times before"
        else
          puts 'Good news — no pwnage found!'
        end

        puts "Seek time: #{format('%.2f', benchm.real * 1000.0)} ms"
      end
    end
  end
end
