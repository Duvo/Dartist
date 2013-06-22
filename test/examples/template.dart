String template(Map<String, dynamic> context) {
  String html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${context['title']}</title>
</head>
<body>
  <h1>${context['title']}</h1>
  <ul>
''';
  for (var option in context['options']) {
    html += '''
  <li>$option</li>
''';
  }
  html +='''
  </ul>
</body>
</html>
''';
  return html;
}