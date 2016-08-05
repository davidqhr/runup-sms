# 已经不维护

请使用

https://github.com/davidqhr/sms_ctrl

# Runup::SMS

依赖Rails.cache

发送短信，间隔限制，过期控制

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'runup-sms'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install runup-sms

## Usage

```ruby
# 设置生成code规则
# confing/initializes/runup-sms.rb
Runup::SMS.set_generate_code_block do
  rand.to_s[-6..-1]
end
```

```ruby
# 设置如何发送
# confing/initializes/runup-sms.rb
Runup::SMS.set_send_block do |mobile_number, code, params|
  ... 第三方发送服务
end
```

```ruby
# 生成一个code
Runup::SMS.generate_code
```

```ruby
# 发送验证码，传参格式同自定义的set_send_block, 默认为mobile_number, code, params
# 注意 传参规则是ruby 2.0之后的规则
Runup::SMS.send_sms(mobile_number, code: code, params: {
  ... 其他参数
})
```

```ruby
# 检查验证码是否匹配
Runup::SMS.check_code "13000000000", '231232'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/davidqhr/runup-sms/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
