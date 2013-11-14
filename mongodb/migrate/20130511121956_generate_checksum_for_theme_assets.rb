class GenerateChecksumForThemeAssets < MongoidMigration::Migration
  def self.up
    Locomotive::ThemeAsset.all.each do |asset|
      asset.send(:calculate_checksum)

      puts "[#{asset.send(:safe_source_filename)}] #{asset.checksum}"

      begin
        asset.save!
      rescue Exception => e
        puts "\tfailed (#{e.message})"
      end
    end
  end

  def self.down
  end
end