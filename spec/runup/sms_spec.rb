require 'spec_helper'

class Rails
  class FakeCache
    def initialize
      @h = {}
    end

    def read key
      @h[key]
    end

    def write key, value, *args
      @h[key] = value
    end
  end

  class << self
    def cache
      @cache ||= FakeCache.new
    end
  end
end

describe Runup::SMS do
  it 'generate code' do
    Runup::SMS.set_generate_code_block do
      '112233'
    end

    expect(Runup::SMS.generate_code).to eq('112233')
  end

  it 'cache read & write' do
    Rails.cache.write '123', '321'
    expect(Rails.cache.read('123')).to eq('321')
  end

  it 'send' do
    Runup::SMS.set_send_block do |mobile_number, code, params|
      'ok'
    end

    result = Runup::SMS.send_sms('13000000000', '321', {})
    expect(result[:data]).to eq('ok')
    expect(Runup::SMS.check_code('18000000000', nil)).to eq(false)
    expect(Runup::SMS.check_code('13000000000', '321')).to eq(true)
  end

  it 'illegal_mobile_number' do
    result = Runup::SMS.send_sms('wrong_mobile_number', '321', {})

    expect(result[:success]).to eq(false)
    expect(result[:error_type]).to eq('illegal_mobile_number')
  end

  it 'retry_limit' do
    Runup::SMS.set_send_block do |mobile_number, code, params|
      'ok'
    end

    result = Runup::SMS.send_sms('18000000000', '321', {})
    expect(result[:data]).to eq('ok')
    expect(Runup::SMS.check_code('18000000000', '321')).to eq(true)

    result = Runup::SMS.send_sms('18000000000', '321', {})
    expect(result[:success]).to eq(false)
    expect(result[:error_type]).to eq('retry_limit')
    expect(Runup::SMS.check_code('18000000000', '321')).to eq(true)
  end
end
