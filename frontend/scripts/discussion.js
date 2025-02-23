
function copyToClipboard(text) {
    // Use the Clipboard API to copy the text
    navigator.clipboard.writeText(text)
        .then(() => {

        })
        .catch(err => {
            console.error('Failed to copy text: ', err);
            alert('Failed to copy text. Please try again.');
        });

}

function copyButtonClicked(button) {
    button.innerHTML = 'Copied!';
    setTimeout(() => {
        button.innerHTML = 'Copy Code';
    }, 1000);
}


async function fetchComments() {
    try {
        const response = await fetch(`https://shaderdojo.tech/app/comments/${id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            },
        });

        if (!response.ok) {
            throw new Error(`${response.status}`);
        }

        const comments = await response.json();
        const commentsContainer = document.getElementById('comments');
        commentsContainer.innerHTML = '';

        comments.forEach(comment => {
            const commentElement = document.createElement('div');
            commentElement.classList.add('comment');

            // Create header container
            const header = document.createElement('div');
            header.classList.add('comment-header');

            // Username (using textContent to avoid XSS)
            const usernameP = document.createElement('p');
            usernameP.classList.add('comment-user');
            usernameP.textContent = comment.account.username;
            header.appendChild(usernameP);

            // Copy button without inline HTML event handlers
            const copyButton = document.createElement('button');
            copyButton.type = 'button';
            copyButton.classList.add('copy-button');
            copyButton.textContent = 'Copy Code';
            copyButton.addEventListener('click', function () {
                copyToClipboard(comment.code);
                copyButtonClicked(copyButton);
            });
            header.appendChild(copyButton);

            commentElement.appendChild(header);

            // Comment text (using textContent to avoid XSS)
            const commentText = document.createElement('p');
            commentText.classList.add('comment-text');
            commentText.textContent = comment.content;
            commentElement.appendChild(commentText);

            commentsContainer.appendChild(commentElement);
        });

        if (comments.length === 0) {
            commentsContainer.textContent = 'No alternative solutions posted';
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while fetching comments.');
    }
}

async function postComment(event) {
    event.preventDefault();
    const content = document.getElementById('content-post').value;
    const code = document.getElementById('code-post').value;
    try {
        const response = await fetch(`https://shaderdojo.tech/app/account/comment/${id}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
            },
            body: JSON.stringify({ code, content }),
        });

        if (!response.ok) {
            throw new Error(`HTTP Error: ${response.status}`);
        }

        fetchComments();
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while posting your comment.');
    }
    return false;
}

fetchComments();