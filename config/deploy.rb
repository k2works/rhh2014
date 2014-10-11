# config valid only for Capistrano 3.1
lock '3.2.1'
set :application, 'split-sample'
set :dist_dir_name, 'split-sinatra-landingpage'
set :dist_base_dir, '../'
set :deploy_to, '/var/www'

task :update do
  run_locally do
  end
end

# カレントパス配下にある application名のディレクトリをターボールにするだけ。
task :archive => :update do
  run_locally do
    execute "cd #{fetch :dist_base_dir}; tar -zcvf #{fetch :dist_dir_name}.tgz #{fetch :dist_dir_name}"
  end
end

# ターボールにしたファイルをサーバにアップロード。
# サーバのホームディレクトリに application名のディレクトリを作ってそこにアップ、
# 解凍して中身をホームディレクトリに展開
task :deploy => :archive do
  deploy_from = "#{fetch :dist_base_dir}/#{fetch :dist_dir_name}.tgz"
  on roles(:web) do
    begin
      old_project_dir = "#{fetch :deploy_to}/#{fetch :application}"
      if test "[ -d #{old_project_dir} ]"
        execute "rm -rf #{old_project_dir}"
      end
    rescue => e
      info "No previous release directory exists"
    end

    unless test "[ -d #{deploy_to} ]"
      execute "mkdir -p #{deploy_to}"
    end
    info deploy_from
    info deploy_to
    upload! deploy_from, deploy_to
    execute "cd #{deploy_to}; tar -zxvf #{fetch :dist_dir_name}.tgz; rm -fr #{fetch :dist_dir_name}.tgz"
    execute "cd #{deploy_to}; mv #{fetch :dist_dir_name} #{fetch :application}"
    work_dir = "#{deploy_to}/#{fetch :application}"
    execute "cd #{work_dir}; rvm use 2.1.1@split-sample; bundle install"

    unless test "[ -d #{work_dir}/tmp ]"
      execute "cd #{work_dir}; mkdir -p tmp"
    end
    current_dir = "#{deploy_to}/current"
    execute "ln -s -nf #{work_dir} #{current_dir}"
    execute "cd #{current_dir}; touch tmp/restart.txt"
  end
end

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
