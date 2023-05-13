#!/bin/bash

# sudo service nginx start
cd /app
RAILS_ENV=production bin/rails db:migrate
# RAILS_ENV=production bin/rails assets:precompile
bundle exec unicorn -p 3000 -c ./config/unicorn.rb -E production
