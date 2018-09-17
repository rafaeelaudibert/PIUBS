module CallsHelper
  def parseStatus(status)
    options = ['Aberto', 'Em Andamento', 'Fechado']
    options[status]
  end
end
