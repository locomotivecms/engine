module ActionDispatch
	module Http
		class UploadedFile
			def to_liquid
				self.instance_values.merge('tempfile' => self.tempfile.path)
			end
		end
	end
end