$(document).ready(function() {

  /**
  * validate FAQ form
  */
  $("#faqForm").submit(function(){
    tinyMCE.triggerSave();
  });
  jQuery.validator.setDefaults({
      ignore: ":hidden:not('textarea, input, select')"
  });

  var validator = $('#faqForm').validate({
      rules: {
          "answer[keywords]": {
              required: true
          },
          "answer[answer]": {
            required: true
          },
          "answer[category_id]": {
            required: true
          }
      },
      messages :{
          "answer[keywords]" : {
              required : 'O campo Palavras-chave é obrigatório.'
          },
          "answer[answer]": {
            required: 'O campo Resposta é obrigatório.'
          },
          "answer[question]": {
            required: 'O campo Questão é obrigatório.'
          },
          "answer[category_id]": {
            required: 'O campo Categoria é obrigatório.'
          }
      }
  });

});
