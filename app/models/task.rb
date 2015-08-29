class Task < ActiveRecord::Base
  validates :name, presence: true

  def is_completed
    if self.completed == true
      return 'completed'
    end
  end

end
