class IsoAssetHost
  def compute(source, timestamp = nil)
    source
  end
end

class CdnAssetHost
  def compute(source, timestamp = nil)
    "http://cdn.locomotivecms.com#{source}"
  end
end

class TimestampAssetHost
  def compute(source, timestamp = nil)
    timestamp ? "#{source}?#{timestamp}" : source
  end
end