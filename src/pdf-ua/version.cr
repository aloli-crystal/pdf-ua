module PDF
  module UA
    # Read at compile time from shard.yml (ALOLI convention).
    VERSION = {{
                (read_file("#{__DIR__}/../../shard.yml")
                  .lines
                  .find(&.starts_with?("version:")) || "version: 0.0.0")
                  .gsub(/^version:\s*/, "")
                  .chomp
              }}

    # The PDF/UA part this shard targets (PDF/UA-1).
    PART = 1
  end
end
