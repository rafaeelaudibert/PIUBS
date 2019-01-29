class CreateControversies < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CONTROVERSIA, id: false do |t|
      t.bigint :CO_PROTOCOLO, null: false
      t.string :DS_TITULO, null: false
      t.string :DS_DESCRICAO, null: false
      t.integer :TP_STATUS, null: false, default: 0
      t.bigint :CO_SEI, null: false
      t.bigint :CO_CIDADE, null: false
      t.bigint :CO_CNES
      t.bigint :CO_USUARIO_EMPRESA
      t.bigint :CO_USUARIO_UNIDADE
      t.bigint :CO_USUARIO_CIDADE
      t.bigint :CO_CRIADO_POR, null: false
      t.bigint :CO_CATEGORIA, null: false
      t.integer :NU_COMPLEXIDADE, null: false, default: 1
      t.bigint :CO_SUPORTE
      t.bigint :CO_SUPORTE_ADICIONAL
      t.datetime :DT_CRIADO_EM
      t.datetime :DT_FINALIZADO_EM
    end

    execute <<-SQL
      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "PK_TB_CONTROVERSIA" PRIMARY KEY ("CO_PROTOCOLO");

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_CATEGORIA_CONTROVERSIA" FOREIGN KEY ("CO_CATEGORIA")
        REFERENCES "TB_CATEGORIA" ("CO_SEQ_ID") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_UBS_CONTROVERSIA" FOREIGN KEY ("CO_CNES")
        REFERENCES "TB_UBS" ("CO_CNES") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_USUARIO_CONTROVERSIA_SUPORTE" FOREIGN KEY ("CO_SUPORTE")
        REFERENCES "TB_USUARIO" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_USUARIO_CONTROVERSIA_USUARIO_CIDADE" FOREIGN KEY ("CO_USUARIO_CIDADE")
        REFERENCES "TB_USUARIO" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_USUARIO_CONTROVERSIA_SUPORTE_ADICIONAL" FOREIGN KEY ("CO_SUPORTE_ADICIONAL")
        REFERENCES "TB_USUARIO" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_USUARIO_CONTROVERSIA_USUARIO_UNIDADE" FOREIGN KEY ("CO_USUARIO_UNIDADE")
        REFERENCES "TB_USUARIO" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_USUARIO_CONTROVERSIA_USUARIO_EMPRESA" FOREIGN KEY ("CO_USUARIO_EMPRESA")
        REFERENCES "TB_USUARIO" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_CIDADE_CONTROVERSIA" FOREIGN KEY ("CO_CIDADE")
        REFERENCES "TB_CIDADE" ("CO_CODIGO") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "FK_EMPRESA_CONTROVERSIA" FOREIGN KEY ("CO_SEI")
        REFERENCES "TB_EMPRESA" ("CO_SEI") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "PK_TB_CONTROVERSIA";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_CATEGORIA_CONTROVERSIA";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_UBS_CONTROVERSIA";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_USUARIO_CONTROVERSIA_SUPORTE";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_USUARIO_CONTROVERSIA_USUARIO_CIDADE";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_USUARIO_CONTROVERSIA_SUPORTE_ADICIONAL";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_USUARIO_CONTROVERSIA_USUARIO_UNIDADE";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_USUARIO_CONTROVERSIA_USUARIO_EMPRESA";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_CIDADE_CONTROVERSIA";
      ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "FK_EMPRESA_CONTROVERSIA";
    SQL
    drop_table :TB_CONTROVERSIA
  end
end
