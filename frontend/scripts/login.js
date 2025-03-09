async function register(event) {
    event.preventDefault();

    const email = document.getElementById('email-signup').value;
    const username = document.getElementById('username-signup').value;
    const password = document.getElementById('password-signup').value;
    const confirmPassword = document.getElementById('confirm-password').value;

    if (password !== confirmPassword) {
        alert('Passwords do not match!');
        return false;
    }

    try {
        const response = await fetch('https://shaderdojo.tech/auth/register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, username, password, captcha: "123", captchaHash: "sdfasf" }),
        });
        if (!response.ok) {
            if(response.status === 409) {
                setErrorModal('Account already exists. Input a different username or email.');
            } else {
                setErrorModal('Unknown Error Occurred. Please Try Again Later.');
            }
        }
        const token = await response.text();
        localStorage.setItem('token', token);

        const redirect = new URLSearchParams(window.location.search).get('redirect');

        if (redirect)
            window.location.href = redirect;
        else
            window.location.href = 'index.html';
    } catch (error) {
        console.error('Error:', error);
        setErrorModal('An error occurred while creating your account. Please check your network and try again.');
    }

    return false;
}

async function login(event) {

    event.preventDefault();

    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    try {
        const response = await fetch('https://shaderdojo.tech/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username, password }),
        });

        if (!response.ok) {
            setErrorModal('Unknown Error Occurred. Please Try Again Later.');
        }
        const token = await response.text();
        localStorage.setItem('token', token);

        const redirect = new URLSearchParams(window.location.search).get('redirect');

        if (redirect)
            window.location.href = redirect;
        else
            window.location.href = 'index.html';
    } catch (error) {
        console.error('Error:', error);
        setErrorModal('An error occurred while creating your account. Please check your network and try again.');
    }

    return false;
}
