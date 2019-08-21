# Rails 勉強メモ

* 参考
	* https://www.atmarkit.co.jp/ait/articles/1402/28/news047.html
	* https://www.atmarkit.co.jp/ait/articles/1403/28/news035.html
	* https://www.atmarkit.co.jp/ait/articles/1405/09/news038.html
	* https://www.atmarkit.co.jp/ait/articles/1405/16/news024.html
	* https://www.atmarkit.co.jp/ait/articles/1405/30/news036.html
	* https://www.atmarkit.co.jp/ait/articles/1406/30/news030.html
	* https://www.atmarkit.co.jp/ait/articles/1407/30/news031.html
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
# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "rails"
```

`--path vendor/bundle` を指定して `bundle install` を実行後、`bundle exec rails new` を実行する。

```
$ bundle install --path vendor/bundle
$ bundle exec rails new . -B -d mysql
```

`bundle exec rails new` のオプション -B は bundle install を実行しない、-d は使用する DB を指定するという意味。
Gemfile を上書きするかどうかをきかれるので Y を入力して続行。

mysql2 のインストールでエラーが発生するのでオプションを追加

```
$ bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib"
```

改めて`bundle install --path vendor/bundle` を実行する。

```
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

## Rails 4.1 の新機能

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

## ActiveRecord の基本機能

### テーブルの変更

```
$ bundle exec rails generate migration update_users
      invoke  active_record
      create    db/migrate/20190514070114_update_users.rb
```

db/migrate/20190514070114_update_users.rb を編集
```ruby
class UpdateUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :age, :integer
    add_column :users, :last_score, :integer
    add_column :users, :averate, :float
    add_column :users, :zip_code, :string
    add_column :users, :tel, :string
    add_column :users, :contact_type, :string, default: 'phone'
  end
end
```

```
$ bundle exec rake db:migrate
```

### モデルオブジェクトの生成/保存

* new
	* モデルオブジェクトの生成
* save
	* newで生成したオブジェクトをデータベースに保存
* changed?
	* モデルオブジェクトにデータベースに保存していない変更があるか確認
* create
	* newメソッドとsaveメソッドを同時に実行
* update
	* モデルオブジェクトの変更とデータベースの更新を同時に実行

### モデルオブジェクトの削除

* destroy
	* モデルオブジェクトをデータベースから削除
* destroyed?
	* モデルオブジェクトがデータベースから削除済みか確認

### モデルオブジェクトの検索

* find
	* 主キーを引数としてデータベースのレコード1つを取り出す
* where
	* 条件に当てはまるレコードをすべて取り出す
* pluck
	* where の戻り値に対して、属性値のみを取得し配列として返す
	* ActiveRecord オブジェクトを生成しないので高速に動作する
* order
	* カラムの値に基づき整列したレコードを取得する
* limit
	* 取得するレコード数の上限を指定する

### マイグレーションファイル

* `rails generate migration` コマンドでマイグレーションファイルを生成できる
* 引数に「AddXXXToYYY」や「RemoveXXXFromYYY」と指定すると「XXX」というカラムを「YYY：というテーブルに追加・削除するためのコードをマイグレーションファイルに実装してくれる

* マイグレーションファイルで使用できる ActiveRecord のメソッド
	* create_table(name, options)
	* drop_table(name)
	* change_table(name, options)
	* rename_table(old_name, new_name)
	* add_column(table_name, column_name, type, options)
	* rename_column(table_name, column_name, new_column_name)
	* change_column(table_name, column_name, type, options)
	* remove_column(table_name, column_name, type, options)
		* migration で rollback する場合は type が必須
	* add_index(table_name, column_names, options)
	* remove_index(table_name, column: column_name)
	* remove_index(table_name, name: index_name)

* type で適用できる型
	* :string
	* :text
	* :integer
	* :float
	* :decimal
	* :datetime
	* :timestamp
	* :time
	* :date
	* :binary
	* :boolean

### validates メソッド

属性の値がデータベースに反映される前に適切であるかを検証する仕組み

* errors.messages
	* 属性名とエラーメッセージの Hash で返す
* errors.full_massages
	* すべての属性のエラーメッセージを一次元の配列で返す

* validates メソッドで使える主なバリデーション
	* presence : 値が空でないかを検証
	* length : 指定した属性の長さを検証
	* format : 指定した属性が正規表現にマッチするかを検証
	* uniqueness : 指定した属性がデータベース中で重複していないかを検証
	* numericality : 指定した属性が数値であるかを検証
	* inclusion : 指定した属性が配列または範囲に含まれているかを検証
	* acceptance : チェックボックにチェックが入ってるかを検証
	* confirmation : 確認用の一時属性と値が同じかどうかを検証
	* exclusion : inclusion の逆で属性が配列または範囲に含まれていないかを検証
	* absence : 空白であることを検証

* validates メソッドの便利なオプション
	* allow_nil : 属性が空の時、バリデーションをスキップ
	* if, unless : バリデーションの実行条件を定義

* validates をスキップするメソッド
	* update_all : where で得られたモデルオブジェクトの集合すべてに対して更新を行う
	* update_attribute : バリデーションをせず、特定のカラムを更新するモデルオブジェクトのメソッド
	* update_column : バリデーションとコールバックをせず、特定のカラムを更新するモデルオブジェクトのメソッド
	* update_columns : バリデーションとコールバックをせず、複数のカラムを更新するモデルオブジェクトのメソッド

### 関連を作成

#### 一対多の関連

```
$ bundle exec rails generate model book title:string author:string outline:text
$ bundle exec rails generate migration AddUserIdToBook user_id:integer
$ bundle exec rake db:migrate
```
app/models/book.rb を編集
```ruby
class Book < ApplicationRecord
  belongs_to :user
end
```
* ApplicationRecord
	* Rais 5 からモデルの継承元が ActiveRecord::Base から ApplicationRecord に変更

app/models/user.rb を編集
```ruby
class User < ApplicationRecord
  has_many :books
end
```

* belongs_to のオプション
	* dependent : 値に「:destroy」を設定すると、そのモデルオブジェクトが「destroy」メソッドにより削除されたときに参照しているモデルオブジェクトの「destroy」メソッドも実行して削除する
	* foreign_key : 外部キーを標準の「第一引数 + _id」とは別の名前にする
	* class_name : 関連名と参照先モデル名が異なる場合、関連が対象とするモデルを指定する

* has_many のオプション
	* dependent : 値に「:destory」を設定すると、「destory」メソッドにより削除されたときにすべての関連するモデルオブジェクトを削除、「:destory_all」を設定すると、「コールバック」なしで関連するモデルオブジェクトのレコードに SQL の DELETE文を実行する
	* foreign_key : 参照元モデルにおいて「関連」名に「_id」を付けた名前ではないカラムを外部キーの格納場所としている場合、参照先モデル側でも「:foreign_key」オプションを指定する必要がある
	* class_name : 「関連」名が小文字の参照元モデル名の複数形と異なる場合、「関連」が対象とするモデルを指定する

#### 一対一の関連

参照元モデルは「belongs_to」で定義し、参照先モデルでは「has_many」の代わりに「has_one」を使用する。

#### 多対多の関連

多対多の関連を作るには対象の2つのモデルとは別に接続情報を持つモデルが必要になる。

```
$ bundle exec rails generate model tag name:string
$ bundle exec rails generate model tagging tag:references book:references
$ bundle exec rake db:migrate
```

* generate mode で指定している references は参照型
	* データベースにインデックスを追加
	* モデルの定義にあらかじめ「belongs_to」を生成

app/models/book.rb を編集
```ruby
class Book < ApplicationRecord
  belongs_to :user
  has_many :taggins
  has_many :tags, through: :taggings
end
```

app/models/tag.rb を編集
```ruby
class Tag < ApplicationRecord
  has_many :taggings
  has_many :books, through: :taggings
end
```

#### 「関連」に基づく検索

* 関連しているオブジェクトに条件を指定して検索を行う
```ruby
book_rails = Book.fined_by(title: "Rails入門")
book_rails.tags.where(name: "Ruby")
```

* 関連先のモデルの属性を対象に関連元のモデルの検索を行う
```ruby
Book.joins(:tags).where(tags: {name: "Rails"})
Book.joins(:tags).where("tag.name = ?", "Rails")
```

#### 「スコープ」による検索条件の登録

よく使う検索条件にはモデル中にあらかじめ名前をつけて定義して「スコープ」という仕組みがある。
```ruby
class Book < ApplicationRecord
  belongs_to :user
  has_many :taggings
  has_many :tags, through: :taggings
  scope :tagged_recommended, -> { joins(:tags).where(tags {name: 'recommended'}) }
end
```

* 第１引数にスコープ名、第２引数に検索状家をラムダ(->)で与える
	* ラムダで渡すのは処理の中身を遅延実行させるため

### コールバック

モデルオブジェクトが保存されるときなど、モデルオブジェクトに関する特定のイベントが発生した際に実行したい処理を指定しておく仕組み。

* コールバックを実行するメソッドでオブジェクトの保存や更新に関わるもの
	* create
	* create!
	* decrement!
	* destroy
	* destroy_all
	* increment!
	* save
	* save!
	* save(validate: false)
	* toggle!
	* update_attribute
	* update
	* update!
	* valid?

* コールバックの種類
	* 新規作成(create)系メソッドと更新(update)系メソッドのコールバック
		* before_validation
		* after_validation
		* before_save
		* around_save
		* before_create
		* before_update
		* around_create
		* around_update
		* after_create
		* after_update
		* after_save
	* 削除(destroy)系メソッドのコールバック
		* before_destroy
		* around_destroy
		* after_destroy

#### コールバックの指定方法

コールバックメソッドの引数に処理を行うメソッドのシンボルを指定
```ruby
class Book < ApplicationRecord
  after_save :increment_user_books_size
  private
  def increment_user_books_size
    self.user.increment!(:books_size)
  end
end
```

コールバックメソッドの引数に処理を記述した文字列を指定
```ruby
class Book < ApplicationRecord
  after_save "self.user.increament!(:book_size)"
end
```

コールバックメソッドにブロックを指定
```ruby
class Book < ApplicationRecord
  after_save do |record|
    record.user.increment!(:book_size)
  end
end
```

コールバックメソッドの引数にコールバックのメソッドを持つクラスを指定
```ruby
class Book < ApplicationRecord
  after_create BooksSizeIncrement.new
end

class BooksSizeIncrement
  def initialize()
  end

  def after_create(record)
    record.user.increment!(:books_size)
  end
```

## コントローラーとルーティング

```
$ bundle exec rails generate controller admin/books --helper=false --asserts=false
      create  app/controllers/admin/books_controller.rb
      invoke  erb
      create    app/views/admin/books
      invoke  test_unit
      create    test/controllers/admin/books_controller_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/admin/books.coffee
      invoke    scss
      create      app/assets/stylesheets/admin/books.scss
```

### アクションの実装

app/controllers/admin/books_controller.rb を編集
```ruby
class Admin::BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

### ルーティング

config/routes.rb を編集
```ruby
Rails.application.routes.draw do
  resources :books
  resources :users
  get 'admin' => 'admin/books#index'
end
```

### レンダリング

app/views/admin/books/index.html.erb を作成
```erb
<p id="notice"><%= notice %></p>

<h1>Books</h1>
<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Author</th>
      <th>Outline</th>
      <th colspan="3"></th>
    </tr>
  </thead>
  <tbody>
    <% @books.each do |book| %>
    <tr>
      <td><%= book.title %></td>
      <td><%= book.author %></td>
      <td><%= book.outline %></td>
      <td><%= link_to 'Show', book %></td>
      <td><%= link_to 'Edit', edit_book_path(book) %></td>
      <td><%= link_to 'Destroy', book, method: :delete, data: { confirm: 'Are you sure?' } %></td>
    </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Book', new_book_path %>
```

### コントローラーの機能

#### パラメーター

* パラメーターの種類
	* URL文字列中に含める「クエリ文字列パラメーター」
	* ルーティングで定義される「ルーティングパラメーター」
	* POSTリクエストの「POSTデータパラメーター」


##### Stong Parameter

Rails 4 から導入された Strong Parameter はリクエストに含まれていてもよいパラメーターをコントローラーで指定する機能。

以下のコードは Rails 4 からエラーになる。
```ruby
params[:book] = {
  "title" => "新しい本",
  "author" => "新しい作者",
}
Book.new(params[:book])
=> ActiveModel::ForbiddenAttributesError:
```

## 「N+1クエリ」問題

モデルオブジェクトのコレクションをレコードごとに順に参照する場合に起こりがちなパフォーマンスに関わる問題。

* 例) BookモデルとAuthorモデルがあり、BookモデルがAuthorモデルを参照しているとする
```ruby
#コントローラー
@books = Book.all

#ビュー
- @books.each do |book|
  = book.title
  = book.author.name
```
* この時、`book.author.name`の呼び出しごとにデータベースへの問い合わせが発生する
* ActiveRecordの「includes」メソッドにより、あらかじめ関連モデルを読み込んでおくことができる
```ruby
@books = Book.includes(:author)
```
* includes に似たメソッドに joins があるが振る舞いが異なる。
	* includes は通常、別途 select を実行して結果をキャッシュする
	* joins は INNER JOIN を追加した select を実行する(結果の件数が includes と異なる)
	* includes と references で LEFT OUTER JOIN になったり(distinct されるため件数は includesと同じ)、includes と joins を組み合わせたり(distinct されない)もできる
	* 参考： https://qiita.com/south37/items/b2c81932756d2cd84d7d
