# frozen_string_literal: true

json.extract! @user, :id, :name, :last_name, :fullname, :cpf, :email, :role, :city_id,
              :sei, :cnes, :last_sign_in_at
