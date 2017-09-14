require 'csv'
class CsvParser
  def initialize(path_to_file, options = {})
    @header_lines = options[:header_lines] || 1
    @data_begins_on_line = options[:data_begins_on_line] || 1
    @col_sep = options[:field_sep] || ","
    @row_sep = options[:line_sep] || "\n"
    @path_to_file = path_to_file
    @headers = nil
  end

  def line_at_a_time(&block)
    i = 0
    unless File.exist?(@path_to_file)
      return false
    end
    CSV.foreach(@path_to_file, col_sep: @col_sep, row_sep: @row_sep) do |row|
      yield(row, i)
      i += 1
    end
    true
  end

  def headers
    return @headers if @headers
    headers = []
    offset = 0
    line_at_a_time do |row, i|
      if row.size == 1
        offset += 1
        next
      end
      break if i >= (@header_lines + offset)
      row.each_with_index do |cell, j|
        headers[j] ||= []
        headers[j] << cell.gsub(/\r/, " ").gsub(/\n/, " ")
      end
    end
    @headers = []
    headers.each do |contents|
      @headers << contents.join(" ").
        # Fix spaces:
        sub(/^\s+/, "").sub(/\s+$/, "").gsub(/\s+/, " ")
    end
    @headers
  end

  def rows_as_hashes(&block)
    offset = 0
    hash = nil
    line_at_a_time do |row, i|
      offset += 1 if row.size == 1 && hash.nil?
      next if i < (@data_begins_on_line + offset)
      hash = Hash[headers.zip(row)]
      yield(hash, i)
    end
  end

  # TODO: parsing with diffs deserves its own class, move!
  def diff_as_hashes(db_headers, &block)
    @line_num = 0
    @diff = nil
    any_diff = line_at_a_time do |row, i|
      if row.size == 1 && row.first =~ /^\d+(\D)(\d+)?$/
        (diff_type, new_line) = [$1, $2]
        @diff = case diff_type
        when "a"
          :new
        when "c"
          :changed
        when "d"
          :removed
        end
        @line_num = new_line.to_i if new_line
        next
      end
      # "Removed" part of a change, we can ignore it:
      next if @diff == :changed && row.first =~ /^</
      # "switch" part of a change, ignore:
      next if @diff == :changed && row.size == 1 && row.first =~ /^---/
      # End of input (for "faked" new diffs):
      next if row.size == 1 && row.first == "."
      if @diff == :changed || @diff == :new
        row.first.sub!(/^> /, "")
      elsif @diff == :removed
        row.first.sub!(/^< /, "")
      end
      @line_num += 1
      hash = Hash[db_headers.zip(row)]
      yield(hash)
    end
    any_diff
  end
end
