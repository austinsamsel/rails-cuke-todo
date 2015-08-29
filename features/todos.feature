Feature: Todos
  In order to get things done
  As a todo-list freak
  I want to be able to create a list of tasks.

  Scenario: Create a task
    Given I am on the home page
    And I go to "Add new task"
    When I fill in "task_name" with "My first todo!"
    And I press "Submit"
    Then I should see "My first todo!"

  Scenario: Create an invalid task
	  Given I am on the home page
    And I go to "Add new task"
	  When I fill in "task_name" with ""
	  And I press "Submit"
	  Then I should be told "can't be blank"
	  And I fill in "Name" with "My first todo!"
	  And I press "Submit"
	  Then I should see "My first todo!"

  Scenario: Mark a task as completed
	  Given I have the following tasks:
	    | name          | completed |
	    | My First Todo | false     |
	    | My 2nd Todo   | false     |
	  When I am on the home page
	  And I follow "Edit" associated with "My First Todo"
	  And I check the "Done" checkbox
	  And I press "Submit"
	  Then I should see "My First Todo" as completed.

  Scenario: Delete a task
    Given I have the following tasks:
      | name          | completed |
      | My First Todo | false     |
      | My 2nd Todo   | false     |
    When I am on the home page
    And I click on the "Delete" next to "My First Todo"
    Then I should no longer see "My First Todo"
