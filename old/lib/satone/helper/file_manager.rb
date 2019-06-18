module Satone
  module Helper
    class FileManager
      attr_reader :name, :file_name

      def initialize(file_name)
        @file_name = file_name
      end

      def file_exists?
        File.exist? file_name
      end

      def add(line)
        File.open(file_name, "a") do |file|
          file.puts line
        end
      end

      def overwrite(lines)
        File.open(file_name, "w") do |file|
          lines.each do |line|
            file.puts line
          end
        end
      end

      def delete(word)
        new_lines = []

        begin
          File.open(file_name, "r") do |file|
            file.each_line do |line|
              new_lines.push line.chomp unless line.include? word
            end
          end

          File.open(file_name, "w") do |file|
            new_lines.each do |line|
              file.puts line
            end
          end
          return { success: 1, error: nil }
        rescue => e
          return { success: 0, error: e.inspect }
        end
      end

      def fetch_all
        lines = []
        File.open(file_name, "r") do |file|
          file.each_line do |line|
            lines.push line.chomp
          end
        end

        lines
      end
    end
  end
end
