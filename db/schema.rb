# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_14_171444) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"

  create_table "RT_LINK_ANEXO", id: false, force: :cascade do |t|
    t.uuid "CO_ID", default: -> { "uuid_generate_v4()" }, null: false
    t.uuid "CO_ANEXO", null: false
    t.integer "CO_RESPOSTA"
    t.integer "CO_ATENDIMENTO"
    t.integer "CO_QUESTAO"
    t.integer "TP_ENTIDADE_ORIGEM", null: false
    t.datetime "DT_CRIADO_EM"
    t.bigint "CO_CONTROVERSIA"
    t.integer "CO_FEEDBACK"
  end

  create_table "TB_ANEXO", primary_key: "CO_ID", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "NO_NOME_ANEXO", null: false
    t.string "DS_TIPO_ANEXO", null: false
    t.binary "BL_CONTEUDO", null: false
    t.datetime "DT_CRIADO_EM", null: false
  end

  create_table "TB_ATENDIMENTO", primary_key: "CO_PROTOCOLO", id: :bigint, default: nil, force: :cascade do |t|
    t.string "DS_TITULO", null: false
    t.text "DS_DESCRICAO", null: false
    t.integer "TP_STATUS", default: 0, null: false
    t.string "DS_VERSAO_SISTEMA"
    t.string "DS_PERFIL_ACESSO"
    t.string "DS_DETALHE_FUNCIONALIDADE"
    t.string "DS_SUMARIO_RESPOSTA"
    t.integer "CO_CIDADE", null: false
    t.integer "CO_CATEGORIA", null: false
    t.integer "CO_UF", null: false
    t.integer "CO_SEI"
    t.datetime "DT_CRIADO_EM"
    t.integer "CO_USUARIO_EMPRESA", null: false
    t.integer "CO_RESPOSTA"
    t.integer "CO_CNES"
    t.integer "CO_USUARIO_SUPORTE"
    t.integer "NU_SEVERIDADE", default: 1
    t.datetime "DT_FINALIZADO_EM"
    t.datetime "DT_REABERTO_EM"
  end

  create_table "TB_CATEGORIA", primary_key: "CO_SEQ_ID", id: :integer, default: -> { "nextval('\"SQ_CATEGORIA_ID\"'::regclass)" }, force: :cascade do |t|
    t.string "NO_NOME", null: false
    t.integer "CO_CATEGORIA_PAI"
    t.integer "NU_PROFUNDIDADE", default: 0
    t.integer "NU_SEVERIDADE", null: false
    t.integer "CO_SISTEMA_ORIGEM", null: false
  end

  create_table "TB_CIDADE", primary_key: "CO_CODIGO", id: :integer, default: nil, force: :cascade do |t|
    t.string "NO_NOME", null: false
    t.integer "CO_UF", null: false
  end

  create_table "TB_CONTRATO", primary_key: "CO_CODIGO", id: :integer, default: nil, force: :cascade do |t|
    t.integer "CO_CIDADE", null: false
    t.integer "CO_SEI", null: false
    t.string "NO_NOME_ARQUIVO", null: false
    t.string "DS_TIPO_ARQUIVO", null: false
    t.binary "BL_CONTEUDO", null: false
    t.datetime "DT_CRIADO_EM"
  end

  create_table "TB_CONTROVERSIA", primary_key: "CO_PROTOCOLO", id: :bigint, default: nil, force: :cascade do |t|
    t.string "DS_TITULO", null: false
    t.string "DS_DESCRICAO", null: false
    t.integer "TP_STATUS", default: 0, null: false
    t.integer "CO_SEI"
    t.integer "CO_CIDADE"
    t.integer "CO_CNES"
    t.integer "CO_USUARIO_EMPRESA"
    t.integer "CO_USUARIO_UNIDADE"
    t.integer "CO_USUARIO_CIDADE"
    t.integer "CO_CRIADO_POR"
    t.integer "CO_CATEGORIA", null: false
    t.integer "NU_COMPLEXIDADE", default: 1, null: false
    t.integer "CO_SUPORTE"
    t.integer "CO_SUPORTE_ADICIONAL"
    t.datetime "DT_CRIADO_EM"
    t.datetime "DT_FINALIZADO_EM"
  end

  create_table "TB_EMPRESA", primary_key: "CO_SEI", id: :integer, default: nil, force: :cascade do |t|
    t.datetime "DT_CRIADO_EM"
  end

  create_table "TB_FEEDBACK", primary_key: "CO_SEQ_ID", id: :bigint, default: -> { "nextval('\"SQ_FEEDBACK_ID\"'::regclass)" }, force: :cascade do |t|
    t.text "DS_DESCRICAO", null: false
    t.bigint "CO_CONTROVERSIA", null: false
    t.datetime "DT_CRIADO_EM"
  end

  create_table "TB_UBS", primary_key: "CO_CNES", id: :integer, default: nil, force: :cascade do |t|
    t.string "NO_NOME", null: false
    t.integer "CO_CIDADE", null: false
    t.string "DS_ENDERECO"
    t.string "DS_BAIRRO"
    t.string "DS_TELEFONE"
  end

  create_table "TB_UF", primary_key: "CO_CODIGO", id: :integer, default: nil, force: :cascade do |t|
    t.string "NO_NOME", null: false
    t.string "SG_SIGLA", limit: 2, null: false
  end

  create_table "answers", force: :cascade do |t|
    t.text "question"
    t.text "answer"
    t.bigint "user_id"
    t.integer "CO_CATEGORIA"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "faq", default: false
    t.string "keywords"
    t.integer "source"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.text "description"
    t.integer "status"
    t.integer "category"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "faq", default: false
    t.string "repliable_type"
    t.bigint "repliable_id"
    t.datetime "last_call_ref_reply_closed_at"
    t.datetime "last_call_ref_reply_reopened_at"
    t.index ["repliable_type", "repliable_id"], name: "index_replies_on_repliable_type_and_repliable_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "role"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "CO_SEI"
    t.string "cpf"
    t.integer "CO_CIDADE"
    t.integer "CO_CNES"
    t.string "last_name"
    t.integer "system"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "RT_LINK_ANEXO", "\"TB_ANEXO\"", column: "CO_ANEXO", primary_key: "CO_ID"
  add_foreign_key "RT_LINK_ANEXO", "\"TB_ATENDIMENTO\"", column: "CO_ATENDIMENTO", primary_key: "CO_PROTOCOLO"
  add_foreign_key "RT_LINK_ANEXO", "\"TB_CONTROVERSIA\"", column: "CO_CONTROVERSIA", primary_key: "CO_PROTOCOLO"
  add_foreign_key "RT_LINK_ANEXO", "\"TB_FEEDBACK\"", column: "CO_FEEDBACK", primary_key: "CO_SEQ_ID"
  add_foreign_key "RT_LINK_ANEXO", "answers", column: "CO_QUESTAO"
  add_foreign_key "RT_LINK_ANEXO", "replies", column: "CO_RESPOSTA"
  add_foreign_key "TB_ATENDIMENTO", "\"TB_CATEGORIA\"", column: "CO_CATEGORIA", primary_key: "CO_SEQ_ID"
  add_foreign_key "TB_ATENDIMENTO", "\"TB_CIDADE\"", column: "CO_CIDADE", primary_key: "CO_CODIGO"
  add_foreign_key "TB_ATENDIMENTO", "\"TB_EMPRESA\"", column: "CO_SEI", primary_key: "CO_SEI"
  add_foreign_key "TB_ATENDIMENTO", "\"TB_UBS\"", column: "CO_CNES", primary_key: "CO_CNES"
  add_foreign_key "TB_ATENDIMENTO", "\"TB_UF\"", column: "CO_UF", primary_key: "CO_CODIGO"
  add_foreign_key "TB_ATENDIMENTO", "answers", column: "CO_RESPOSTA"
  add_foreign_key "TB_ATENDIMENTO", "users", column: "CO_USUARIO_EMPRESA"
  add_foreign_key "TB_ATENDIMENTO", "users", column: "CO_USUARIO_SUPORTE"
  add_foreign_key "TB_CATEGORIA", "\"TB_CATEGORIA\"", column: "CO_CATEGORIA_PAI", primary_key: "CO_SEQ_ID"
  add_foreign_key "TB_CIDADE", "\"TB_UF\"", column: "CO_UF", primary_key: "CO_CODIGO"
  add_foreign_key "TB_CONTRATO", "\"TB_CIDADE\"", column: "CO_CIDADE", primary_key: "CO_CODIGO"
  add_foreign_key "TB_CONTRATO", "\"TB_EMPRESA\"", column: "CO_SEI", primary_key: "CO_SEI"
  add_foreign_key "TB_CONTROVERSIA", "\"TB_CATEGORIA\"", column: "CO_CATEGORIA", primary_key: "CO_SEQ_ID"
  add_foreign_key "TB_CONTROVERSIA", "\"TB_CIDADE\"", column: "CO_CIDADE", primary_key: "CO_CODIGO"
  add_foreign_key "TB_CONTROVERSIA", "\"TB_EMPRESA\"", column: "CO_SEI", primary_key: "CO_SEI"
  add_foreign_key "TB_CONTROVERSIA", "\"TB_UBS\"", column: "CO_CNES", primary_key: "CO_CNES"
  add_foreign_key "TB_CONTROVERSIA", "users", column: "CO_SUPORTE"
  add_foreign_key "TB_CONTROVERSIA", "users", column: "CO_SUPORTE_ADICIONAL"
  add_foreign_key "TB_CONTROVERSIA", "users", column: "CO_USUARIO_CIDADE"
  add_foreign_key "TB_CONTROVERSIA", "users", column: "CO_USUARIO_EMPRESA"
  add_foreign_key "TB_CONTROVERSIA", "users", column: "CO_USUARIO_UNIDADE"
  add_foreign_key "TB_FEEDBACK", "\"TB_CONTROVERSIA\"", column: "CO_CONTROVERSIA", primary_key: "CO_PROTOCOLO"
  add_foreign_key "TB_UBS", "\"TB_CIDADE\"", column: "CO_CIDADE", primary_key: "CO_CODIGO"
  add_foreign_key "answers", "\"TB_CATEGORIA\"", column: "CO_CATEGORIA", primary_key: "CO_SEQ_ID"
  add_foreign_key "answers", "users"
  add_foreign_key "replies", "users"
  add_foreign_key "users", "\"TB_CIDADE\"", column: "CO_CIDADE", primary_key: "CO_CODIGO"
  add_foreign_key "users", "\"TB_EMPRESA\"", column: "CO_SEI", primary_key: "CO_SEI"
  add_foreign_key "users", "\"TB_UBS\"", column: "CO_CNES", primary_key: "CO_CNES"
end
