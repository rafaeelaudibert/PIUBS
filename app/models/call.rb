class Call < ApplicationRecord
  belongs_to :city
  belongs_to :category
  belongs_to :state
  belongs_to :user
  belongs_to :company, class_name: 'Company', foreign_key: :sei
  belongs_to :answer, optional: true
  belongs_to :unity, class_name: 'Unity', foreign_key: :cnes
  validates :protocol, presence: true, uniqueness: true
  has_many :replies, class_name: 'Reply', foreign_key: :protocol
  has_many :attachment_links
  has_many :attachments, through: :attachment_links

  ### SE ADICIONAR NOVO OU ALTERAR STATUS OU SEVERIDADE, LEMBRAR DE
  ### ADICIONAR TAMBÉM NA TRADUÇÃO (config/locales/en.yml)
  enum status: [:open, :closed, :reopened]
  enum severity: [:low, :normal, :high, :huge]

  filterrific(
   default_filter_params: { filtered_by: 'status_any'},
   available_filters: [
     :filtered_by,
     :with_ubs,
     :with_company,
     :with_state,
     :with_city
   ]
 )

  scope :filtered_by, lambda { |filter_key|
    filter = (filter_key =~ /open$/) ? 'open' : (filter_key =~ /reopened$/) ? 'reopened' : (filter_key =~ /closed$/) ? 'closed' : 'any'
    @status_i = (filter == 'open') ? 0 : (filter == 'reopened') ? 2 : (filter == 'closed') ? 1 : 4
    puts @status_i
    case filter_key.to_s
    when /^status_/
        if(@status_i != 4)
            where(status: @status_i)
        end
    else
      raise(ArgumentError, "Invalid filter option")
    end
  }

  scope :with_ubs, lambda { |cnes|
    return nil if cnes == [""]
      if cnes != [""]
        where(cnes: cnes)
      end
  }

  scope :with_company, lambda { |sei|
    return nil if sei == [""]
      if sei != [""]
        where(sei: sei)
      end
  }

  scope :with_state, lambda { |state|
    return [] if state == [""]
      if state != [""]
        where(state_id: state)
      end
  }

  scope :with_city, lambda { |city|
    unless (city == 0)
      where(city_id: city)
    end
  }

  def self.options_for_filtered_by()
    [
      ['Status', 'status_any'],
      ['Abertos', 'status_open'],
      ['Fechados', 'status_closed'],
      ['Reabertos', 'status_reopened'],
    ]
  end

  def self.options_for_with_city()
    [
      ['Cidade', 0],
    ]
  end

  # def self.options_for_filtered_by_ubs()
  #   [
  #     ['SEI_19', 'sei19'],
  #     ['SEI_11', 'sei11'],
  #   ]
  # end



end
