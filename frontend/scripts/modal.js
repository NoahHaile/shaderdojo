const modal = document.getElementById('modal');
const modalHeader = document.getElementById('result-status');
const modalStatus = document.getElementById('processing-status');
const modalButtonContainer = document.getElementById('modal-button-container');

function modalSetup() {
    modal.addEventListener('click', () => {
        modal.style.display = 'none';
    });
}

function modalProcessStart() {
    closeModal();
    modal.style.display = 'block';
    modalHeader.innerHTML = "Processing...";
    modalStatus.innerHTML = "Running Shader...";
}

function lessonBackUrl() {
    return 'courses.html';
}

function modalSuccess() {
    modal.style.display = 'block';
    modalHeader.innerText = "Solved";
    modalStatus.innerText = "Nice work. Head back to the course to pick the next lesson.";
    modalHeader.style.color = "var(--success)";
    modalButtonContainer.innerHTML =
        `<button class="button1" onclick="window.location.href='${lessonBackUrl()}'">Back to Course</button>` +
        `<button class="button2" onclick="modal.style.display = 'none'">Keep tweaking</button>`;
}

function modalFail() {
    modal.style.display = 'block';
    modalHeader.innerText = "Not quite";
    modalStatus.innerText = "Your output didn't match. Scroll down to see other learners' solutions in the discussion.";
    modalHeader.style.color = "var(--warning)";
    modalButtonContainer.innerHTML =
        `<button class="button1" onclick="modal.style.display = 'none'">Keep going</button>`;
}

function closeModal() {
    modal.style.display = 'none';
    modalButtonContainer.innerHTML = '';
}

function setModalMessage(message) {
    modal.style.display = 'block';
    modalStatus.innerText = message;
}

modalSetup();
