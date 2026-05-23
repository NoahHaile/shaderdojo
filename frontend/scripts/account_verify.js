window.SHADERDOJO_API = window.SHADERDOJO_API || {
    auth: `${location.origin}/auth`,
    app:  `${location.origin}/app`,
};

const token = localStorage.getItem('token');
if (token == null) {
    window.location.href = redirectUrl;
}


async function verifyToken() {
    await fetch(`${SHADERDOJO_API.app}/account/verify_account`, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`
        }
    }).then(response => {
        if (response.status != 200) {
            closeModal();
            window.location.href = redirectUrl;
        }
    }).catch(err => {
        setErrorModal("An error occurred while verifying your account. Please check your network connection.");
        closeModal();
    })
};

verifyToken();