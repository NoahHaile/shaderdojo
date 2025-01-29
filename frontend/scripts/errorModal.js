const errorModal = document.getElementById('error-modal');
const errorModalMessage = document.getElementById('error-modal-message');

function errorModalSetup() {
    errorModal.addEventListener('click', () => {
        errorModal.style.display = 'none';
    });
}

function setErrorModal(message) {
    errorModalMessage.innerText = message;
    errorModal.style.display = 'block';
}

errorModalSetup();