<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jadwal Harian Dinamis - Real-Time</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Digital+7&display=swap');
        
        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        .digital-clock {
            font-family: 'Digital 7', monospace;
            letter-spacing: 6px;
            text-shadow: 0 0 20px rgba(0, 255, 255, 0.8);
        }
        
        .hours-text { font-size: 3.2rem; line-height: 1; }
        .minutes-text { font-size: 2.4rem; line-height: 1; }
        .seconds-text { font-size: 1.8rem; line-height: 1; opacity: 0.85; }
        
        .schedule-card { transition: all 0.3s ease; }
        .schedule-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
        }
        
        .live-dot { animation: pulse 2s infinite; }
    </style>
</head>
<body class="bg-zinc-950 text-white min-h-screen">
    <div class="max-w-6xl mx-auto px-6 py-8">
        <div class="flex justify-between items-start mb-8">
            <div>
                <h1 class="text-4xl font-bold tracking-tight">Jadwal <span id="header-day" class="text-cyan-400">Hari Ini</span></h1>
                <p class="text-zinc-400 text-lg mt-1">Label otomatis berganti sesuai hari aktif.</p>
            </div>
            
            <div class="flex items-center gap-2 bg-zinc-900 px-4 py-2 rounded-3xl border border-cyan-500/30">
                <div class="w-3 h-3 bg-cyan-400 rounded-full live-dot"></div>
                <span class="text-sm font-medium text-cyan-400">LIVE • Smart Scheduler</span>
            </div>
        </div>

        <div class="bg-zinc-900 rounded-3xl p-8 mb-8 border border-cyan-500/20 shadow-2xl">
            <div class="flex flex-col items-center">
                <div id="clock" class="digital-clock flex items-center justify-center gap-3 text-cyan-300">
                    <span id="hours" class="hours-text">00</span>
                    <span class="text-4xl text-cyan-400/60 mt-1">:</span>
                    <span id="minutes" class="minutes-text">00</span>
                    <span class="text-4xl text-cyan-400/60 mt-1">:</span>
                    <span id="seconds" class="seconds-text">00</span>
                </div>
                
                <div class="flex items-center gap-3 mt-4">
                    <div id="date" class="text-2xl font-medium text-zinc-400"></div>
                    <div id="dayname" class="text-2xl font-semibold bg-cyan-500/10 text-cyan-400 px-5 py-1 rounded-2xl"></div>
                </div>
            </div>
        </div>

        <div class="mb-6">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-3xl font-semibold">Aktivitas Spesifik Hari Ini</h2>
                <span id="current-date-small" class="text-sm px-3 py-1 bg-zinc-800 rounded-2xl text-zinc-400"></span>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="schedule-list">
                </div>
        </div>
    </div>

    <script>
        // DATA JADWAL BERBEDA SETIAP HARI
        const dailySchedules = {
            "Senin": [
                { time: "08:00", label: "Monday Meeting", desc: "Evaluasi mingguan dan penetapan target baru." },
                { time: "13:00", label: "Deep Work", desc: "Fokus penuh pada tugas teknis tersulit minggu ini." }
            ],
            "Selasa": [
                { time: "09:00", label: "Skill Learning", desc: "Waktu untuk belajar teknologi atau bahasa baru." },
                { time: "15:00", label: "Collaboration", desc: "Diskusi proyek kreatif dengan tim eksternal." }
            ],
            "Rabu": [
                { time: "10:00", label: "Mid-week Review", desc: "Melihat progres target tengah minggu." },
                { time: "19:00", label: "Community Night", desc: "Berinteraksi dengan komunitas atau networking." }
            ],
            "Kamis": [
                { time: "08:30", label: "Content Creation", desc: "Menulis artikel, dokumentasi, atau membuat video." },
                { time: "14:00", label: "Client Follow-up", desc: "Menghubungi klien dan mematikan progres feedback." }
            ],
            "Jumat": [
                { time: "11:00", label: "Final Check", desc: "Menyelesaikan semua sisa pekerjaan sebelum weekend." },
                { time: "16:00", label: "Clean Up", desc: "Merapikan file komputer dan meja kerja." }
            ],
            "Sabtu": [
                { time: "07:00", label: "Long Run", desc: "Olahraga kardio durasi panjang untuk stamina." },
                { time: "18:00", label: "Movie Night", desc: "Waktu santai menonton film favorit." }
            ],
            "Minggu": [
                { time: "09:00", label: "Self Care", desc: "Hobi, meditasi, dan istirahat total." },
                { time: "20:00", label: "Weekly Prep", desc: "Menyiapkan pakaian dan jadwal untuk hari Senin." }
            ]
        };

        // Fungsi Tambahan untuk simulasi 10 label per hari (duplikasi agar list penuh)
        function getFullSchedule(day) {
            let base = dailySchedules[day] || dailySchedules["Senin"];
            // Jika data kurang dari 10, kita tambahkan jadwal umum
            const general = [
                { time: "00:00", label: "Istirahat", desc: "Waktu tidur untuk pemulihan otak." },
                { time: "12:00", label: "Isoma", desc: "Istirahat, Sholat, dan Makan siang." },
                { time: "22:00", label: "Wind Down", desc: "Matikan gadget dan relaksasi." }
            ];
            return [...base, ...general].sort((a, b) => a.time.localeCompare(b.time)).slice(0, 10);
        }

        function updateClock() {
            const now = new Date();
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const seconds = String(now.getSeconds()).padStart(2, '0');
            
            document.getElementById('hours').textContent = hours;
            document.getElementById('minutes').textContent = minutes;
            document.getElementById('seconds').textContent = seconds;
            
            const dayName = now.toLocaleDateString('id-ID', { weekday: 'long' });
            const fullDate = now.toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
            
            // Update Text
            if(document.getElementById('dayname').textContent !== dayName.toUpperCase()) {
                document.getElementById('dayname').textContent = dayName.toUpperCase();
                document.getElementById('header-day').textContent = dayName;
                renderSchedule(dayName); // Re-render jika hari berubah
            }
            document.getElementById('date').textContent = fullDate;
            document.getElementById('current-date-small').textContent = fullDate;
        }

        function renderSchedule(day) {
            const container = document.getElementById('schedule-list');
            const data = getFullSchedule(day);
            container.innerHTML = '';
            
            data.forEach((item, index) => {
                container.innerHTML += `
                <div class="schedule-card bg-zinc-900 border border-zinc-700 hover:border-cyan-400 rounded-3xl p-6 flex gap-6 items-start">
                    <div class="flex-shrink-0 w-16 h-16 bg-cyan-950 text-cyan-300 rounded-2xl flex items-center justify-center font-mono text-xl font-bold border border-cyan-400/30">
                        ${item.time}
                    </div>
                    <div class="flex-1">
                        <div class="flex items-center justify-between">
                            <h3 class="font-semibold text-lg text-white">${item.label}</h3>
                            <span class="text-[10px] bg-zinc-800 text-zinc-500 px-2 py-1 rounded-lg uppercase tracking-widest">${day}</span>
                        </div>
                        <p class="text-zinc-400 mt-2 text-sm leading-relaxed">${item.desc}</p>
                    </div>
                </div>`;
            });
        }

        function initialize() {
            updateClock();
            setInterval(updateClock, 1000);
            console.log("System Ready: Perubahan jadwal berdasarkan hari aktif.");
        }

        window.onload = initialize;
    </script>
</body>
</html>
