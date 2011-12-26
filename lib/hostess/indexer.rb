require 'rubygems/format'
require 'rubygems/indexer'
require 'fog'

module Hostess
  class Indexer
    def write_gem(body, spec)
      gem_file = directory.files.create(
        :body   => body.string,
        :key    => "gems/#{spec.original_name}.gem",
        :public => true
      )

      gem_spec = directory.files.create(
        :body   => Gem.deflate(Marshal.dump(spec)),
        :key    => "quick/Marshal.4.8/#{spec.original_name}.gemspec.rz",
        :public => true
      )
    end

    def update_index
      log "Updating the index"
      upload("specs.4.8.gz", specs_index)
      log "Uploaded all specs index"
      upload("latest_specs.4.8.gz", latest_index)
      log "Uploaded latest specs index"
      upload("prerelease_specs.4.8.gz", prerelease_index)
      log "Uploaded prerelease specs index"
      log "Finished updating the index"
    end

    private

    def directory
      fog.directories.get('repo')
    end

    def all_gems
      fog.directories.get('repo/gems').files
    end

    def fog
      $fog || Fog::Storage.new(
        :provider => 'Local',
        :local_root => File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'server'))
      )
    end

    def stringify(value)
      final = StringIO.new
      gzip = Zlib::GzipWriter.new(final)
      gzip.write(Marshal.dump(value))
      gzip.close

      final.string
    end

    def upload(key, value)
      file = directory.files.create(
        :body   => stringify(value),
        :key    => key,
        :public => true
      )
    end

    def minimize_specs(data)
      names     = Hash.new { |h,k| h[k] = k }
      versions  = Hash.new { |h,k| h[k] = Gem::Version.new(k) }
      platforms = Hash.new { |h,k| h[k] = k }

      data.each do |row|
        row[0] = names[row[0]]
        row[1] = versions[row[1].strip]
        row[2] = platforms[row[2]]
      end

      data
    end

    def specs_index
      minimize_specs rows_for_index
    end

    def rows_for_index
      all_gems.collect do |gf|
        spec = Gem::Package.open(StringIO.new(gf.body), "r", nil) {|pkg| pkg.metadata }
        [spec.name, spec.version.to_s, spec.platform]
      end
    end

    def latest_index
      minimize_specs rows_for_latest_index
    end

    def rows_for_latest_index
      latest = { }
      all_gems.collect do |gf|
        spec = Gem::Package.open(StringIO.new(gf.body), "r", nil) {|pkg| pkg.metadata }
        latest[spec.name] ||= [spec.name, spec.version.to_s, spec.platform]
        if Gem::Version.new(latest[spec.name][1]) < spec.version
          latest[spec.name] = [spec.name, spec.version.to_s, spec.platform]
        end
      end

      return latest.values
    end

    def prerelease_index
      return []
      minimize_specs rows_for_prerelease_index
    end

    def log(message)
      puts "#{Time.now} #{message}"
    end
  end
end
