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

s3 = Aws::S3::Resource.new(region: 'ap-northeast-1')
obj = s3.bucket(bucket).object(file_name)
file = File.open(file_name, 'rb')
sha256 = Digest::SHA256.file file_name
puts "file #{file_name} with sha-256: #{sha256}"

# setup metadata
obj.metadata['content-type'] = 'application/x-www-form-urlencoded; charset=utf-8'
obj.metadata['x-amz-meta-sha256'] = sha256
obj.metadata['x-amz-meta-date'] = Time.now.strftime("%Y-%d-%m")
obj.metadata['x-amz-meta-version'] = ARGV[0]

puts "uploading file..."
obj.upload_file(file)