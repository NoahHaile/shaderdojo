window.SHADERDOJO_API = window.SHADERDOJO_API || {
    auth: `${location.origin}/auth`,
    app:  `${location.origin}/app`,
};

async function verifyToken() {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = redirectUrl;
        return false;
    }
    try {
        const response = await fetch(`${SHADERDOJO_API.app}/account/verify_account`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        if (!response.ok) {
            window.location.href = redirectUrl;
            return false;
        }
        return true;
    } catch (err) {
        setErrorModal("An error occurred while verifying your account. Your work might not be saved.");
        return false;
    }
}

async function verifyShaderOutput() {
    const isTokenValid = await verifyToken();
    if (!isTokenValid) return;

    const token = localStorage.getItem('token');
    try {
        const response = await fetch(`${SHADERDOJO_API.app}/lessons/verify`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                fragmentShader: buildFragmentShader(),
                vertexShader: vertexShaderSource,
                lessonId: id,
                time: 20
            }),
        });
        if (response.ok) {
            modalSuccess();
        } else if (response.status == 400) {
            modalFail();
        } else {
            setErrorModal("An error occurred while verifying the shader output. Please try again later.");
            closeModal();
        }
    } catch (err) {
        setErrorModal("An error occurred while verifying the shader output. Please try again later.");
        closeModal();
    } finally {
        updateProblemStatus();
    }
}

async function updateProblemStatus() {
    const statusText = document.querySelector(".status-text");
    const token = localStorage.getItem('token');
    if (!token) {
        if (statusText) statusText.innerHTML = "No Account";
        return;
    }
    const problemStatus = await fetch(`${SHADERDOJO_API.app}/account/status/${id}`, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`
        }
    }).then(response => {
        if (response.status != 200) {
            if (statusText) statusText.innerHTML = "Account not Valid";
        }
        return response.json();
    }).catch(err => {
        setErrorModal("An error occurred while fetching lesson attempts.");
        return {
            status: "UNDEFINED",
            count: -1
        };
    });

    if (!statusText) return;
    if (problemStatus.status == "UNATTEMPTED") {
        statusText.innerHTML = "Lesson Unattempted";
    } else if (problemStatus.status == "SUCCESSFUL") {
        statusText.innerHTML = "Lesson Completed. " + problemStatus.count + (problemStatus.count != 1 ? " attempts." : " attempt.");
    } else if (problemStatus.status == "FAILED") {
        statusText.innerHTML = "Lesson attempted " + problemStatus.count + (problemStatus.count != 1 ? " times." : " time");
    } else {
        statusText.innerHTML = "Failed to fetch.";
    }
}

updateProblemStatus();
