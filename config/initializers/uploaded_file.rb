module ActionDispatch
	module Http
		class UploadedFile
			def to_liquid
				self.instance_values
			end
		end
	end
end