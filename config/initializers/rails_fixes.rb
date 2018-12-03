# Remove annoying "** ERROR: directory is already being watched! **" errors in development
# https://github.com/guard/listen/wiki/Duplicate-directory-errors
# https://github.com/rails/rails/issues/32700

if Rails.env.development?
  require 'listen/record/symlink_detector'
  module Listen
    class Record
      class SymlinkDetector
        def _fail(_, _)
          fail Error, "Don't watch locally-symlinked directory twice"
        end
      end
    end
  end
end
