every :sunday, at: '04am' do
  runner 'Attachment.all.select { |attach| attach.attachment_links.length == 0 }.each { |attach| attach.destroy! }',
          mailto: 'rbaudibert@inf.ufrgs.br'
end

every :day, at: '7:50 pm' do
  command "backup perform --trigger PIUBS_production"
end
