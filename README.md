# Getting Started with Cucumber on Rails

This is a "getting started" with Cucumber and BDD testing in rails. We're literally jumping straight into it. I'm assuming you've already read up on some testing concepts and you've found your way here in order to understand what a workflow with Cucumber might look like and how we think about problems along the way. If you like, you can grab the finished code from [GitHub](https://github.com/austinsamsel/rails-cuke-todo).

### Step 1 - Set up.

Create a new app

	$ rails new todos-tdd-cucumber --skip-test-unit

Add Cucumber to your Gemfile. We'll include database_cleaner, which comes highly recommended as per [cucumber docs](https://github.com/cucumber/cucumber-rails)

	group :test do
	  gem 'cucumber-rails', require: false
	  gem 'database_cleaner'
	end

	$ bundle install

Run cucumber installer.

	$ rails generate cucumber:install

This gives us a new directory called `features` which is where we'll write tests.

### Step 2 - Create first feature: Add a Task.

Create the feature. Using (Gherkin)[https://github.com/cucumber/cucumber/wiki/Gherkin] - an easy to read syntax that works as both documentation and as tests. Your clients can read it and you can write it together. Even if you're not working with a client (or a client that wants to read it), its still worthwhile to use it because it forces you to "think like the user" as you write your features. Rather than mapping out your database and building your models, you'll develop your features with an "outside in" approach, starting from the homepage, and working with what you would see in the browser.

	$ touch features/todos.feature

Your feature should express what you'd like to build and conclude with the business value behind it.

	#todos.feature

	Feature: Todos
	  In order to get things done
	  As a todo-list freak
	  I want to be able to create a list of tasks.

Great. Let's write our first scenario. Each scenario is composed of steps that begin with keywords like `Given` `And` `When` and finally `Then`.

	#todos.feature
	...

	Scenario: Create a task
	  Given I am on the home page
	  And I go to "Add new task"
	  When I fill in "Task Field" with "My first todo!"
	  And I press "Submit"
	  Then I should see "My first todo!"

Run cucumber for the first time as a rake task.

	$ rake cucumber

Copy and paste the console output into our step definitions file.

	$ touch features/step_definitions/todos.rb

<!-- -->

	#features/step_definitions/todos.rb

	Given(/^I am on the home page$/) do
	  pending # express the regexp above with the code you wish you had
	end

	Given(/^I go to "(.*?)"$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end

	When(/^I fill in "(.*?)" with "(.*?)"$/) do |arg1, arg2|
	  pending # express the regexp above with the code you wish you had
	end

	When(/^I press "(.*?)"$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^I should see "(.*?)"$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end

Whenever we want some feedback from cucumber, we'll run `$ rake cucumber`.  and we'll see that it tells us our first step is pending.

Fill out the first step definition with the following.

	#features/step_definitions/todos.rb

	Given(/^I am on the home page$/) do
	  visit "/"
	end
	...

This tells Cucumber we expect to be on the home page to start things off.

Cucumber tells us

	No route matches [GET] "/" (ActionController::RoutingError)

What we need is a route to our homepage. Even if we build a route, we know we'll need a view and a controller (plus an index) to get it started...

Let's add a route.

	# config/routes.rb
	...
	root 'tasks#index'
	...

Run cucumber again.

	uninitialized constant TasksController (ActionController::RoutingError)

Cucumber tells us we need a controller for our tasks. This is really TDD. Just taking one step, then another, letting the tests dictate each next step in development.

Let's create a controller.

	$ rails g controller Tasks home --no-helper --no-assets

This will also give us the view we need as well at `app/views/tasks/home.html.erb`

When we run cucumber again, our first step passes! Now our next step is pending. So let's write the code for that.

Now we need to write the code for our next feature. We want to go to a page to add a new task. So we'll need a link users can click. We'll update the argument so its human readable, the_link and reference it in the code.

	Given(/^I go to "(.*?)"$/) do |the_link|
	  click_link the_link
	end

Cucumber tells us:

	Unable to find link "Add new task" (Capybara::ElementNotFound)

Now we have a failing test. It's time to update our application code with a link to add a new task.

	#app/views/tasks/home.html.erb
	<%= link_to "Add new task", new_task_path %>

Cucumber tells us:

	undefined local variable or method `new_task_path' for #<#<Class:0x007fcc04b53060>:0x007fcc04b51dc8> (ActionView::Template::Error)

We don't have a route for new. So let's change our code in our routes to:

	config/routes.rb
	...
	root 'tasks#home'
	resources :tasks
	...

Cucumber tells us:

	The action 'new' could not be found for TasksController (AbstractController::ActionNotFound)

So we need to update our controller with a new action.

	#app/controllers/task_controller.rb
	class TasksController < ApplicationController
	  def new
	  end
	end

Cucumber tells us:

	Missing template tasks/new, application/new with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:

We need a view template for our new action.

	$ touch app/views/tasks/new.html.erb

Rake tells us this step passes!

Let's write the code for our next step.

	# features/step_definitions/todos.rb
	...
	When(/^I fill in "(.*?)" with "(.*?)"$/) do |input, value|
	  fill_in input, with: value
	end
	...

We updated the argument variables from `arg1, arg2` to `input, value` to be more readable.

When we run cucumber, we get:

	Unable to find field "Task Field" (Capybara::ElementNotFound)

Cucumber is looking for the form to add a new task. Let's create the form. First let's add Simple Form to our gemfile.

	#Gemfile
	...
	gem 'simple_form'
	...

	$ bundle install

	$ rails g simple_form:install

<!-- -->

	#app/views/tasks/home.html.erb
	<%= simple_form_for(@task) do |f| %>
	  <%= f.input :name %>
	  <%= f.button :submit, "Submit" %>
	<% end %>

Run Cucumber and we get:

	undefined method `model_name' for nil:NilClass (ActionView::Template::Error)

We need to update our controller action that will allow us to create a new task.

	#app/controllers/tasks_controller.rb
	...
	def new
	  @task = Task.new()
	end
	...

We need to create a model.

	$ rails g model Task name:string
	$ rake db:migrate

Then we get...

	Unable to find field "Task Field" (Capybara::ElementNotFound)

Capybara is having trouble finding the field for which we'd like to add in the name of our task. It's time to take a second look at our original step definition and enter a revision. If you run your rails server and inspect the source code, our rails form field looks like this: `<input class="string optional" type="text" name="task[name]" id="task_name" />` Cucumber is able to find the field by name or ID. So let's update our feature with the id as the form field identifier:

Our step definition passes.

Let's write the code for our third step definition.

	#features/step_definitions/todos.rb
	...
	When(/^I press "(.*?)"$/) do |the_button|
	  click_button the_button
	end
	...

Run cucumber and we get:

	The action 'create' could not be found for TasksController (AbstractController::ActionNotFound)

	We need a create action in our controller.

	#app/controllers/task_controller.erb
	...
	def create
	  @task = Task.new
	end
	...

Run Cucumber.

	Missing template tasks/create, application/create with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:

By default Rails is trying to take us to a new page... Since this is just a one page app, let's keep everything on the home page. And so our app is secure, I'm including in params at this time.

	#app/controllers/task_controller.erb
	...
	def create
	  @task = Task.new(task_params)
	  if @task.save
	    redirect_to root_url
	  end
	end

	private
	  def task_params
	    params.require(:task).permit(:name)
	  end
	...

Our step passes. Now we should verify that we can see our new task. Let's finish out the code for the fourth step. Where we test to make sure we can actually see the new task posted.

	#features/step_definitions/todos.rb
	...
	Then(/^I should see "(.*?)"$/) do |task|
	  assert page.has_content?(task)
	end
	...

Run Cucumber:

	Failed assertion, no message given. (Minitest::Assertion)

This isn't that informative. But considering we haven't done anything to actually list tasks, let's start with the view.

	#app/views/tasks/home.html.erb
	...
	<% for task in @tasks %>
	  <li><%= task.name %></li>
	<% end %>

Run Cucumber:

	undefined method `each' for nil:NilClass (ActionView::Template::Error)

We don't have anything in the controller to feed the view any data. So let's update that.

	#app/controllers/task_controller.rb
	...
	def home
	  @tasks= Task.all
	end
	...

Then all our tests pass.

### Step 3: Create a failing test

What happens when the user does something weird? Do we want users to create empty tasks? No. So let's test to make sure that invalid tasks are not posted.

Let's write a feature:

	#features/todos.feature
	...
	Scenario: Create an invalid task
	  Given I am on the home page
	  And I go to "Add new task"
	  When I fill in "task_name" with ""
	  And I press "Submit"
	  Then I should be told "Can't be blank"
	  And I fill in "Name" with "My first todo!"
	  And I press "Submit"
	  Then I should see "My first todo!"

There's some repetition here in the steps. We're only going to have to write one new step definition. The rest is repeat. The new step definition is `Then I should be told "Can't be blank"`

When we run Cucumber, it gives us our new step definition to implement. We'll copy and paste it into our todos.rb

	#features/step_definitions/todos.rb
	...
	# invalid post
	Then(/^I should be told "(.*?)"$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end

And let's update this step definition with our test code.

	#features/step_definitions/todos.rb
	...
	# invalid post
	Then(/^I should be told "(.*?)"$/) do |error_message|
	  assert page.has_content?(error_message)
	end

Cucumber tells us:

	Failed assertion, no message given. (Minitest::Assertion)

Not that informative. But we know we don't have any validations on our task model. So let's update that.

	#app/models/task.rb
	class Task < ActiveRecord::Base
	  validates :name, presence: true
	end

Cucumber tells us:

	Missing template tasks/create, application/create with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:

It looks like Rails is trying to reroute us. We want to stay on the same page and see the error. Let's update the controller action with a scenario detailing what happens when a task is not saved.

	#app/controllers/tasks_controller.rb
	...
	def create
	  @task = Task.new(task_params)
	  if @task.save
	    redirect_to root_url
      else
        render :new
	  end
	end
	...

Cucumber tells us:

	Failed assertion, no message given. (Minitest::Assertion)

We still aren't being told of the failure. If we run `rails s` and see what's going on when we submit a blank task, we're told "can't be blank". It is working! Cross referencing with our feature, we previously wrote, "Can't be blank". So we need to update our feature with the proper capitalization.

	#features/todos.feature
	...
	# old
	# Then I should be told "Can't be blank"
	Then I should be told "can't be blank"
	...

Now all our tests pass.

### Step 4: Completing Tasks

Let's write the scenario for marking a task as complete.

	Scenario: Mark a task as completed
	  Given I have the following tasks:
	    | name          | completed |
	    | My First Todo | false     |
	    | My 2nd Todo   | false     |
	  When I am on the home page
	  And I follow "Edit" associated with "My 1st Todo"
	  And I check the "Done" checkbox
	  And I press "Submit"
	  Then I should see "My 1st Todo" as completed.

You'll notice a new format here. We created some sample data within Cucumber that can run. It's a simple and fast way to start writing more complex tests.

We'll run cucumber and grab the output and paste it in our `step_definitons/todos.rb` file.

In order to work with the data in the fixtures, we'll modify our first step definition:

	Given(/^I have the following tasks:$/) do |table|
	  for hash in table.hashes
	    Task.create(hash)
	  end
	end

Then we're told:

	unknown attribute 'completed' for Task. (ActiveRecord::UnknownAttributeError)

We never created the a field for "completed" so let's add that now.

	$ rails g migration AddCompletedToTasks completed:boolean
	$ rake db:migrate

Our second step passes. Now we need to write another step definition:

	When(/^I follow "(.*?)" associated with "(.*?)"$/) do |arg1, arg2|
	  first('li').click_link('Edit')
	end

This will find the first "Edit" link on the page, which will be associated with our first todo. Capybara will tell us it can't find it:

	Unable to find link "Edit" (Capybara::ElementNotFound)

We'll add an edit link into our view.

	#app/views/tasks/home.html.erb
	...
	<% for task in @tasks %>
	  <li><%= task.name %> • <%= link_to 'Edit', edit_task_path(task) %></li>
	<% end %>

Then Cucumber tells us we don't have a controller action:

	The action 'edit' could not be found for TasksController (AbstractController::ActionNotFound)

We'll add the action to our tasks controller:

	#app/controllers/tasks_controller.rb

	def edit
	end


Now we're missing our view

	Missing template tasks/edit, application/edit with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:

We'll add it in. Again just doing the bare minimum at each step.

	$ touch app/views/tasks/edit.html.erb

Our step passes. We now need to write the code for the next step definition to test completing a task.

	When(/^I check the "(.*?)" checkbox$/) do |arg1|
	  page.find('input[type=checkbox]').set(true)
	end

Cucumber:

	Unable to find css "input[type=checkbox]" (Capybara::ElementNotFound)

All we have is a blank page. Its time to add in a form to edit the task on our edit page. It's the same form as on the new view, except with a new field to mark todos as completed.

	#app/views/tasks/edit.html.erb

	<%= simple_form_for(@task) do |f| %>
	  <%= f.input :name %>
	  <%= f.input :completed, as: :boolean, checked_value: true, unchecked_value: false %>
	  <%= f.button :submit, "Submit" %>
	<% end %>

We get:

	undefined method `model_name' for nil:NilClass (ActionView::Template::Error)

There's nothing in the controller to help rails find the task. So let's update the edit method:

	#app/controllers/task_controller.rb
	def edit
	  @task = Task.find(params[:id])
	end

Cucumber tells us:

	The action 'update' could not be found for TasksController (AbstractController::ActionNotFound)

Let's add an update action to our tasks controller.

	#app/controllers/task_controller.rb

	def update
	end

Cucumber says:

	Missing template tasks/update, application/update with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:

We don't want to create a view for update... so let's try updating the action to include some rerouting... After a successful update we want to go to the home page and if there's been an error, we want to stay on the edit page.

	#app/controllers/task_controller.rb

	def update
	  if @task.update
	    redirect_to root_url
	  else
	    render :edit
	  end
	end

One more problem, rails can't find the task we're trying to update... so let's copy over the same find code from the edit action...

	#app/controllers/task_controller.rb

	def update
	  @task = Task.find(params[:id])
	  if @task.update
	    redirect_to root_url
	  else
	    render :edit
	  end
	end

And now...

	wrong number of arguments (0 for 1) (ArgumentError)

We need to fix our strong parameters in our private task_params method.

	#app/controllers/task_controller.rb

	def task_params
	  params.require(:task).permit(:name, :completed)
	end

We also need to pass our params into the update method.

	#app/controllers/task_controller.rb

	def update
	  @task = Task.find(params[:id])
	  if @task.update(task_params)
	    redirect_to root_url
	  else
	    render :edit
	  end
	end

The step passes. Before we go on, let's refactor the code so we aren't repeating the same line of code in the edit and update methods in the controller. Remove the following line from the edit and update actions.

	@task = Task.find(params[:id])

Then create a new private method:

	#app/controllers/task_controller.rb

	def find_task
      @task = Task.find(params[:id])
    end

And at the top of our controller we'll call our new method with a before_action hook:

	#app/controllers/task_controller.rb

	before_action :find_task, only: [:edit, :update]

If we run cucumber again and see it still working, we were just able to "fearlessly" refactor.

Finally, let's finish this last step. We need to communicate to the user that the task is completed.

	Then(/^I should see "(.*?)" as completed\.$/) do |task|
	  assert first('li').parent.has_css?('.completed')
	end

This code checks if our list item has the css class `.completed`. The argument has_css? looks within the list item to its children, when we wanted to check the list item itself. So we used `.parent` to return the search to the list item element itself.

Let's update the home page view with some logic that determines if the task is marked as completed, and if it is, to add the class, "completed"

	#app/views/tasks/home.html.erb

	<li class="<%= task.completed == true ? "completed" : "" %>"><%= task.name %> • <%= link_to 'Edit', edit_task_path(task) %></li>

You may want to move this logic out into a helper method, but for now, this will adequately accomplish what we want.

Then let's add a new CSS file:

	$ touch app/assets/stylesheets/tasks.css

And add the code:

	#app/assets/stylesheets/tasks.css

	li.completed{
	  text-decoration: line-through;
	}

Then we can run cucumber and verify that all our tests are passing. It kind of sucks that we have a line running through even the edit and delete actions, but oh well - this isn't about being pretty, but just showing how this can all work.

### Step 5: Removing Tasks

When a user has completed a bunch of tasks, after a time, it makes sense to that our user may no longer want to view the tasks. So we need a way to delete tasks.

So let's write the following scenario:

	Scenario: Delete a task
	  Given I have the following tasks:
	    | name          | completed |
	    | My First Todo | false     |
	    | My 2nd Todo   | false     |
	  When I am on the home page
	  And I press "Delete" associated with "My First Todo"
	  Then I should no longer see "My First Todo"


Let's write our first step. We want to tell Cucumber to click the delete link:

	When(/^I click on the "(.*?)" next to "(.*?)"$/) do |arg1, arg2|
	  first('li').click_link('Delete')
	end

Cucumber tells us:

	Unable to find link "Delete" (Capybara::ElementNotFound)

Let's add a delete link to the Home page view.

	#app/views/tasks/new.html.erb

	<% for task in @tasks %>
	  <li class="<%# task.completed == true ? "completed" : "" %>">
	    <%= task.name %>
	    • <%= link_to 'Edit', edit_task_path(task) %>
	    • <%= link_to 'Delete', task, method: :delete, data: { confirm: 'Are you sure?' } %>
	  </li>
	<% end %>

Cucumber tells us:

	The action 'destroy' could not be found for TasksController (AbstractController::ActionNotFound)

Let's add the necessary controller action:

	#app/controllers/task_controller.rb

	def destroy
	end

Cucumber tells us:

	Missing template tasks/destroy, application/destroy with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:

Let's fill out the action with:

	#app/controllers/task_controller.rb

	def destroy
	  @task.destroy
	end

And also include the destroy action in the before_action hook:

	#app/controllers/task_controller.rb

	before_action :find_task, only: [:edit, :update, :destroy]

We keep getting the same message:

	 Missing template tasks/destroy, application/destroy with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:

So let's add a redirect

	#app/controllers/task_controller.rb

	def destroy
	  @task.destroy
	  redirect_to root_url
	end

Our step passes.

Let's write the last step here.

	Then(/^I should no longer see "(.*?)"$/) do |task|
	  !assert page.has_content?(task)
	end

This is similar to when we were first checking to see if the task would appear on the page when we created a new task. Here we want to test that it doesn't show. So I slightly modified the code with a bang, to assert the opposite.

Cucumber tells us:

	And I press "Delete" associated with "My First Todo"


Nice! We created a Todo app using Cucumber that allows us to create tasks, validates against invalid tasks, mark tasks as complete, and delete tasks. This this type of functionality is pretty common and can be applied in a lot of scenarios.

If you have any questions, or notice anything that can be improved, please let me know!
