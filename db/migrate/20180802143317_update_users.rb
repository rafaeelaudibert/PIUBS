# frozen_string_literal: true

class UpdateUsers < ActiveRecord::Migration[5.2]
  def self.up
    change_table :TB_USUARIO do |t|
      t.string :NO_NOME
      t.string :NO_SOBRENOME
      t.string :NU_CPF
      t.integer :TP_ROLE
      t.bigint :ST_SISTEMA
    end

    add_column :TB_USUARIO, :CO_CIDADE, :bigint
    add_column :TB_USUARIO, :CO_SEI, :bigint
    add_column :TB_USUARIO, :CO_CNES, :bigint

    execute <<-SQL
      ALTER TABLE "TB_USUARIO" ADD CONSTRAINT "FK_CIDADE_USUARIO" FOREIGN KEY ("CO_CIDADE")
        REFERENCES "TB_CIDADE" ("CO_CODIGO") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      ALTER TABLE "TB_USUARIO" ADD CONSTRAINT "FK_EMPRESA_USUARIO" FOREIGN KEY ("CO_SEI")
        REFERENCES "TB_EMPRESA" ("CO_SEI") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_USUARIO" ADD CONSTRAINT "FK_UBS_USUARIO" FOREIGN KEY ("CO_CNES")
        REFERENCES "TB_UBS" ("CO_CNES") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_USUARIO" DROP CONSTRAINT "FK_CIDADE_USUARIO";
      ALTER TABLE "TB_USUARIO" DROP CONSTRAINT "FK_EMPRESA_USUARIO";
      ALTER TABLE "TB_USUARIO" DROP CONSTRAINT "FK_UBS_USUARIO";
    SQL
    drop_table :TB_USUARIO
  end
end
