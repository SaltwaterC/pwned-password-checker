require 'json'
require 'open3'
require 'shellwords'
require 'io/console'

require_relative 'helpers'

module PwnedPassword
  module Checker
    # implements op 1Password CLI wrapper
    class Onepassword
      include Helpers

      def self.prompt(options)
        print '1Password master password> '
        if options[:echo]
          password = gets.strip
        else
          password = STDIN.noecho(&:gets).strip
          puts
        end

        new(password, options)
      rescue Interrupt
        exit
      end

      def initialize(password, options)
        @options = options
        @session = run('signin --output=raw', password, true)

        @vaults = run('list vaults')
        @templates = run('list templates')
      end

      def run(cmd, stdin = nil, raw = false)
        cmd = prepare_cmd(cmd)

        args = {}
        args[:stdin_data] = stdin unless stdin.nil?

        stdout, stderr, status = Open3.capture3(cmd, args)
        raise stderr if status.exitstatus != 0

        stdout = stdout.strip
        return JSON.parse(stdout) unless raw

        stdout
      end

      def prepare_cmd(cmd)
        cmd = ['op'] + cmd.split(' ')
        cmd += ["--session=#{@session}"] if @session
        Shellwords.join(cmd)
      end

      def headings
        %w[Vault Type Title Field Password Count]
      end

      def pwned_passwords
        pwned = []

        run('list items').each do |item| # extremely slow...
          next unless passwords?(item)

          it = run("get item #{item['uuid']} --vault=#{item['vaultUuid']}")
          process_item(it, pwned)
        end

        pwned
      end

      # not all item types have password fields
      def passwords?(item)
        # login, password, email account, server, database, wireless router
        %w[001 005 111 110 102 109].include?(item['templateUuid'])
      end

      def process_item(item, pwned)
        extract_passwords(item).each do |name, password|
          count = hash_count(@options[:pwn], password)
          next unless count

          collect_pwned_passwords(item, pwned, name, password, count)
        end
      end

      def collect_pwned_passwords(item, pwned, name, password, count)
        pwned << {
          vault: vault_name(item),
          type: template_name(item),
          title: item['overview']['title'],
          field: name,
          password: password,
          count: count
        }
      end

      def extract_passwords(item)
        passwords = {}

        case item['templateUuid']
        when '001'
          passwords = extract_login(item)
        when '005'
          passwords = extract_password(item)
        when '102', '109', '110', '111'
          passwords = extract_accounts(item)
        end

        passwords
      end

      def extract_login(item)
        passwords = {}

        password = item['details']['fields'].select do |f|
          f['type'] == 'P'
        end.first

        passwords = { 'password' => password['value'] } unless password.nil?
        passwords
      end

      def extract_password(item)
        passwords = {}

        unless item['details']['password'].nil?
          passwords = { 'password' => item['details']['password'] }
        end

        passwords
      end

      def extract_accounts(item)
        passwords = {}

        item['details']['sections'].each do |section|
          next if section['fields'].nil?

          sec = section['fields'].select { |f| f['t'].include?('password') }
          sec.each do |s|
            passwords[s['n']] = s['v'] unless s['v'].nil?
          end
        end

        passwords
      end

      def vault_name(item)
        @vaults.select { |v| v['uuid'] == item['vaultUuid'] }.first['name']
      end

      def template_name(ite)
        @templates.select { |t| t['uuid'] == ite['templateUuid'] }.first['name']
      end
    end
  end
end
