# frozen_string_literal: true

require 'json'

require_relative 'compose/version'

##
# Your one-stop shop for local development needs
module Compose
  def self.execute(*args)
    `docker compose #{args.join ' '}`.chomp
  end

  def self.port(service, port, template = nil)
    return unless enabled?

    port = ports.dig(service.to_s, port.to_s)
    port && template ? template % port : port
  end

  def self.ports
    @ports ||= begin
      # Get raw text block for service|ports
      result = enabled? ? execute(:ps, '--format', 'json') : ''

      # Parse results
      result.each_line.to_h do |line|
        data   = JSON.parse(line).slice('Service', 'Publishers')
        name   = data['Service']
        values = data['Publishers'].to_h { |pub| pub.slice('TargetPort', 'PublishedPort').values.map(&:to_s) }

        [name, values]
      end
    end
  end

  def self.enabled?
    ENV['RAILS_DISABLE_COMPOSE'].nil? || ENV['RAILS_DISABLE_COMPOSE'] == ''
  end
end
