
const pauseButton = document.getElementById('pausePlayButton');
const timeDisplay = document.getElementById('timeDisplay');
const manualTime = document.getElementById('manualTime');
const resetButton = document.getElementById('resetButton');


let trackedTime;

let paused = false;

let pausedTime = 0;
let totalPauseTime = 0;

let offset = 0;

let startTime;

let currentProcess = 0;


function togglePause() {
    paused = !paused;
    if (paused) {
        pausedTime = Date.now();
        pauseButton.textContent = "▶";
    } else {
        totalPauseTime = Date.now() - pausedTime;
        startTime += totalPauseTime * 0.001;
        pauseButton.textContent = "❚❚";
    }
}

pauseButton.addEventListener('click', () => {
    togglePause()
});

function setTrackedTime(time) {
    trackedTime = time;
    timeDisplay.textContent = time.toFixed(2);
}

function playShader() {
    trackedTime = 0;
    totalPauseTime = 0;
    startTime = null;
    setTrackedTime(0);
    offset = manualTime.value;
    paused = false;
    pauseButton.textContent = "❚❚";
}

resetButton.addEventListener('click', () => {
    playShader();
});