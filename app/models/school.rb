class School < ApplicationRecord
  belongs_to :state #, optional: true

  def pr_url
    "https://www.princetonreview.com/schools/#{self.pr_id}/college/#{pr_code}"
  end
end
