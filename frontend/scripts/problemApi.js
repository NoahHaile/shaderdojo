async function verifyShaderOutput(finalRes) {
    const res = await fetch(`https://shaderdojo.tech/app/problems/verify`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ hash: finalRes, problemId: id }),
    }).then(response => {
        if (response.status === 200) {
            modalSuccess();
        } else {
            modalFail();
        }
        updateProblemStatus()
    }).catch(err => {
        setErrorModal("An error occurred while verifying the shader output. Please try again later.");
        closeModal();
        updateProblemStatus();
    });
}

async function updateProblemStatus() {
    const problemStatus = await fetch(`https://shaderdojo.tech/app/account/status/${id}`, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`
        }
    }).then(response => {
        if (response.status != 200) {
            setErrorModal("An error occurred while fetching problem attempts.");
        }
        return response.json();
    }).catch(err => {
        setErrorModal("An error occurred while fetching problem attempts.");
        return {
            status: "UNDEFINED",
            count: -1
        };
    });

    const statusText = document.querySelector(".status-text");
    if (problemStatus.status == "UNATTEMPTED") {
        statusText.innerHTML = "Problem Unattempted";
    } else if (problemStatus.status == "SUCCESSFUL") {
        statusText.innerHTML = "Problem Completed. " + problemStatus.count + " attempts.";
    } else if (problemStatus.status == "FAILED") {
        statusText.innerHTML = "Problem attempted " + problemStatus.count + " times.";
    } else {
        statusText.innerHTML = "Failed to fetch.";
    }
}

updateProblemStatus();
