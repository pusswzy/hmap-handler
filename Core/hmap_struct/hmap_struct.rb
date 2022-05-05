require_relative '../Tool/hmap_tool'

module HeaderMap
	class HMapCommonStructure
		FORMAT = ' '
		SIZE = 0
		@@SMALL_ENDIAN_TYPE = false

		def  self.format
			# HMapCommonStructure::FORMAT
			# 👆这么写是有问题的 就会导致类常量一直是从HMapCommonStructure获取, 子类重写的类常量就会没有了 要改成👇
			self::FORMAT
		end

		# @see 为什么要用这种写法呢, 因为外界无法直接访问类常量,所以提供一个方法给外界访问类中的常量.这个size在读取源数据的时候很有用
		def self.byte_size
			self::SIZE
		end

		def self. load_from_binary_data(binary_data, is_small_endian)
			@@SMALL_ENDIAN_TYPE = is_small_endian
			transfer_format = HMapTool.transfer_format_from_endian_type(self.format, is_small_endian)
			# 调用了子类的初始化方法 并将unpack解析回的数组 使用*分配给子类各个形参
			new(*binary_data.unpack(transfer_format))
		end

		def log_all_property
			puts "✨"
		end
	end

	# HMapHeader
	# @see https://github.com/llvm/llvm-project/blob/2946cd701067404b99c39fb29dc9c74bd7193eb3/clang/include/clang/Lex/HeaderMapTypes.h
=begin
	struct HMapHeader {
  uint32_t Magic;          // Magic word, also indicates byte order.
  uint16_t Version;        // Version number -- currently 1.
  uint16_t Reserved;       // Reserved for future use - zero for now.
  uint32_t StringsOffset;  // Offset to start of string pool.
  uint32_t NumEntries;     // Number of entries in the string table.
  uint32_t NumBuckets;     // Number of buckets (always a power of 2).
  uint32_t MaxValueLength; // Length of longest result path (excluding nul).
  // An array of 'NumBuckets' HMapBucket objects follows this header.
  // Strings follow the buckets, at StringsOffset.
};
=end
	class HMapHeader < HMapCommonStructure
		attr_reader :magic, :version, :reserved, :strings_offset, :num_entries, :num_buckets, :max_value_length

		FORMAT = 'L=1S=2L=4'
		SIZE = 24

		def initialize(magic, version, reserved, strings_offset, num_entries, num_buckets, max_value_length)
			@magic = magic
			@version = version
			@reserved = reserved
			@strings_offset = strings_offset
			@num_entries = num_entries
			@num_buckets = num_buckets
			@max_value_length = max_value_length
		end

		def log_all_property
			super
			puts "打印类:#{self.class} @magic = #{@magic}, @version = #{@version}, @reserved = #{reserved}, @strings_offset = #{strings_offset}, @num_entries = #{num_entries}, @num_buckets = #{num_buckets}, @max_value_length = #{max_value_length}, "
			super
		end
	end

	# Header Map Bucket
	# @see
	# struct HMapBucket {
	# 	uint32_t Key;    // Offset (into strings) of key.
	# 			uint32_t Prefix; // Offset (into strings) of value prefix.
	# 			uint32_t Suffix; // Offset (into strings) of value suffix.
	# };
	class HMapBucket < HMapCommonStructure
		FORMAT = 'L=3'
		SIZE = 12

		attr_reader :key, :prefix, :suffix
		def initialize (key, prefix, suffix)
			@key = key
			@prefix = prefix
			@suffix = suffix
		end

		def to_a
			[key, prefix, suffix]
		end

		def log_all_property
			super
			puts "打印类:#{self.class} @key = #{@key}, @prefix = #{@prefix}, @suffix = #{@suffix}"
		end

	end

	#hmap路径key和实际路径
	class HMapEntry
		attr_reader :key, :prefix, :suffix
		def initialize (key, prefix, suffix)
			@key = key
			@prefix = prefix
			@suffix = suffix
		end

		def to_h
			{
					key => {
							"prefix" => prefix,
							"suffix" => suffix
					}
			}
		end

		def description
			<<-DESC
			#{@key} -> #{prefix + suffix}

			DESC
		end

	end

end
