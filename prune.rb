require 'json'
require 'pp'
require 'rest-client'

API_TOKEN = ENV['PACKAGECLOUD_TOKEN']

REPOSITORY = ARGV[0] # 'user/repo'
DIST = ARGV[1] # 'ubuntu/xenial'
PACKAGE = ARGV[2] #'package-name'
LIMIT = ARGV[3].to_i

base_url = "https://#{API_TOKEN}:@packagecloud.io/api/v1/repos/#{REPOSITORY}"

package_url = "/package/deb/#{DIST}/#{PACKAGE}/amd64/versions.json"

url = base_url + package_url

redis_versions = RestClient.get(url)

parsed_redis_versions = JSON.parse(redis_versions)

sorted_redis_versions = parsed_redis_versions.sort_by { |x| Time.parse(x["created_at"]) }

if sorted_redis_versions.size >= LIMIT
  to_yank = sorted_redis_versions.first

  distro_version = to_yank["distro_version"]
  filename = to_yank["filename"]
  yank_url = "/#{distro_version}/#{filename}"
  url = base_url + yank_url

  puts "yanking #{url}"
  result = RestClient.delete(url)
  if result == {}
    puts "successfully yanked #{filename}!"
  end
end
