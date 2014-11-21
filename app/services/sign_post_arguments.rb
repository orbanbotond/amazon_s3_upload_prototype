class SignPostArguments
  def sign
    @expires = 10.hours.from_now
    render json: {
      acl: 'public-read',
      awsaccesskeyid: ENV['AWS_ACCESS_KEY_ID'],
      bucket: ENV['BUCKET_NAME'],
      expires: @expires,
      key: "#{params[:aws_dir]}/#{params[:name]}",
      policy: policy,
      signature: signature,
      success_action_status: '201',
      'Content-Type' => params[:type],
      'Cache-Control' => 'max-age=630720000, public'
    }, status: :ok
  end

  def signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        ENV['AWS_SECRET_ACCESS_KEY'],
        policy({ secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] })
      )
    ).gsub(/\n/, '')
  end

  def policy(options = {})
    Base64.encode64(
      {
        expiration: @expires,
        conditions: [
          { bucket: ENV['BUCKET_NAME'] },
          { acl: 'public-read' },
          { expires: @expires },
          { success_action_status: '201' },
          [ 'starts-with', '$key', '' ],
          [ 'starts-with', '$Content-Type', '' ],
          [ 'starts-with', '$Cache-Control', '' ],
          [ 'content-length-range', 0, 524288000 ]
        ]
      }.to_json
    ).gsub(/\n|\r/, '')
  end
end