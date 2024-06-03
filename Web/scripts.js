document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

        tab.classList.add('active');
        document.getElementById(tab.dataset.tab).classList.add('active');
    });
});

function showAlertForm() {
    document.getElementById('alertModal').style.display = 'flex';
    document.getElementById('overlay').style.display = 'block';
}

function hideAlertForm() {
    document.getElementById('alertModal').style.display = 'none';
    document.getElementById('overlay').style.display = 'none';
}

// Create a new alert
function createAlert() {
    const botToken = document.getElementById('botToken').value;
    const chatId = document.getElementById('chatId').value;
    const indicator = document.getElementById('indicator').value;
    const thresholdValue = document.getElementById('thresholdValue').value;
    const thresholdUnit = document.getElementById('thresholdUnit').value;
    const scanInterval = document.getElementById('scanInterval').value;
    const intervalUnit = document.getElementById('intervalUnit').value;

    if (!botToken || !chatId || !indicator || !thresholdValue || !thresholdUnit || !scanInterval || !intervalUnit) {
        alert('Vui lòng điền đầy đủ thông tin.');
        return;
    }

    const alertData = {
        bot_token: botToken,
        chat_id: chatId,
        created_at: new Date().toISOString(), // Setting created_at to the current date and time
        indicator: indicator,
        threshold_value: parseFloat(thresholdValue),
        threshold_unit: thresholdUnit,
        scan_interval: parseInt(scanInterval, 10),
        interval_unit: intervalUnit
    };

    fetch('http://127.0.0.1:5000/api/alerts', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(alertData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        console.log('Alert created:', data);
        loadAlerts(); // Reload alerts to include the new one
        document.getElementById('alertForm').reset(); // Reset the form
        hideAlertForm(); // Hide the form after submission
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Có lỗi xảy ra khi tạo ngưỡng: ' + error.message);
    });
}


function loadAlerts() {
    fetch('http://127.0.0.1:5000/api/alerts', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        console.error('response:', response);
        return response.json();
    })
    .then(data => {
        const table = document.getElementById('alertsTable').getElementsByTagName('tbody')[0];
        table.innerHTML = ''; // Clear any existing rows

        if (!Array.isArray(data)) {
            throw new Error('Response data is not an array');
        }

        data.forEach(alert => {
            const newRow = table.insertRow();
            newRow.insertCell(0).innerText = alert.bot_token || '';
            newRow.insertCell(1).innerText = alert.chat_id || '';
            newRow.insertCell(2).innerText = alert.indicator || '';
            newRow.insertCell(3).innerText = alert.threshold_value + '(' + alert.threshold_unit + ')'|| '';
            newRow.insertCell(4).innerText = alert.scan_interval + '(' + alert.interval_unit + ')'|| '';
            const actionCell = newRow.insertCell(5);

            actionCell.innerHTML = '<button onclick="editAlert(this)">Chỉnh sửa</button> <button onclick="deleteAlert(this)">Xóa</button>';
        });
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Có lỗi xảy ra khi tải ngưỡng: ' + error.message);
    });
}



function editAlert(button) {
    const row = button.closest('tr');
    showAlertForm();
    document.getElementById('botToken').value = row.cells[0].innerText;
    document.getElementById('chatId').value = row.cells[1].innerText;
    document.getElementById('indicator').value = row.cells[2].innerText;
    document.getElementById('thresholdValue').value = row.cells[3].innerText;
    document.getElementById('scanInterval').value = row.cells[4].innerText;
    row.remove();
}

function deleteAlert(button) {
    if (confirm('Bạn có chắc chắn muốn xóa ngưỡng này không?')) {
        const row = button.closest('tr');
        row.remove();
    }
}

function showContent() {
    // Kiểm tra trạng thái đăng nhập từ Local Storage và hiển thị phần nội dung tương ứng
    const isLoggedIn = localStorage.getItem('isLoggedIn');

    if (isLoggedIn) {
        document.getElementById('loginModal').style.display = 'none';
        document.getElementById('mainContent').style.display = 'block';
    } else {
        document.getElementById('loginModal').style.display = 'block';
        document.getElementById('mainContent').style.display = 'none';
    }
}


function login() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    // Tạo payload chứa thông tin đăng nhập
    const payload = {
        username: username,
        password: password
    };

    // Gửi yêu cầu POST đến backend
    fetch('http://127.0.0.1:5000/api/login', {  // Đảm bảo URL là của backend
        method: 'POST', // Sử dụng phương thức POST
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Invalid username or password');
        }
        return response.json();
    })
    .then(data => {
        // Xử lý phản hồi từ backend
        localStorage.setItem('isLoggedIn', true);
        // document.getElementById('loginModal').style.display = 'none';
        // document.getElementById('mainContent').style.display = 'block';
        showContent();
    })
    .catch(error => {
        // Xử lý lỗi
        alert(error.message);
    });
}


function logout() {
    localStorage.setItem('isLoggedIn', false);
    showContent();
}
