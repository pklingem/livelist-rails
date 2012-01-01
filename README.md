# livelist-rails
## a Rails extension incorporating livelist.js

## General Setup

### in your Gemfile:

    gem 'livelist', '0.0.2'

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

#### app/assets/javascripts/application.js (manifest file)

    //= require livelist-rails
    //= require users

#### app/views/layouts/application.html.erb

    <%= javascript_include_tag 'application' %>

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
