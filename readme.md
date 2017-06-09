# Monitoring Sinatra Turntable with Datadog APM

*Sinatra Turntable* is a framework that allows you to spin up a full-stack web app in just a few minutes, which can then seamlessly be integrated into Datadog’s APM service for performance monitoring.

APM allows you to trace requests and template rendering across your Sinatra app, so you can have a fuller picture of its health.

## Sinatra Turntable

Sinatra Turntable is a full model-view-controller (MVC) framework with two principal components:

- A **Sinatra** web server.
- A PostgreSQL database with an **ActiveRecord** wrapper.


Sinatra is a minimalist, web server written in Ruby that receives and inteprets HTTP requests, and renders HTML template views in response.

ActiveRecord is a Ruby gem that allows us to interface with our database in Ruby, rather than having to write in SQL, so you only need one language to work across your stack.

With just a few commands, we can bootstrap a full web app with data-persistence.

## Installing Sinatra Turntable

To install the Sinatra Turntable app generator, use the text editor of your choice to open your bash  profile (typically located in `~/.bash_profile`), and [add this snippet](https://gist.github.com/schmartmann/7384d6e8a73657152778dc4d0936f28b).

  *NOTE*: You may need to reload your terminal before accessing the sinatra_turntable script.

## Running The Generator

To run the generator, use the bash command `sinatra_turntable`, which takes one parameter: your app’s name.

Example:
`$ sinatra_turntable mans_best_friends`

The generator will create a directory structure, and populate it with the files needed to run your app.

Before completing, the generator will prompt you:`Would you like to set up ActiveRecord for this project? (y/n)`. If you don’t want ActiveRecord integration, simply reply `n`, and the generator will exit, leaving you with just a Sinatra app, and won’t attempt to configure a database. Otherwise, reply `y`, and the generator will create the directories and files needed to integrate a PostgreSQL database with your app.

This will result in the following structure:

![Sinatra Turntable Directory Structure](tree.png =100x)

Once the generator finishes, test your app by running `$ rackup`. You should see the familiar Hello World! on `localhost:9292`.

## Setting Up Your Database

Once created, we need to do some configure at least one table in our database. This process has four steps.

### Step 1: Creating the Database

Our database hasn’t actually been created yet — we just configuration files that tell our app where to look for it.

To create our PostgreSQL database, run `$ rake db:create`.

NOTE: for a list of all rake commands, run `rake -T` in your command line.

### Step 2: Creating a Model File

ActiveRecord needs a model file to interact with your tables in your database. A model simply defines how to interact with a collection of data, and groups together common methods. In our case, the model is a Ruby class. Its use here is identical to its use in a Ruby on Rails app.  

A directory for your model files already exists, so all you need to do is create a Ruby file in that directory whose file name corresponds to the singular form of your database’s table’s name. For our example, we will create a `dog.rb` inside the `models/` directory, since we’d like to have a `dogs` table in our database.

>>>SCREENSHOT?>>>
models/dog.rb
```ruby
class Dog < ActiveRecord::Base
end
```
### Step 3: Creating a Migration File

Next, we will create a migration file that adds our table to the database.

Run `$ rake db:create_migration NAME=<snake_cased_name_of_your_migration>` and rake will automatically generate a migration file in `db/migrate`.

In our example, that command would look something like this:
`rake db:create_migration NAME=create_dogs_table`

This generates a date-stamped migration file, within which you can define your table’s attributes.

Our example migration file looks like this:
`db/migrate/20170608222332_add_dogs_table.rb`:
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

                                    Running `$ rake db:migrate` is the final step in setting up your database, and runs the migration file to make any additions or alternations to your database’s tables. Notice there is now a `schema.rb` file, that describes your tables, and lists the date of the most recent migration.

                                    In our example, our migration file creates a `dogs` table, and our `models/dog.rb` file allows us to access it via the `Dog` object in our Sinatra app.

                                    If you want to have data pre-populated in your database, just add that data to `db/seeds.rb`, and run `rake db:seed` to seed your database.

## Building A View

Now that we have a server and a database, let’s build an index view to make sure the two are communicating correctly.

`Server.rb` controls how your server responds to HTTP requests, and is where your routes live.

You should see a function block that describes your application’s root `/`:

`server.rb`:
```ruby
get “/“ do
  erb :index
  end
  ```

  Instead of   

## Enabling APM Tracing

Datadog exercise:

require 'ddtrace'
require 'ddtrace/contrib/sinatra/tracer'

^^— belong in the `Rakefile`, rather than inside of `server.rb`

place this:
```configure do
  settings.datadog_tracer.configure default_service: 'my-app', debug: true
  end
  ```
  inside of Rakefile as well.
