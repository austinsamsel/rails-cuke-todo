class TasksController < ApplicationController
before_action :find_task, only: [:edit, :update, :destroy]

  def home
	  @tasks= Task.all
	end

  def new
    @task = Task.new
  end

  def create
	  @task = Task.new(task_params)
	  if @task.save
	    redirect_to root_url
    else
      render :new
	  end
	end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to root_url
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to root_url
  end

	private
    def find_task
      @task = Task.find(params[:id])
    end

	  def task_params
	    params.require(:task).permit(:name, :completed)
	  end
end
