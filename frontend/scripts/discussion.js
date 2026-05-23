window.SHADERDOJO_API = window.SHADERDOJO_API || {
    auth: `${location.origin}/auth`,
    app:  `${location.origin}/app`,
};

function copyToClipboard(text) {
    navigator.clipboard.writeText(text).catch(err => {
        console.error('Failed to copy text:', err);
    });
}

function copyButtonClicked(button) {
    const original = button.textContent;
    button.textContent = 'Copied';
    setTimeout(() => { button.textContent = original; }, 1000);
}

async function fetchComments() {
    const commentsContainer = document.getElementById('comments');
    try {
        const response = await fetch(`${SHADERDOJO_API.app}/comments/${id}`);
        if (!response.ok) throw new Error(`${response.status}`);

        const comments = await response.json();
        commentsContainer.replaceChildren();

        if (!comments.length) {
            commentsContainer.textContent = 'No alternative solutions posted yet.';
            return;
        }

        for (const comment of comments) {
            const commentEl = document.createElement('article');
            commentEl.className = 'comment';

            const header = document.createElement('div');
            header.className = 'comment-header';

            const user = document.createElement('p');
            user.className = 'comment-user';
            user.textContent = comment.username || 'unknown';
            header.appendChild(user);

            const copyBtn = document.createElement('button');
            copyBtn.type = 'button';
            copyBtn.className = 'copy-button';
            copyBtn.textContent = 'Copy code';
            copyBtn.addEventListener('click', () => {
                copyToClipboard(comment.code);
                copyButtonClicked(copyBtn);
            });
            header.appendChild(copyBtn);

            commentEl.appendChild(header);

            const text = document.createElement('p');
            text.className = 'comment-text';
            text.textContent = comment.content;
            commentEl.appendChild(text);

            commentsContainer.appendChild(commentEl);
        }
    } catch (error) {
        commentsContainer.textContent = 'Could not load comments.';
    }
}

async function postComment(event) {
    event.preventDefault();
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = `login.html?redirect=${encodeURIComponent(location.pathname + location.search)}`;
        return false;
    }

    const content = document.getElementById('content-post').value;
    const code = document.getElementById('code-post').value;
    try {
        const response = await fetch(`${SHADERDOJO_API.app}/account/comment/${id}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
            },
            body: JSON.stringify({ code, content }),
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        document.getElementById('content-post').value = '';
        document.getElementById('code-post').value = '';
        fetchComments();
    } catch (error) {
        if (typeof setErrorModal === 'function') {
            setErrorModal('Could not post comment. Please try again.');
        } else {
            alert('Could not post comment.');
        }
    }
    return false;
}

fetchComments();
