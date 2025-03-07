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

function modalSuccess() {
    modal.style.display = 'block';
    modalHeader.innerText = "Success!";
    modalStatus.innerText = "Head to the next problem.";
    modalHeader.style.color = "#267E31";
    modalButtonContainer.innerHTML = `<button class="button1" onclick="window.location.href='${pageNumber + 1}.html'">Next Problem</button><button class="button2" onclick="window.location.href='../problems.html'">Back to List</button>`;
}

function modalFail() {
    modal.style.display = 'block';
    modalHeader.innerText = "Try Again!";
    modalStatus.innerText = "Your solution wasn't quite there. Feel free to check the discussion page if you are starting to feel frustrated.";
    modalButtonContainer.innerHTML = `<button class="button1" onclick="modal.style.display = 'none'">Keep Grinding</button><button class="button2" onclick="window.location.href='../solutions/${pageNumber}.html'">Check Solution</button>`;
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



