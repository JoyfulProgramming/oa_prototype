require 'bundler/setup'
require_relative 'lib/boot'

use TracerMiddleware
use MemoryProfilerMiddleware
run Web
