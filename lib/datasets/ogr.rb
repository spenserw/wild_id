# frozen_string_literal: true

module Datasets
  class OGR
    DEFAULT_FLAGS = %w[-overwrite -progress].freeze

    def self.to_postgres(source, table:, layer: nil, nlt: nil, s_srs: nil, t_srs: nil)
      args = [
        "ogr2ogr",
        *DEFAULT_FLAGS,
        "PG:#{pg_connection}",
        source.to_s,
        "-nln", table.to_s
      ]
      args << layer.to_s if layer
      args.push("-nlt", nlt) if nlt
      args.push("-s_srs", s_srs) if s_srs
      args.push("-t_srs", t_srs) if t_srs

      system(*args, exception: true)
    end

    def self.pg_connection
      cfg = ActiveRecord::Base.connection_db_config.configuration_hash

      parts = []
      parts << "dbname=#{cfg[:database]}" if cfg[:database]
      parts << "user=#{cfg[:username]}" if cfg[:username]
      parts << "password=#{cfg[:password]}" if cfg[:password].present?
      parts << "host=#{cfg[:host]}" if cfg[:host].present?
      parts << "port=#{cfg[:port]}" if cfg[:port].present?
      parts.join(" ")
    end
    private_class_method :pg_connection
  end
end
