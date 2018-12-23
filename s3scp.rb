require 'net/ssh'
require 'net/scp'
require 'aws-sdk-s3'

def process_inbound(event:, context:)
  s3 = Aws::S3::Resource.new(region: 'ca-central-1')
  
  # Process documents in the 'inbound' folder
  s3.bucket(ENV['INBOUND_DOCUMENT_BUCKET']).objects(prefix: 'inbound/').each do |document|
    obj = document.object

    # copy the document over to the remote host
    remote_filename = "#{ENV['INBOX_DIR']}/#{document.key.split('/').last}"
    Net::SSH.start(ENV['HOST'], ENV['USER'], key_data: [ENV['SSH_KEY']], keys_only: true) do |ssh|
      ssh.scp.upload!(obj.get.body, remote_filename)
    end
    puts "#{document.key} copied to #{ENV['HOST']}:/#{remote_filename}"

    # Move the document to the received/ folder
    target_key = document.key.sub('inbound', "received/#{Time.now.strftime('%Y-%m-%d')}")
    obj.copy_to "#{ENV['INBOUND_DOCUMENT_BUCKET']}/#{target_key}"
    obj.delete
    puts "Moved #{document.key} to #{target_key}"

  rescue StandardError => e
    puts "ERROR: Failed to copy #{document.key} to remote host: #{e.message}"
    # puts e.backtrace
  end
end
