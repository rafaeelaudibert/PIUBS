# TODO: Check why :protocol return a different number than
# the path requires

json.extract! @call, :protocol, :title, :description, :status,
              :version, :access_profile, :feature_detail,
              :city_id, :category_id, :state_id, :sei,
              :cnes, :severity, :user_id,
              :support_user_id
