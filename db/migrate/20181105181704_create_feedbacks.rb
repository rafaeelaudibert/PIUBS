class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_FEEDBACK, id: false do |t|
      t.bigint :CO_SEQ_ID, null: false
      t.text :DS_DESCRICAO, null: false
      t.bigint :CO_CONTROVERSIA, null: false
      t.datetime :DT_CRIADO_EM
    end

    add_foreign_key :TB_FEEDBACK, :TB_CONTROVERSIA, column: :CO_CONTROVERSIA, primary_key: :CO_PROTOCOLO

    execute <<-SQL
      CREATE SEQUENCE "SQ_FEEDBACK_ID";
      ALTER TABLE "TB_FEEDBACK" ADD CONSTRAINT "PK_TB_FEEDBACK" PRIMARY KEY ("CO_SEQ_ID");
      ALTER TABLE "TB_FEEDBACK" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_FEEDBACK_ID"');
      -- ALTER SEQUENCE TB_CATEGORIA_CO_SEQ_ID_SEQ OWNED BY NONE;
      ALTER SEQUENCE "SQ_FEEDBACK_ID" OWNED BY "TB_FEEDBACK"."CO_SEQ_ID";
    SQL
  end

  def self.down
    execute 'ALTER TABLE "TB_FEEDBACK" DROP CONSTRAINT "PK_TB_FEEDBACK";'
    drop_table :TB_FEEDBACK
  end
end
