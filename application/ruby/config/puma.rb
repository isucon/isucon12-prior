environment ENV.fetch('RACK_ENV') { 'development' }

workers ENV.fetch('WEB_WORKERS') { 1 }

threads_min = ENV.fetch('WEB_THREADS_MIN', 1).to_i
threads_max = ENV.fetch('WEB_THREADS_MAX', threads_min).to_i
threads threads_min, threads_max

port ENV.fetch('PORT') { 3000 }

root = File.expand_path('..', __dir__)
directory root
rackup File.join(root, 'config.ru')
pidfile File.join(root, 'tmp', 'puma.pid')
