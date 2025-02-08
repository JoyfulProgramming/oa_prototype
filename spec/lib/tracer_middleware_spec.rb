require_relative '../../lib/boot'

RSpec.describe TracerMiddleware do
  let(:app) { ->(env) { [200, { 'Content-Type' => 'text/plain' }, ['Hello World']] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { { 'PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET', 'HTTP_X_FORWARDED_FOR' => '127.0.0.1', 'HTTP_REFERER' => 'https://example.com' } }

  before do
    App.telemetry_client.clear!
  end

  describe '#call' do
    it 'traces the request and adds an event' do
      # Make the request
      status, headers, body = middleware.call(env)

      traces = App.telemetry_client.traces
      expect(traces.size).to eq(1)
      
      trace = traces.first
      expect(trace[:path]).to eq('/test')
      expect(trace[:method]).to eq('GET')
      expect(trace[:application_info]).to eq(App.telemetry_client.web_application_info.values.first)
      expect(trace[:request_headers]).to eq('X-Forwarded-For' => '127.0.0.1', 'Referer' => 'https://example.com')
      expect(trace[:status_code]).to eq(200)
      expect(trace[:start_time]).to be_a(Time)
      expect(trace[:end_time]).to be_a(Time)
      expect(trace[:response_headers]).to eq('Content-Type' => 'text/plain')
    end

    it 'traces requests even when the app raises an error' do
      error_app = ->(_env) { raise 'Boom!' }
      error_middleware = described_class.new(error_app)

      # Expect the error to be raised
      expect {
        error_middleware.call(env)
      }.to raise_error('Boom!')

      # Verify the trace event was still created
      traces = App.telemetry_client.traces
      expect(traces.size).to eq(1)
      
      trace = traces.first
      expect(trace[:path]).to eq('/test')
      expect(trace[:method]).to eq('GET')
      expect(trace[:application_info]).to eq(App.telemetry_client.web_application_info.values.first)
      expect(trace[:request_headers]).to eq('X-Forwarded-For' => '127.0.0.1', 'Referer' => 'https://example.com')
      expect(trace[:status_code]).to be_nil
      expect(trace[:start_time]).to be_a(Time)
      expect(trace[:end_time]).to be_nil
      expect(trace[:response_headers]).to be_nil
    end
  end
end
