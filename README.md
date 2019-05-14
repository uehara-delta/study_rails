# Rails 勉強メモ

* 参考
	* https://www.atmarkit.co.jp/ait/articles/1403/28/news035.html
	* https://qiita.com/yuitnnn/items/b45bba658d86eabdbb26

## Railsプロジェクト作成

`rails new xxx` だと `bundle install` が実行されてシステムの gem にインストールされてしまう。
システムの gem はクリーンに保ちたいので、先にディレクトリを作成し vendor/bundle に rails をインストールする。

```
$ mkdir xxx
$ cd xxx
$ bundle init
```

生成された Gemfile を編集して `gem "rails"` のコメントを外す。

```
$ bundle install --path vendor/bundle
$ bundle exec rails new . -B -d mysql
```

`bundle exec rails new` のオプション -B は bundle install を実行しない、-d は使用する DB を指定するという意味。

Gemfile を上書きするかどうかをきかれるので`bundle install --path vendor/bundle`

mysql2 のインストールでエラーが発生するのでオプションを追加

```
$ bundle config --local build.mysql2 "--with-cppflags=-I/usr/local/opt/openssl/include --with-ldflags=-L/usr/local/opt/openssl/lib"
$ bundle install --path vendor/bundle
```

* 参考
	* https://ty-engineer.com/ruby-on-rails/mysql-in-rails/
	* https://qiita.com/thunders/items/101c6b329830fb1fb27d


## Scaffold を使用せずにアプリケーションを作成

### モデルの作成

```
$ bundle exec rails generate model user name:string department:string
      invoke  active_record
      create    db/migrate/20190514010204_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
```

config/database.yml を編集し、MySQL の root パスワードを変更

```
$ bundle exec rake db:create
Created database 'rails_test2_development'
Created database 'rails_test2_test'
$ bundle exec rake db:migrate
== 20190514010204 CreateUsers: migrating ======================================
-- create_table(:users)
   -> 0.0058s
== 20190514010204 CreateUsers: migrated (0.0059s) =============================

```

### rails console でモデルの操作

```
$ bundle exec rails console
Loading development environment (Rails 5.2.3)
irb(main):001:0> user = User.new(name: "アリス", department: "ネットワーク管理部")
   (0.3ms)  SET NAMES utf8,  @@SESSION.sql_mode = CONCAT(CONCAT(@@sql_mode, ',STRICT_ALL_TABLES'), ',NO_AUTO_VALUE_ON_ZERO'),  @@SESSION.sql_auto_is_null = 0, @@SESSION.wait_timeout = 2147483
=> #<User id: nil, name: "アリス", department: "ネットワーク管理部", created_at: nil, updated_at: nil>
irb(main):002:0> user.save
   (0.3ms)  BEGIN
  User Create (0.4ms)  INSERT INTO `users` (`name`, `department`, `created_at`, `updated_at`) VALUES ('アリス', 'ネットワーク管理部', '2019-05-14 01:16:36', '2019-05-14 01:16:36')
   (4.5ms)  COMMIT
=> true
irb(main):003:0> User.create(name: "ボブ", department: "サービス開発部")
   (0.2ms)  BEGIN
  User Create (0.3ms)  INSERT INTO `users` (`name`, `department`, `created_at`, `updated_at`) VALUES ('ボブ', 'サービス開発部', '2019-05-14 01:16:57', '2019-05-14 01:16:57')
   (0.9ms)  COMMIT
=> #<User id: 2, name: "ボブ", department: "サービス開発部", created_at: "2019-05-14 01:16:57", updated_at: "2019-05-14 01:16:57">
```

### コントローラーの作成

```
$ bundle exec rails generate contorller users
      create  app/controllers/users_controller.rb
      invoke  erb
      create    app/views/users
      invoke  test_unit
      create    test/controllers/users_controller_test.rb
      invoke  helper
      create    app/helpers/users_helper.rb
      invoke    test_unit
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/users.coffee
      invoke    scss
      create      app/assets/stylesheets/users.scss
```

app/controllers/users_controller.rb に index メソッドを追加
```ruby
class UsersController < ApplicationController

  def index
    @users = User.all
  end

end
```

### ビューの実装

app/views/users/index.html.erb を作成
```erb
<h1>利用者一覧</h1>

<table>
  <thead>
    <tr>
      <th>氏名</th>
      <th>部署</th>
    </tr>
  </thead>

  <tbody>
    <% @users.each do |user| %>
    <tr>
      <td><%= user.name %></td>
      <td><%= user.department %></td>
    </tr>
    <% end %>
  </tbody>
</table>
```

### ルーティングの設定

config/routes.rb にルーティング設定を追加
```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: %i(index)
end
```

%i は要素がシンボルの配列

ルーティング設定の確認
```
$ bundle exec rake routes
                   Prefix Verb URI Pattern                                                                              Controller#Action
                    users GET  /users(.:format)                                                                         users#index
       rails_service_blob GET  /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
rails_blob_representation GET  /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
       rails_disk_service GET  /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
update_rails_disk_service PUT  /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
     rails_direct_uploads POST /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
```

### 実行確認

```
$ bundle exec rails server
```

ブラウザで http://localhost:3000/users にアクセス

### 「new」と「create」アクションを実装

app/views/users/new.html.erb を作成
```erb
<h1>新規利用者</h1>

<%= form_for(@user) do |f| %>
<div class="field">
  <%= f.label :name %><br>
  <%= f.text_field :name %>
</div>
<div class="field">
  <%= f.label :department %><br>
  <%= f.text_field :department %>
</div>
<div class="actions">
  <%= f.submit %>
</div>
<% end %>

<%= link_to 'Back', users_path %>
```

UsersContoller に new と create メソッドを定義
```ruby
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_url
    else
      render 'new'
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :department)
  end
```

* _path と _url の使い分け
	* https://qiita.com/higeaaa/items/df8feaa5b6f12e13fb6f

### ルーティング設定の追加

config/routes.rb の :user を引数に取る resources メソッドの only オプションに new と create を追加
```
  resources :users, only: %i(index new create)
```

http://localhost:3000/users/new にアクセスして動作確認

### show, edit, update, destroy アクションの実装

config/routes.rb の :user を引数に取る resources メソッドの only オプションを削除
```
  resources :users
```

ルーティング設定の確認
```
$ bundle exec rake routes
                   Prefix Verb   URI Pattern                                                                              Controller#Action
                    users GET    /users(.:format)                                                                         users#index
                          POST   /users(.:format)                                                                         users#create
                 new_user GET    /users/new(.:format)                                                                     users#new
                edit_user GET    /users/:id/edit(.:format)                                                                users#edit
                     user GET    /users/:id(.:format)                                                                     users#show
                          PATCH  /users/:id(.:format)                                                                     users#update
                          PUT    /users/:id(.:format)                                                                     users#update
                          DELETE /users/:id(.:format)                                                                     users#destroy
       rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
       rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
     rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
```

### コントローラーに show アクションを追加

UsersController(app/controllers/users_controller.rb) に show メソッドを追加
```ruby
  def show
    @user = User.find(params[:id])
  end
```

### show アクション用のビューを作成

app/views/users/show.html.erb を作成
```erb
<p>
  <strong>氏名:</strong>
  <%= @user.name %>
</p>
<p>
  <strong>部署:</strong>
  <%= @user.department %>
</p>

<%= link_to 'Back', users_path %>
```

### index アクションのビューに show アクションへのリンクを追加

app/views/users/index.html.erb を編集
```erb
    <% @users.each do |user| %>
    <tr>
      <td><%= link_to user.name, user_path(user) %></td>
      <td><%= user.department %></td>
    </tr>
    <% end %>
```

### edit アクションを追加

UsersController(app/controllers/users_controller.rb) に edit メソッドを追加
```ruby
  def edit
    @user = User.find(params[:id])
  end
```

### edit アクション用のビューを作成

app/views/users/edit.html.erb を作成
```erb
<h1>ユーザー編集</h1>
<%= form_for(@user) do |f| %>
<div class="field">
  <%= f.label :name %><br>
  <%= f.text_field :name %>
</div>
<div class="field">
  <%= f.label :department %><br>
  <%= f.text_field :department %>
</div>
<div class="actions">
  <%= f.submit %>
</div>
<% end %>

<%= link_to 'Back', users_path %>
```

### index アクションのビューに edit アクションへのリンクを追加

app/views/users/index.html.erb を編集
```erb
    <% @users.each do |user| %>
    <tr>
      <td><%= link_to user.name, user_path(user) %></td>
      <td><%= user.department %></td>
      <td><%= link_to '編集', edit_user_path(user) %></td>
    </tr>
    <% end %>
```

### update アクションを追加

UsersController(app/controllers/users_controller.rb) に update メソッドを追加
```ruby
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_url(@user)
    else
      render 'edit'
    end
  end
```

### destroy アクションを追加

UsersController(app/controllers/users_controller.rb) に destroy メソッドを追加
```ruby
  def destroy
    @user = User.find(params[:id])
    @user.destory
    redirect_to users_url
  end
```

### index アクションのビューに destroy アクションへのリンクを追加

app/views/users/index.html.erb を編集
```erb
    <% @users.each do |user| %>
    <tr>
      <td><%= link_to user.name, user_path(user) %></td>
      <td><%= user.department %></td>
      <td>
        <%= link_to '編集', edit_user_path(user) %>
        <%= link_to '削除', user_path(user), method: 'DELETE' %>
      </td>
    </tr>
    <% end %>
```

## リファクタリング

### アクションの共通処理をフィルターに変更

UsersController(app/controllers/users_controller.rb) を修正
```ruby
  before_action :set_user, only: %w(show edit update destroy)

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_url(@user)
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url
  end

  def set_user
    @user = User.find(params[:id])
  end
```

### new アクションのビューと edit アクションのビューで部分テンプレートを使用

app/views/users/_form.html.erb を作成
```erb
<%= form_for(@user) do |f| %>
<div class="field">
  <%= f.label :name %><br>
  <%= f.text_field :name %>
</div>
<div class="field">
  <%= f.label :department %><br>
  <%= f.text_field :department %>
</div>
<div class="actions">
  <%= f.submit %>
</div>
<% end %>
```

app/views/users/new.html.erb を修正
```erb
<h1>新規利用者</h1>

<%= render 'form' %>

<%= link_to 'Back', users_path %>
```

app/views/users/edit.html.erb を修正
```erb
<h1>ユーザー編集</h1>

<%= render 'form' %>

<%= link_to 'Back', users_path %>
```

### メール送信内容のプレビュー確認

メールのコンポーネントを生成
```
$ bundle exec rails generate mailer news
      create  app/mailers/news_mailer.rb
      invoke  erb
      create    app/views/news_mailer
      invoke  test_unit
      create    test/mailers/news_mailer_test.rb
      create    test/mailers/previews/news_mailer_preview.rb
```

NewsMailer(app/mailers/news_mailer.rb)に daily メソッドを追加
```ruby
class NewsMailer < ApplicationMailer

  default from: "from@example.com"
  def daily(datetime)
    @delivered_at = datetime
    mail to: "to@example.com"
  end

end
```

app/views/news_mailer/daily.text.erb ファイルを作成
```
Railsデイリーニュース
配信:<%= @delivered_at %>
```

test/mailers/previews/news_mailer_preview.rb を編集
```ruby
class NewsMailerPreview < ActionMailer::Preview
  def daily_news
    NewsMailer.daily(DateTime.now)
  end
end
```

http://localhost:3000/rails/mailers/news_mailer/daily_news にアクセスしてメールのプレビューを確認
