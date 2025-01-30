const token = localStorage.getItem('token');
if (token == null) {
    window.location.href = redirectUrl;
}


async function verifyToken() {
    await fetch(`https://shaderdojo.tech:7090/account/verify_account`, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`
        }
    }).then(response => {
        if (response.status != 200) {
            window.location.href = redirectUrl;
        }
    }).catch(err => {
        setErrorModal("An error occurred while verifying your account. Your work might not be saved.");
    })
};

verifyToken();