require 'yaml'
require 'digest'

module PwnedPassword
  module Checker
    # helper methods to wrap the hash search
    module Helpers
      def sha1(password)
        Digest::SHA1.hexdigest(password).upcase
      end

      def read_bucket(idx, pwn, hash)
        validate(idx, pwn)
        dir = hash[(0..1)]
        bucket = hash[(0..3)]

        offsets = YAML.load_file("#{idx}/#{dir}/#{bucket}")

        File.open(pwn) do |fd|
          fd.pos = offsets['s']
          fd.read(offsets['e'] - offsets['s'])
        end
      rescue Errno::ENOENT
        nil
      end

      def find_hash(bucket, hash)
        return bucket if bucket.nil?

        bucket.each_line do |line|
          next unless line.start_with?(hash)

          return line.strip.split(':')[1].to_i
        end

        nil
      end

      def hash_count(idx, pwn, pwd)
        hash = sha1(pwd)
        bucket = read_bucket(idx, pwn, hash)
        find_hash(bucket, hash)
      end

      def validate(idx, pwn)
        raise "Error: unable to find index at #{idx}" unless Dir.exist?(idx)
        return if File.exist?(pwn)

        raise "Error: unable to find pwned passwords file at #{pwn}"
      end
    end
  end
end
