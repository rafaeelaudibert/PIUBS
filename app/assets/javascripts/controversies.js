  
  (function($) {
  /**
  * validate reply form
  */
 $("#replyForm").submit(function(){
    tinyMCE.triggerSave();
  });
  $.validator.setDefaults({
      ignore: ":hidden:not('textarea')"
  });
  var validator = $('#replyForm').validate({
      rules: {
          "reply[description]": {
              required: true
          }
      },
      messages :{
          "reply[description]" : {
              required : 'O campo Descrição é obrigatório.'
          }
      }
  });
});
