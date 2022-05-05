module HeaderMap
	class HMapTool
		# @return 调整成对应的大小端的format
		# @note 调整format至对应的大小端模式
		def self.transfer_format_from_endian_type(format, is_small_endian_type)
			endian_code = is_small_endian_type ? '<' : '>'
			format.tr('=', endian_code)
		end



	end
end
