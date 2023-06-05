require 'digest'

module PwnedPassword
  module Checker
    # helper methods to wrap the hash search
    module Helpers
      def sha1(password)
        Digest::SHA1.hexdigest(password).upcase
      end

      def hash_count(pwn, pwd)
        validate_dir(pwn)
        hash = sha1(pwd)
        range = hash[(0..4)]
        suffix = hash[(5..-1)]
        validate_file(pwn, range)
        find_hash(pwn, range, suffix)
      end

      def raise_error(msg)
        STDERR.puts("Error: #{msg}")
        exit(2)
      end

      def validate_dir(pwn)
        return if Dir.exists?(pwn)

        raise_error "unable to find pwned password directory at #{pwn}"
      end

      def validate_file(pwn, range)
        file = "#{pwn}/#{range}.txt"
        return if File.exists?(file)

        raise_error "unable to find pwned password range file at #{file}"
      end

      def find_hash(pwn, range, suffix)
        File.read("#{pwn}/#{range}.txt").each_line do |line|
          next unless line.start_with?(suffix)

          return line.strip.split(':')[1].to_i
        end

        nil
      end
    end
  end
end
