# frozen_string_literal: tru

# require_relative 'Core/hmap_struct/hmap_struct'
# require_relative 'Core/Tool/hmap_tool'
require_relative 'Core/hmap_struct/hmap_struct'

def fetch_hmap_bin_path
	hmap_bin_name = 'test_hmap.hmap'
	resource_dir = "#{Dir.pwd}/Resource"
	hmap_bin_path = File.expand_path(hmap_bin_name, resource_dir)
end

def read_buckets (hmap_header, &bucket_handler)
	# 读取bucket的内容
	buckets_num = hmap_header.num_buckets
	bucket_offset = HeaderMap::HMapHeader.byte_size
	bucket_size = HeaderMap::HMapBucket.byte_size
	bucket_array = []

	for i in 0..buckets_num - 1
		bucket_data = File.read(fetch_hmap_bin_path, bucket_size, bucket_offset + i * bucket_size)
		bucket = HeaderMap::HMapBucket.load_from_binary_data(bucket_data, true)

		if bucket_handler.nil? == FALSE && bucket.key != 0
			bucket_array[i] = { bucket => bucket_handler.call(bucket, i) }
		end
	end

	log_description = bucket_array.each_with_index do |entry, index|
		if  entry != nil
			puts entry.values[0].description
		end
	end
end

raw_data = File.open(fetch_hmap_bin_path, 'rb', &:read);

# raw_data = File.open(fetch_hmap_bin_path, 'rb') {
# 		|x| puts x.class.read(fetch_hmap_bin_path, HeaderMap::HMapHeader.byte_size, 0) + 'block_inset'
# }
a = File.read(fetch_hmap_bin_path, HeaderMap::HMapHeader.byte_size, 0)

hmap_header = HeaderMap::HMapHeader.load_from_binary_data(a, true)
string_t = raw_data[hmap_header.strings_offset..-1]
read_buckets(hmap_header) do
|bucket, index|
	bucket_data_array =  bucket.to_a.map do |property|
		end_index = string_t.index("\0", property) - 1
		string_t[property..end_index]
	end
	HeaderMap::HMapEntry.new(*bucket_data_array)
end
