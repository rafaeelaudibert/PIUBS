class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_FEEDBACK, id: false do |t|
      t.bigint :CO_PROTOCOLO, null: false
      t.text :DS_DESCRICAO, null: false
      t.datetime :DT_CRIADO_EM
    end

    execute 'ALTER TABLE "TB_FEEDBACK" ADD CONSTRAINT "PK_TB_FEEDBACK" PRIMARY KEY ("CO_PROTOCOLO");'

    add_foreign_key :TB_FEEDBACK, :TB_CONTROVERSIA, column: :CO_PROTOCOLO, primary_key: :CO_PROTOCOLO
  end

  def self.down
    execute 'ALTER TABLE "TB_FEEDBACK" DROP CONSTRAINT "PK_TB_FEEDBACK";'
    drop_table :TB_FEEDBACK
  end
end
