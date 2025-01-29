var editor = ace.edit("editor");
editor.setTheme("ace/theme/monokai");
editor.session.setMode("ace/mode/glsl");

editor.setValue(fragmentShaderSourceBody);
editor.clearSelection();