require 'aws-sdk-s3'
require 'digest'

if 2 != ARGV.length
  puts "arguments not enough"
  puts "Usage: ruby upload.rb tag file_name"
  exit(false)
end

version = ARGV[0]
file_name = ARGV[1]
bucket = 'bitmarkd-flatpak'
region = 'ap-northeast-1'

s3 = Aws::S3::Resource.new(region: region)
obj = s3.bucket(bucket).object(file_name)
sha256 = Digest::SHA256.file file_name
puts "file #{file_name} with sha-256: #{sha256}"

# setup metadata
metadata = {
  'x-amz-meta-sha256' => sha256.to_s,
  'x-amz-meta-date' => Time.now.strftime("%Y-%d-%m"),
  'x-amz-meta-version' => ARGV[0]
}
content_type = 'application/x-www-form-urlencoded; charset=utf-8'

puts "uploading file..."
file = File.open(file_name, 'rb')
obj.upload_file(file, metadata: metadata, content_type: content_type)
file.close