<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>PCAPIFY - Network Anomaly Detection</title>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Font Awesome (icons, not emojis) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
*{box-sizing:border-box;margin:0;padding:0}

body{
    font-family:"Segoe UI",Arial,sans-serif;
    background:#000;
    color:#fff;
    min-height:100vh;
}

/* ===== NAVBAR ===== */
.navbar{
    height:65px;
    background:#000;
    border-bottom:1px solid #444;
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:0 30px;
}

.logo{
    font-size:24px;
    font-weight:700;
    letter-spacing:2px;
}

.menu a{
    color:#ccc;
    text-decoration:none;
    margin-left:20px;
    padding:8px 14px;
    border-radius:6px;
    border:1px solid transparent;
}

.menu a:hover{
    color:#fff;
    border-color:#fff;
}

/* ===== MAIN ===== */
.main{
    max-width:1200px;
    margin:auto;
    padding:30px;
}

/* ===== CARDS ===== */
.card{
    background:#111;
    border:1px solid #333;
    border-radius:12px;
    padding:30px;
    margin-bottom:30px;
}

.card h2{
    font-size:26px;
    margin-bottom:20px;
    border-bottom:1px solid #444;
    padding-bottom:10px;
}

/* ===== INPUTS ===== */
input,select{
    width:100%;
    padding:14px;
    margin:12px 0;
    background:#000;
    color:#fff;
    border:1px solid #555;
    border-radius:8px;
}

input:focus,select:focus{
    outline:none;
    border-color:#fff;
}

/* ===== BUTTONS ===== */
button{
    background:#fff;
    color:#000;
    border:none;
    padding:14px 28px;
    border-radius:8px;
    cursor:pointer;
    font-size:16px;
    font-weight:600;
    margin-top:10px;
}

button:hover{
    background:#ddd;
}

button.secondary{
    background:#444;
    color:#fff;
}

button.secondary:hover{
    background:#666;
}

/* ===== MESSAGES ===== */
.message{
    padding:12px;
    border-radius:8px;
    margin:12px 0;
    font-size:14px;
}

.message.error{
    color:#ff2b2b;
    border-left:4px solid #ff2b2b;
    background:#1a0000;
}

.message.success{
    color:#fff;
    border-left:4px solid #fff;
    background:#1a1a1a;
}

.message.info{
    color:#ccc;
    border-left:4px solid #888;
    background:#111;
}

/* ===== FILE UPLOAD ===== */
.file-upload-container{
    border:2px dashed #888;
    padding:40px;
    text-align:center;
    border-radius:12px;
    cursor:pointer;
}

.file-upload-container:hover{
    border-color:#fff;
}

/* ===== STATS ===== */
.stats-grid{
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(200px,1fr));
    gap:20px;
    margin:20px 0;
}

.stat-card{
    background:#0d0d0d;
    border:1px solid #333;
    padding:20px;
    border-radius:10px;
    text-align:center;
}

.stat-value{
    font-size:34px;
    font-weight:700;
}

.stat-label{
    font-size:13px;
    color:#aaa;
    letter-spacing:1px;
}

/* ===== ANOMALY LIST ===== */
.anomaly-item{
    background:#1a0000;
    border-left:4px solid #ff2b2b;
    padding:15px;
    border-radius:8px;
    margin:10px 0;
    display:flex;
    align-items:center;
    justify-content:space-between;
}

.anomaly-item.safe{
    background:#111;
    border-left:4px solid #888;
}

/* ===== CHART ===== */
.chart-container{
    background:#0d0d0d;
    border:1px solid #333;
    padding:20px;
    border-radius:12px;
    margin-top:20px;
}

canvas{
    width:100%!important;
    height:auto!important;
}

/* ===== UTILS ===== */
.hidden{display:none}
.flex{display:flex;gap:15px}
</style>
</head>

<body>

<div class="navbar">
    <div class="logo">PCAPIFY</div>
    <div class="menu hidden" id="mainMenu">
        <a onclick="showPage('dashboard')">Dashboard</a>
        <a onclick="showPage('uploadPage')">Upload</a>
        <a onclick="showPage('resultPage')">Results</a>
        <a onclick="showPage('about')">About</a>
        <a onclick="logout()">Logout</a>
    </div>
</div>

<div class="main">

<!-- LOGIN -->
<div id="login" class="card">
    <h2>Login</h2>
    <input id="username" placeholder="Username">
    <input id="password" type="password" placeholder="Password">
    <button onclick="login()">Login</button>
    <div id="loginMessage" class="message error hidden"></div>
</div>

<!-- DASHBOARD -->
<div id="dashboard" class="card hidden">
    <h2>System Overview</h2>
    <div class="stats-grid">
        <div class="stat-card"><div class="stat-value" id="loginCount">0</div><div class="stat-label">Logins</div></div>
        <div class="stat-card"><div class="stat-value" id="analysisCount">0</div><div class="stat-label">Analyses</div></div>
        <div class="stat-card"><div class="stat-value" id="anomalyCount">0</div><div class="stat-label">Anomalies</div></div>
    </div>
    <button onclick="showPage('uploadPage')">Start Analysis</button>
</div>

<!-- UPLOAD -->
<div id="uploadPage" class="card hidden">
    <h2>Upload PCAP</h2>
    <div class="file-upload-container" onclick="pcapFile.click()">
        Click to upload PCAP file
    </div>
    <input type="file" id="pcapFile" accept=".pcap,.pcapng" class="hidden">
    <div id="uploadMessage" class="message hidden"></div>
    <button onclick="analyzeFile()">Analyze</button>
</div>

<!-- RESULTS -->
<div id="resultPage" class="card hidden">
    <h2>Analysis Results</h2>
    <p><b>File:</b> <span id="resultFileName"></span></p>

    <div class="stats-grid">
        <div class="stat-card"><div class="stat-value" id="totalPackets">0</div><div class="stat-label">Packets</div></div>
        <div class="stat-card"><div class="stat-value" id="detectedAnomalies">0</div><div class="stat-label">Anomalies</div></div>
        <div class="stat-card"><div class="stat-value" id="riskScore">0%</div><div class="stat-label">Risk</div></div>
    </div>

    <div id="anomalyList"></div>

    <div class="chart-container">
        <canvas id="lineGraph"></canvas>
    </div>

    <div class="chart-container">
        <canvas id="pieChart"></canvas>
    </div>

    <button onclick="showPage('uploadPage')">Analyze Another</button>
</div>

<!-- ABOUT -->
<div id="about" class="card hidden">
    <h2>About</h2>
    <p>PCAPIFY is a network anomaly detection demo for cybersecurity analysis.</p>
</div>

</div>

<script>
let lineChart,pieChart;
let loginHistory=[],analysisHistory=[];
let currentFile=null;

function showPage(id){
    ['login','dashboard','uploadPage','resultPage','about']
    .forEach(p=>document.getElementById(p).classList.add('hidden'));
    document.getElementById(id).classList.remove('hidden');
}

function login(){
    if(username.value==="admin" && password.value==="admin"){
        mainMenu.classList.remove('hidden');
        loginHistory.push(Date.now());
        loginCount.textContent=loginHistory.length;
        showPage('dashboard');
    }else{
        loginMessage.textContent="Invalid credentials";
        loginMessage.classList.remove('hidden');
    }
}

function logout(){
    mainMenu.classList.add('hidden');
    showPage('login');
}

pcapFile.onchange=e=>currentFile=e.target.files[0];

function analyzeFile(){
    if(!currentFile){
        uploadMessage.textContent="Select a PCAP file";
        uploadMessage.className="message error";
        uploadMessage.classList.remove('hidden');
        return;
    }
    showPage('resultPage');
    resultFileName.textContent=currentFile.name;

    let scores=[...Array(20)].map(()=>Math.random()*10);
    let anomalies=scores.filter(s=>s>6).length;

    detectedAnomalies.textContent=anomalies;
    totalPackets.textContent=2000+Math.floor(Math.random()*3000);
    riskScore.textContent=Math.round(anomalies/20*100)+"%";

    drawLine(scores);
    drawPie(anomalies,20-anomalies);
}

function drawLine(data){
    if(lineChart)lineChart.destroy();
    lineChart=new Chart(lineGraph,{
        type:'line',
        data:{labels:data.map((_,i)=>i+1),datasets:[{data,borderColor:'#fff'}]},
        options:{scales:{y:{beginAtZero:true,max:10}}}
    });
}

function drawPie(a,n){
    if(pieChart)pieChart.destroy();
    pieChart=new Chart(pieChart,{
        type:'pie',
        data:{labels:['Anomaly','Normal'],datasets:[{data:[a,n],backgroundColor:['#ff2b2b','#888']}]}
    });
}

showPage('login');
</script>

</body>
</html>
