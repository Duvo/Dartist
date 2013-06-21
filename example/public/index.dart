import 'dart:html';

main() {
  var button = query('#button');

  button.onClick.listen((MouseEvent event) {
    if (button.text == 'Again!') {
      button.text = 'Press me!';
      button.style.color = null;
    } else {
      button.text = 'Again!';
      button.style.color = 'red';
    }
  });
}