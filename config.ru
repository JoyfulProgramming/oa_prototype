require 'bundler/setup'
require_relative 'lib/boot'

use TracerMiddleware
run Web