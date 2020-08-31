require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'create' do
    post = create(:post)
    assert post.persisted?
  end
end
