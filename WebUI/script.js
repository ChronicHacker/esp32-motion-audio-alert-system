function send(endpoint) {
  fetch(endpoint, { method: "POST" });
}

function changeVolume(val) {
  fetch('/volume', {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: "value=" + val
  });
}
