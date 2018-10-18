# frozen_string_literal: true

AnyLogin.setup do |config|
  config.limit = :none
  config.position = :bottom_right
  config.collection_method = :by_role
end
