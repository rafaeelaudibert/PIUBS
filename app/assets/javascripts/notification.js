Notification = window.Notification || {};
Notification = function() {
  let number = 0;
  let incPosition = 0;

  const template = function(title, text, image, position) {
    incPosition = number * 120;
    number++;

    const textHtml = '<div class="text">' + text + '</div>';
    const titleHtml = (!title ? '' : '<div class="title">' + title + '</div>');
    const imageHtml = (!image ? '' : '<div class="illustration"><img src="' + image + '" width="70" height="70" /></div>');
    let style;

    switch (parseInt(position, 10)) {
      case 1:
        style = `top: ${incPosition}px; left:20px;`
        break;
      case 2:
        style = `top: ${incPosition}px; right:20px;`
        break;
      case 3:
        style = `bottom: ${incPosition}px; right:20px;`
        break;
      case 4:
        style = `bottom: ${incPosition}px; left:20px;`
        break;
      default:
        break;
    }
    return {
      id: number,
      content: `<div class='notification notification-${number}' style='${style}'><div class='dismiss' onclick="this.parentNode.classList += ' fadeOutUpBig'">&#10006;</div>${imageHtml}<div class="text">${titleHtml}${textHtml}</div></div>`
    };
  };

  const hide = function(id, animation_out) {

    const notification = $(document)
      .find('.notification-' + id);

    notification.addClass(animation_out);
    setTimeout(() => {
      notification.remove();
      number--;
    }, 1000);
  };

  const create = function(title, text, image, animation, position, delay) {
    const notification = template(title, text, image, position);

    $(notification.content)
      .addClass('animated ' + animation.in)
      .appendTo('body');

    setTimeout(() => hide(notification.id, animation.out || ''), (delay || 2) * 1000);
  };

  return {
    create: create
  };

}();