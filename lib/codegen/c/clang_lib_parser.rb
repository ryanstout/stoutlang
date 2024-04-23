require 'ffi/clang'
require 'tempfile'

include FFI::Clang

class ClangLibParser
  def initialize

  end

  def preprocess_header(header_path)
    preprocessed_header = Tempfile.new('preprocessed_header')
    cflags = `llvm-config --cflags`
    system("clang -I/opt/homebrew/Cellar/llvm/17.0.6_1/include  -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -E -P -x c #{header_path}  | sed 's/__attribute__(([^)]*))//g' > #{preprocessed_header.path}")
    # `cp #{preprocessed_header.path} /tmp/header.h`
    preprocessed_header
  end

  def homebrew_prefix
    # Only execute on macOS systems
    return nil unless RUBY_PLATFORM.include?("darwin")

    # Dynamically get the Homebrew installation prefix
    prefix = `brew --prefix`.strip
    return nil if prefix.empty?

    prefix
  end

  def find_files(dir, filename)
    # Find all files matching the filename in directory and subdirectories
    matches = []
    Dir.glob("#{dir}/**/#{filename}").each do |file|
      matches << file if File.file?(file)
    end
    matches
  end

  def find_header_path(library_name)
    common_paths = [
      "/usr/include",
      "/usr/local/include",
      "/opt/local/include",
      "#{ENV['HOME']}/.local/include",
      "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include",
    ]

    brew_prefix = homebrew_prefix
    common_paths.push("#{brew_prefix}/opt/#{library_name}/include") if brew_prefix

    header_file = "#{library_name}.h"
    common_paths.each do |path|
      matches = find_files(path, header_file)
      return matches.first unless matches.empty?
    end
    nil
  end

  def list_functions(library_name)
    header_path = find_header_path(library_name)
    if header_path.nil?
      puts "Header file for #{library_name} not found."
      return
    end

    header_path = '/tmp/header.h'

    puts "Parsing #{header_path}..."

    index = Index.new

    parse_options = [
      '-x', 'c',
      # '-DCURL_STATICLIB',
      # '-DCURL_EXTERN=extern',  # Redefine CURL_EXTERN as extern, for libcurl
      # '-DFFI_AVAILABLE_APPLE=extern',
      "-I#{File.dirname(header_path)}",  # Include the directory of the header file
    ]

    # Run preprocessor first
    preprocessed_header = preprocess_header(header_path)
    index = Index.new
    # puts File.read(preprocessed_header.path)
    tu = index.parse_translation_unit(preprocessed_header.path, parse_options)

    # Load from file
    # tu = index.parse_translation_unit(header_path, parse_options)

    tu.cursor.visit_children do |cursor, parent|
      case cursor.kind
      when :cursor_function
        function_name = cursor.spelling
        return_type = cursor.type.result_type.spelling
        arg_details = []
        cursor.num_arguments.times do |i|
          arg = cursor.argument(i)
          arg_details << "#{arg.type.spelling} #{arg.spelling}"
        end
        puts "Function: #{return_type} #{function_name}(#{arg_details.join(', ')})"

      when :cursor_struct_decl
        struct_name = cursor.spelling
        member_details = []
        cursor.visit_children do |child, parent|
          if child.kind == :cursor_field_decl
            member_details << "#{child.type.spelling} #{child.spelling}"
          end
          :continue
        end
        puts "Struct: #{struct_name} { #{member_details.join('; ')} }"

      when :cursor_typedef_decl
        type_name = cursor.spelling
        aliased_type_spelling = cursor.type.canonical.spelling # Get the spelling of the canonical type
        # Check if the aliased type is a record type to provide details of struct/union
        if cursor.type.canonical.kind == :type_record
          member_details = []
          cursor.underlying_type.declaration.visit_children do |child, parent|
            if child.kind == :cursor_field_decl
              member_details << "#{child.type.spelling} #{child.spelling}"
            end
            :continue
          end
          puts "Typedef Struct: #{type_name} is an alias to #{aliased_type_spelling} { #{member_details.join('; ')} }"
        else
          puts "Type: #{type_name} is an alias to #{aliased_type_spelling}"
        end

      when :cursor_union_decl
        puts "Union: #{cursor.spelling}"

      when :cursor_enum_decl
        enum_name = cursor.spelling
        constant_details = []
        cursor.visit_children do |child, parent|
          if child.kind == :cursor_enum_constant_decl
            constant_name = child.spelling
            constant_value = child.enum_value
            constant_details << "#{constant_name} = #{constant_value}"
          end
          :continue
        end
        puts "Enum: #{enum_name} { #{constant_details.join(', ')} }"
      end
      :continue
    end
  end
end

ClangLibParser.new.list_functions("curl")
