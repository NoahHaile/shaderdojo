var editor = ace.edit("editor");
editor.setTheme("ace/theme/monokai");
editor.session.setMode("ace/mode/glsl");

// Initialize the editor with the fragment shader source
editor.setValue(fragmentShaderSourceBody);
editor.clearSelection();

// Load saved code from local storage (if any)
const savedCode = localStorage.getItem('savedShaderCode/' + pageUrl);
if (savedCode) {
    editor.setValue(savedCode);
    editor.clearSelection();
}

const codeResetButton = document.getElementById('codeResetButton');

codeResetButton.addEventListener('click', () => {
    editor.setValue(fragmentShaderSourceBody);
    editor.clearSelection();
    runNewShader();
});

// Save the code to local storage every time it changes
editor.session.on('change', () => {
    localStorage.setItem('savedShaderCode/' + pageUrl, editor.getValue());
});
