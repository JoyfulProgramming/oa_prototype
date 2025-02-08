environment ENV.fetch('RACK_ENV', 'development')
bind 'tcp://0.0.0.0:3000'
threads 0, 16
workers 0
