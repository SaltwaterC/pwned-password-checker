require 'rubeepass'
require 'io/console'

require_relative 'helpers'

module PwnedPassword
  module Checker
    # implements KDBX checker
    class Kdbx < RubeePass
      include Helpers

      def self.prompt(options)
        print 'KDBX path> '
        path = gets.strip

        pwd = prompt_password(options)

        print 'KDBX key file> '
        key = nil
        k = gets.strip
        key = k unless k.empty?

        new(path, pwd, key, options)
      rescue Interrupt
        exit
      end

      def self.prompt_password(options)
        print 'KDBX password> '

        if options[:echo]
          pwd = gets.strip
        else
          pwd = STDIN.noecho(&:gets).strip
          puts
        end

        pwd
      end

      def initialize(path, pwd, key, options)
        @options = options
        super(path, pwd, key)
        open
      end

      def headings
        %w[Group Title Username Password Count]
      end

      def pwned_passwords(group = @db)
        pwned = []

        group.groups.each do |_n, subgroup|
          pwned.concat(pwned_passwords(subgroup))
        end

        group.entries.each do |_n, entry|
          count = hash_count(@options[:pwn], entry.password)
          next unless count

          update_pwned(pwned, group, entry, count)
        end

        pwned
      end

      def update_pwned(pwned, group, entry, count)
        pwned << {
          group: group.name,
          title: entry.title,
          username: entry.username,
          password: entry.password,
          count: count
        }
      end
    end
  end
end
