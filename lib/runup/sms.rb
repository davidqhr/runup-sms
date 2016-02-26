require "runup/sms/version"

module Runup
  module SMS

    @retry_limit ||= 55
    @expires ||= 30 * 60

    @generate_code_block = Proc.new do
      rand.to_s[-6..-1]
    end

    @send_block = Proc.new do |mobile_number, code, params|
      raise '请设置send_block'
    end

    @debug = false
    @debug_code = '123456'

    class << self
      attr_accessor :retry_limit, :expires

      # 设置是否为debug和debug_code
      # 在debug模式下，默认产生的所有验证码都为debug_code
      attr_accessor :debug, :debug_code

      # 设置生成code规则
      # Runup::SMS.set_generate_code_block do
      #   rand.to_s[-6..-1]
      # end
      def set_generate_code_block &block
        @generate_code_block = block
      end

      # 生成一个code
      # Runup::SMS.generate_code
      def generate_code
        debug ? debug_code : @generate_code_block.call
      end

      # 自定义设置如何发送
      # Runup::SMS.set_send_block do |mobile_number, code, params|
      #   ... 第三方发送服务
      # end
      def set_send_block &block
        @send_block = block
      end

      # 发送验证码，传参格式同自定义的set_send_block, 默认为mobile_number, code, params
      # Runup::SMS.send_sms(mobile_number, param: {
      #   ... 其他参数
      # })
      # Runup::SMS.send_sms(mobile_number, code: 123, param: {
      #   ... 其他参数
      # })
      def send_sms mobile_number, code: nil, params: {}
        mobile_number = mobile_number.to_s

        if code.nil?
          code = generate_code
        end

        unless mobile_number =~ /^1[3|4|5|7|8]\d{9}$/
          return { success: false, error: '请输入正确的手机号码', error_type: 'illegal_mobile_number' }
        end

        if retry_limit > 0 && Rails.cache.read(retry_limit_key(mobile_number))
          return { success: false, error: '操作太频繁，请稍后再试', error_type: 'retry_limit' }
        end

        result = {
          success: true,
          data: @send_block.call(mobile_number, code, params)
        }

        if retry_limit > 0
          Rails.cache.write(retry_limit_key(mobile_number), 'true', expires_in: retry_limit)
        end

        Rails.cache.write(code_cache_key(mobile_number), code, expires_in: expires)

        result
      end

      # 检查验证码是否匹配
      # Runup::SMS.check_code "13000000000", '231232'
      def check_code mobile_number, input_code
        input_code = input_code.to_s
        mobile_number = mobile_number.to_s
        cache_code = Rails.cache.read(code_cache_key(mobile_number))
        if cache_code.nil?
          return false
        end

        cache_code == input_code
      end

      private

      # keys
      def retry_limit_key mobile_number
        "runupsms:retry_limit_key:#{mobile_number}"
      end

      def code_cache_key mobile_number
        "runupsms:code_cache_key:#{mobile_number}"
      end
    end
  end
end
