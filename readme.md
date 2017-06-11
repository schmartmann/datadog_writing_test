# Monitoring Sinatra Turntable with Datadog APM

**Sinatra Turntable** is a framework that allows you to spin up a full-stack web app in just a few minutes, which integrates seamlessly with Datadog’s APM service for application performance monitoring.

APM allows you to trace requests and template rendering across your Sinatra app, so you can have a fuller picture of its health.


## Sinatra Turntable

Sinatra Turntable is a full-stack framework with two principal components:

- A **Sinatra** web server.
- A PostgreSQL database with an **ActiveRecord** wrapper.


Sinatra is a minimalist web server written in Ruby that receives and inteprets HTTP requests, and renders HTML template views in response.

ActiveRecord is a Ruby gem that allows us to interface with our database in Ruby, as opposed to writing in SQL inside our Ruby app, so you only need one language to work across your stack.

With just a few commands, we can bootstrap a full web app with data-persistence.

## Installing Sinatra Turntable

To install the Sinatra Turntable app generator, use the text editor of your choice to open your bash  profile (typically located in `~/.bash_profile`), [add this snippet](https://gist.github.com/schmartmann/7384d6e8a73657152778dc4d0936f28b), and save.

*NOTE*: You may need to reload your terminal before accessing the sinatra_turntable script.

## Running The Generator

To run the generator, use the bash command `sinatra_turntable <your_apps_name>`.

_Example_:
`$ sinatra_turntable mans_best_friends`

The generator will create a directory structure, and populate it with the files needed to run your app.

The generator will prompt:`Would you like to set up ActiveRecord for this project? (y/n)`. If you don’t want ActiveRecord integration, simply reply `n`, and the generator will exit, leaving you with just a Sinatra app. Otherwise, reply `y`, and the generator will create the directories and files needed to integrate a database.

Once complete, you should see this directory structure:
![Sinatra Turntable Directory Structure](tree.png)

Once the generator finishes, test your app by running `$ rackup`. You should see the familiar Hello World! on `localhost:9292`.

![Hello World](hello_world_test.png)

## Setting Up Your Database

Once created, we will want to set up at least one table in our database.

### Step 1: Creating the Database

Our database hasn’t actually been created yet, so run `$ rake db:create` to instantiate it.

*NOTE*: to list all rake commands, run `$ rake -T`.

### Step 2: Creating a Model File

ActiveRecord needs a model file to interact with your database tables. A model is a Ruby class, and defines how to interact with a collection of data. Its use here is identical to models in a Ruby on Rails app.  

Create a Ruby file in the `models` directory. The file name should correspond to the singular form of your database’s table’s name. For our example, we will create `dog.rb` inside the `models/` directory, since we want a `dogs` table.

**models/dog.rb**:

```ruby
class Dog < ActiveRecord::Base
end
```
### Step 3: Creating a Migration File

Next, create a migration file that adds our table to the database.

Run `$ rake db:create_migration NAME=<migration_name>` and rake will automatically generate a migration file in `db/migrate`.

In our example, that command looks like this:
`rake db:create_migration NAME=add_dogs_table`

This generates a date-stamped migration file, within which you can define your table’s attributes.

Our example migration file looks like this:
**db/migrate/20170608222332_add_dogs_table.rb**:

```ruby
class AddDogsTable < ActiveRecord::Migration
  def change
    create_table :dogs do |t|
      t.string :name
      t.string :breed
      t.integer :age
      t.boolean :is_good_boy
    end
  end
end
```
### Step 4: Running the Migration

Running `$ rake db:migrate`runs the migration file to make any additions or alternations to your database’s tables. Notice there is now a `schema.rb` file, that describes your tables, and lists the most recent migration's date.

In our example, our migration file creates a `dogs` table, and our `models/dog.rb` file allows us to access it via the `Dog` object in our Sinatra app.

If you want your database pre-populated, add that data to `db/seeds.rb`, and run `rake db:seed` to seed your database.


Now that we have a server and a database, let’s build an index view to make sure the two are communicating correctly.

## Templating Views

The `server.rb`file controls how your server responds to HTTP requests, and is where your routes live.

You should see a function block that describes your application’s root path at `/`:

**server.rb**:
```ruby
get “/“ do
  erb :index
end
```

Add a new route that responds with data from your database.

For our example app, we will add a `/dogs` route, and fetch a list of all the dogs in our database. 

Example: 


```ruby
get "/dogs"
  @dogs = Dog.all
  erb :index
end
```
Because this framework's base is Sinatra, we can take advantage of its powerful template rendering `erb` tags. Here's an example of how to render the example's list of dogs in the index view template:

**views/index.erb**:
```erb
<div>
  <% @dogs.each do |dog| %>
    <ul>
      <li>Name: <%= dog.name%></li>
      <li>Breed: <%= dog.breed%></li>
      <li>Is A Good Boy? <%= dog.is_good_boy%></li>
    </ul>
</div>
```

## Enabling APM Tracing

To enable APM tracing, first ensure you have a [Datadog account](https://www.datadoghq.com/), and install the [Datadog Agent](https://app.datadoghq.com/account/settings#agent). 

First, add `gem ddtrace` to your Gemfile, and then run `$ bundle install` to install the gem.

Then add these lines to the bottom of the configuration block at the top of `server.rb`:
`require 'ddtrace'
require 'ddtrace/contrib/sinatra/tracer'`

And place this underneath the Sinatra/Reloader configuration block:
```ruby
configure do
  settings.datadog_tracer.configure default_service: 'my-app', debug: true
end
```

Finally, `rackup`, navigate to localhost:9292 in your browser, and you should see the tracer reporting data sent in your terminal. (If you don't want this feedback in the terminal, simply change your configuration block's debug to `false`.

Your application's trace will be visibile through the [Datadog web app](https://app.datadoghq.com/apm).
![APM trace]()
