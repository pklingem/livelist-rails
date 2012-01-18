# livelist-rails
## a Rails extension incorporating livelist.js

## General Setup

### in your Gemfile:

    gem 'livelist-rails', '0.0.3'

then:

    bundle install

## setup livelist for a resource, ex: users
### javascript setup

#### app/assets/javascripts/users.js.coffee

    $(document).ready ->
      list = new LiveList(
        global:
          resourceName: 'users'
          resourceNameSingular: 'user'
        list:
          renderTo: 'ul#users'
          listItemTemplate: '<li>{{first_name}} {{last_name}} ({{status}})</li>'
        filters:
          renderTo: 'div#filters'
        pagination:
          renderTo: 'div#pagination'
      )

#### Rails 3.1 - Asset Pipeline
##### app/assets/javascripts/application.js (manifest file)

    //= require livelist-rails
    //= require users

##### app/views/layouts/application.html.erb

    <%= javascript_include_tag 'application' %>

#### Rails 3.0
##### app/views/layouts/application.html.erb

if you are not already including mustache.js and underscore.min.js in
your application layout, add the following:

    <%= javascript_include_tag :livelist_dependencies %>

to include livelist.js or livelist.min.js (depending on your
environment) add the following:

    <%= javascript_include_tag :livelist %>

### controller setup
#### app/controllers/users_controller.rb

    def index
      @users = User.filter(params[:filters])
      @filters = User.filters_as_json(params[:filters])
    end

### JSON template setup
#### RABL
##### app/views/users/index.json.rabl

    object false
    node :pagination do
      @pagination
    end
    node :filters do
      @filters
    end
    child(@users) do
      extends('users/user')
    end

##### app/views/users/user.json.rabl

    object @user
    attributes :first_name, :last_name, :status

### model setup

    class User < ActiveRecord::Base
      filters :status
    end

## Todos

# add gem dependencies
# add generator for Rails 3.0
