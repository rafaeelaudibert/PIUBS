// Show or hide form to create new call
$("#create_call").click(function(){
  var id = 'create_call';
  var checked = $("#create_call:checked").length;
  if (checked) {
    $(".hidden").show(300);
    $(".search").hide();
  }
  else {
    $(".hidden").hide();
    $(".search").show(300);
  }
});
