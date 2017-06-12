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

**NOTE**: You may need to reload your terminal before accessing the sinatra_turntable script.

## Running The Generator

To run the generator, use the bash command `sinatra_turntable <your_apps_name>`.

**Example**:
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

**NOTE**: to list all rake commands, run `$ rake -T`.

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

If you want your database pre-populated, add that data to `db/seeds.rb`, and run `$ rake db:seed` to seed your database.

Now that we have a server and a database, let’s build an index view to make sure the two are communicating correctly.

## Enabling APM Tracing

Datadog's APM agent traces requests from request to response across your app. This metadata allows a top-level view of your app's health, and helps you understand how user requests effect your app's architecture.

To enable APM tracing, first ensure you have a [Datadog account](https://www.datadoghq.com/), and install the [Datadog Agent](https://app.datadoghq.com/account/settings#agent). 

Next, add `gem ddtrace` to your Gemfile, and run `$ bundle install` to install the gem.

In `server.rb`, add these lines under `require 'sinatra/reloader'`: 
`require 'ddtrace'
require 'ddtrace/contrib/sinatra/tracer'`

Include this block underneath `configure :development do` to customize the tracer's configuration:
```ruby
configure do
  settings.datadog_tracer.configure default_service: 'my-app', debug: true
end
```

Finally, `$ rackup`, navigate to localhost:9292 in your browser, and you should see the tracer reporting data in your terminal.

Your tracer's terminal output will provde immediate feedback on requests flowing across your app:
<img src="tracer_terminal_output.png" alt="Tracer Output in Terminal" style="max-width: 25%; height: auto"/>
(If you don't want this feedback, change `debug:true` to `false`.)



Your tracer gives you access to information such as:
  
  - Which templates are being rendered
  - Duration of rendering request 
  - HTTP request status codes

Your trace will be also visibile through the [Datadog web app](https://app.datadoghq.com/apm).
![APM trace]()
