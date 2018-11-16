# frozen_string_literal: true

json.array! @controversies, partial: 'controversies/controversy', as: :controversy
