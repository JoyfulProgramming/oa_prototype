require_relative '../../lib/boot'

RSpec.describe TracerMiddleware do
  let(:app) { ->(env) { [200, { 'Content-Type' => 'text/plain' }, ['Hello World']] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { { 'PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET', 'HTTP_X_FORWARDED_FOR' => '127.0.0.1', 'HTTP_REFERER' => 'https://example.com', 'HTTP_X_REAL_IP' => '1.2.3.4' } }

  before do
    App.telemetry_client.clear!
  end

  describe '#call' do
    it 'traces the request and adds an event' do
      middleware.call(env)

      traces = App.telemetry_client.traces
      expect(traces.size).to eq(1)
      
      trace = traces.first
      expect(trace[:path]).to eq('/test')
      expect(trace[:method]).to eq('GET')
      expect(trace[:application_info]).to eq(App.telemetry_client.web_application_info.values.first)
      expect(trace[:request_headers]).to eq('X-Forwarded-For' => '127.0.0.1', 'Referer' => 'https://example.com', 'X-Real-Ip' => '1.2.3.4')
      expect(trace[:status_code]).to eq(200)
      expect(trace[:start_time]).to be_a(Time)
      expect(trace[:end_time]).to be_a(Time)
      expect(trace[:response_headers]).to eq('Content-Type' => 'text/plain')
      expect(trace[:remote_address]).to eq('1.2.3.4')
    end

    it 'traces requests even when the app raises an error' do
      error_app = ->(_env) { raise 'Boom!' }
      error_middleware = described_class.new(error_app)

      expect {
        error_middleware.call(env)
      }.to raise_error('Boom!')

      traces = App.telemetry_client.traces
      expect(traces.size).to eq(1)
      
      trace = traces.first
      expect(trace[:path]).to eq('/test')
      expect(trace[:method]).to eq('GET')
      expect(trace[:application_info]).to eq(App.telemetry_client.web_application_info.values.first)
      expect(trace[:request_headers]).to eq('X-Forwarded-For' => '127.0.0.1', 'Referer' => 'https://example.com', 'X-Real-Ip' => '1.2.3.4')
      expect(trace[:status_code]).to be_nil
      expect(trace[:start_time]).to be_a(Time)
      expect(trace[:end_time]).to be_nil
      expect(trace[:response_headers]).to be_nil
      expect(trace[:remote_address]).to eq('1.2.3.4')
    end
  end
end
