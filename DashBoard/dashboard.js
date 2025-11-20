// Bill Scanner Development Dashboard
// Data structure for all phases and tasks

const projectData = {
    startDate: "2025-10-21",
    phases: [
        {
            id: "phase1",
            name: "PHASE 1 — MVP",
            emoji: "🚀",
            description: "Build a fast, private, beautiful bill scanner",
            weeks: "Weeks 1-4",
            status: "in-progress",
            tasks: [
                {
                    id: "p1t1",
                    title: "📸 Camera + Auto-Crop Module",
                    description: "Implement edge detection, brightness enhancement, crop adjust",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p1t2",
                    title: "🔤 OCR Integration (Tesseract / ML Kit)",
                    description: "Extract text from images for amount, date, and vendor",
                    owner: "🧠 AI + Dev",
                    priority: "⭐⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p1t3",
                    title: "💾 Local Storage (SQLite)",
                    description: "Store bill metadata and image paths",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p1t4",
                    title: "🔐 Biometric App Lock",
                    description: "FaceID / Fingerprint app unlock",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p1t5",
                    title: "🖼️ Figma UI Implementation",
                    description: "Apply color scheme, dark mode, transitions",
                    owner: "🎨 UI",
                    priority: "⭐⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p1t6",
                    title: "🛰️ Offline Mode Support",
                    description: "App works without internet, syncs later",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                }
            ]
        },
        {
            id: "phase2",
            name: "PHASE 2 — SMART FEATURES",
            emoji: "⚙️",
            description: "Make the app feel intelligent & useful daily",
            weeks: "Weeks 5-8",
            status: "not-started",
            tasks: [
                {
                    id: "p2t1",
                    title: "🧠 Rule-Based Categorization",
                    description: "Categorize bills via keywords (electricity, groceries)",
                    owner: "🧠 AI",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p2t2",
                    title: "📊 Expense Summary Screen",
                    description: "Pie/Bar chart by category and vendor",
                    owner: "🎨 UI + Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p2t3",
                    title: "🔔 Smart Notifications",
                    description: "Due date alerts, spend summaries",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p2t4",
                    title: "☁️ Cloud Sync (Firebase)",
                    description: "Upload bills + metadata to cloud",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p2t5",
                    title: "🔎 Search & Filter Feature",
                    description: "Search by date, vendor, or category",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p2t6",
                    title: "📤 Export (PDF/CSV)",
                    description: "Export bills or reports",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐",
                    completed: false
                }
            ]
        },
        {
            id: "phase3",
            name: "PHASE 3 — AI & INSIGHTS",
            emoji: "🧠",
            description: "Make it a smart financial companion",
            weeks: "Weeks 9-12",
            status: "not-started",
            tasks: [
                {
                    id: "p3t1",
                    title: "♻️ Recurring Vendor Detection",
                    description: "Identify Netflix, Airtel, etc.",
                    owner: "🧠 AI",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p3t2",
                    title: "🔧 Warranty Reminder System",
                    description: "Detect purchase date and expiry",
                    owner: "🧠 AI + Dev",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p3t3",
                    title: "💬 AI Chat Assistant",
                    description: "Query bills: 'Show food bills from March'",
                    owner: "🧠 AI + Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p3t4",
                    title: "📈 Insights Dashboard",
                    description: "Trend lines, category comparisons",
                    owner: "🎨 UI + Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                }
            ]
        },
        {
            id: "phase4",
            name: "PHASE 4 — TRUST & MONETIZATION",
            emoji: "🔒",
            description: "Build loyalty, privacy trust, and revenue model",
            weeks: "Weeks 13-16",
            status: "not-started",
            tasks: [
                {
                    id: "p4t1",
                    title: "🔒 End-to-End Encryption",
                    description: "Secure cloud sync data",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p4t2",
                    title: "👁️ Privacy Dashboard",
                    description: "Transparency on data stored",
                    owner: "🎨 UI",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p4t3",
                    title: "💳 In-App Purchases (Stripe / Razorpay)",
                    description: "Subscription tiers",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p4t4",
                    title: "🎁 Referral Rewards",
                    description: "Invite friends → earn free months",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐",
                    completed: false
                }
            ]
        },
        {
            id: "phase5",
            name: "PHASE 5 — GROWTH & RETENTION",
            emoji: "🌍",
            description: "Drive virality, retention, and integrations",
            weeks: "Weeks 17-24",
            status: "not-started",
            tasks: [
                {
                    id: "p5t1",
                    title: "📧 Email Bill Import (Gmail API)",
                    description: "Fetch PDF bills automatically",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p5t2",
                    title: "📱 SMS Parsing",
                    description: "Detect payment alerts and link them",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p5t3",
                    title: "🏆 Gamification (Streaks / Badges)",
                    description: "Encourage daily scans",
                    owner: "🎨 UI + Dev",
                    priority: "⭐⭐",
                    completed: false
                },
                {
                    id: "p5t4",
                    title: "🌐 Multi-Language Support",
                    description: "English, Hindi, Tamil, Marathi",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p5t5",
                    title: "📤 In-App Sharing",
                    description: "Share summary links or bills",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐",
                    completed: false
                },
                {
                    id: "p5t6",
                    title: "📣 Push Campaigns",
                    description: "Your spending dropped 10% 🎉",
                    owner: "🧾 PM",
                    priority: "⭐⭐",
                    completed: false
                }
            ]
        },
        {
            id: "phase6",
            name: "PHASE 6 — ECOSYSTEM EXPANSION",
            emoji: "💎",
            description: "Build the brand ecosystem and B2B opportunities",
            weeks: "Post 6 Months",
            status: "not-started",
            tasks: [
                {
                    id: "p6t1",
                    title: "🏪 Business Mode",
                    description: "For small vendors to store invoices",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p6t2",
                    title: "💻 Web Dashboard",
                    description: "Manage bills online",
                    owner: "👨‍💻 Dev + UI",
                    priority: "⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p6t3",
                    title: "🧩 Bill Scanner API (B2B)",
                    description: "External API for OCR + Categorization",
                    owner: "🧠 AI",
                    priority: "⭐⭐⭐⭐",
                    completed: false
                },
                {
                    id: "p6t4",
                    title: "👨‍👩‍👧 Family Sharing Mode",
                    description: "Shared folders & budgets",
                    owner: "👨‍💻 Dev",
                    priority: "⭐⭐",
                    completed: false
                },
                {
                    id: "p6t5",
                    title: "📑 Tax Mode Export",
                    description: "Generate deductible expense reports",
                    owner: "🧾 PM",
                    priority: "⭐⭐⭐",
                    completed: false
                }
            ]
        }
    ]
};

// Initialize dashboard on load
document.addEventListener('DOMContentLoaded', () => {
    loadProgressFromStorage();
    renderDashboard();
    updateStats();
    updateLastUpdated();
    initializeScrollAnimations();
});

// Load saved progress from localStorage
function loadProgressFromStorage() {
    const savedData = localStorage.getItem('billScannerProgress');
    if (savedData) {
        const saved = JSON.parse(savedData);
        saved.phases.forEach((savedPhase, phaseIndex) => {
            savedPhase.tasks.forEach((savedTask, taskIndex) => {
                if (projectData.phases[phaseIndex] && projectData.phases[phaseIndex].tasks[taskIndex]) {
                    projectData.phases[phaseIndex].tasks[taskIndex].completed = savedTask.completed;
                }
            });
            if (projectData.phases[phaseIndex]) {
                projectData.phases[phaseIndex].status = savedPhase.status;
            }
        });
    }
}

// Save progress to localStorage
function saveProgressToStorage() {
    localStorage.setItem('billScannerProgress', JSON.stringify(projectData));
    localStorage.setItem('lastUpdated', new Date().toISOString());
    updateLastUpdated();
}

// Render the complete dashboard
function renderDashboard() {
    const container = document.getElementById('phasesContainer');
    container.innerHTML = '';

    projectData.phases.forEach((phase, phaseIndex) => {
        const phaseCard = createPhaseCard(phase, phaseIndex);
        container.appendChild(phaseCard);
    });
}

// Create a phase card element
function createPhaseCard(phase, phaseIndex) {
    const card = document.createElement('div');
    card.className = 'glass-effect border border-slate-700/50 rounded-3xl p-9 transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl hover:border-primary-500 animate-fade-in-up';
    card.style.animationDelay = `${phaseIndex * 0.1}s`;

    const completedTasks = phase.tasks.filter(t => t.completed).length;
    const totalTasks = phase.tasks.length;
    const progressPercent = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

    const statusClasses = {
        'not-started': 'bg-slate-700/30 text-slate-400',
        'in-progress': 'bg-amber-500/20 text-amber-400',
        'completed': 'bg-emerald-500/20 text-emerald-400'
    };

    card.innerHTML = `
        <div class="flex flex-wrap justify-between items-center mb-5 pb-5 border-b border-slate-700/50">
            <div class="text-2xl font-bold flex items-center gap-3">
                ${phase.emoji} ${phase.name}
            </div>
            <span class="px-4 py-1.5 ${statusClasses[phase.status]} rounded-full text-xs font-semibold uppercase tracking-wider">
                ${phase.status.replace('-', ' ')}
            </span>
        </div>
        <p class="text-slate-400 mb-4">${phase.description}</p>
        <p class="text-slate-400 text-sm mb-5">⏱️ ${phase.weeks}</p>
        
        <div class="mb-6">
            <div class="flex justify-between mb-2 text-sm">
                <span class="text-slate-300">${completedTasks} / ${totalTasks} tasks completed</span>
                <span class="font-semibold text-primary-500">${progressPercent}%</span>
            </div>
            <div class="w-full h-2 bg-slate-800 rounded-full overflow-hidden">
                <div class="h-full gradient-primary rounded-full transition-all duration-700" style="width: ${progressPercent}%"></div>
            </div>
        </div>

        <div class="space-y-3" id="tasks-${phase.id}">
            ${phase.tasks.map((task, taskIndex) => createTaskHTML(task, phase.id, taskIndex)).join('')}
        </div>
    `;

    return card;
}

// Create task HTML
function createTaskHTML(task, phaseId, taskIndex) {
    const completedClass = task.completed ? 'opacity-60' : '';
    const strikethrough = task.completed ? 'line-through' : '';
    const checkboxClass = task.completed ? 'gradient-primary border-primary-500' : 'border-slate-600';
    const checkmark = task.completed ? '✓' : '';
    
    return `
        <div onclick="toggleTask('${phaseId}', ${taskIndex})" class="${completedClass} flex items-start gap-4 p-4 bg-slate-900/50 border border-slate-700/50 rounded-xl cursor-pointer transition-all duration-300 hover:bg-slate-900/80 hover:border-primary-500">
            <div class="${checkboxClass} w-6 h-6 border-2 rounded-md flex items-center justify-center flex-shrink-0 mt-0.5 transition-all duration-300 text-white font-bold text-sm">
                ${checkmark}
            </div>
            <div class="flex-1">
                <div class="font-medium ${strikethrough} mb-1 text-slate-100">${task.title}</div>
                <div class="flex flex-wrap gap-4 mt-2 text-xs">
                    <span class="text-slate-400">${task.owner}</span>
                    <span class="text-slate-400">${task.priority}</span>
                </div>
                <p class="text-sm text-slate-400 mt-2">${task.description}</p>
            </div>
        </div>
    `;
}

// Toggle task completion
function toggleTask(phaseId, taskIndex) {
    const phase = projectData.phases.find(p => p.id === phaseId);
    if (phase && phase.tasks[taskIndex]) {
        phase.tasks[taskIndex].completed = !phase.tasks[taskIndex].completed;
        updatePhaseStatus(phase);
        saveProgressToStorage();
        renderDashboard();
        updateStats();
    }
}

// Update phase status based on completed tasks
function updatePhaseStatus(phase) {
    const completedTasks = phase.tasks.filter(t => t.completed).length;
    const totalTasks = phase.tasks.length;
    
    if (completedTasks === 0) {
        phase.status = 'not-started';
    } else if (completedTasks === totalTasks) {
        phase.status = 'completed';
    } else {
        phase.status = 'in-progress';
    }
}

// Update dashboard statistics
function updateStats() {
    const allTasks = projectData.phases.flatMap(p => p.tasks);
    const completedTasks = allTasks.filter(t => t.completed).length;
    const totalTasks = allTasks.length;
    const progressPercent = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

    const currentPhase = projectData.phases.find(p => p.status === 'in-progress') || 
                        projectData.phases.find(p => p.status === 'not-started') ||
                        projectData.phases[projectData.phases.length - 1];

    document.getElementById('totalProgress').textContent = `${progressPercent}%`;
    document.getElementById('completedTasks').textContent = completedTasks;
    document.getElementById('totalTasks').textContent = totalTasks;
    document.getElementById('currentPhase').textContent = currentPhase.name.split('—')[0].trim();
    document.getElementById('heroProgressBar').style.width = `${progressPercent}%`;

    const startDate = new Date(projectData.startDate);
    const today = new Date();
    const daysElapsed = Math.floor((today - startDate) / (1000 * 60 * 60 * 24));
    document.getElementById('daysElapsed').textContent = daysElapsed;
    document.getElementById('startDate').textContent = formatDate(startDate);
}

// Update last updated timestamp
function updateLastUpdated() {
    const lastUpdated = localStorage.getItem('lastUpdated');
    if (lastUpdated) {
        const date = new Date(lastUpdated);
        document.getElementById('lastUpdated').textContent = date.toLocaleString();
    } else {
        document.getElementById('lastUpdated').textContent = new Date().toLocaleString();
    }
}

// Format date
function formatDate(date) {
    return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' });
}

// Reset all progress
function resetProgress() {
    if (confirm('Are you sure you want to reset all progress? This action cannot be undone.')) {
        projectData.phases.forEach(phase => {
            phase.status = phase.id === 'phase1' ? 'in-progress' : 'not-started';
            phase.tasks.forEach(task => task.completed = false);
        });
        saveProgressToStorage();
        renderDashboard();
        updateStats();
        alert('✅ Progress has been reset!');
    }
}

// Export progress report
function exportProgress() {
    const allTasks = projectData.phases.flatMap(p => p.tasks);
    const completedTasks = allTasks.filter(t => t.completed).length;
    const totalTasks = allTasks.length;
    const progressPercent = Math.round((completedTasks / totalTasks) * 100);

    let report = `📱 BILL SCANNER APP - DEVELOPMENT PROGRESS REPORT\n`;
    report += `${'='.repeat(60)}\n\n`;
    report += `Generated: ${new Date().toLocaleString()}\n`;
    report += `Overall Progress: ${progressPercent}% (${completedTasks}/${totalTasks} tasks)\n\n`;

    projectData.phases.forEach(phase => {
        const phaseCompleted = phase.tasks.filter(t => t.completed).length;
        const phaseTotal = phase.tasks.length;
        const phasePercent = Math.round((phaseCompleted / phaseTotal) * 100);

        report += `\n${phase.emoji} ${phase.name}\n`;
        report += `${'-'.repeat(60)}\n`;
        report += `Status: ${phase.status.toUpperCase()}\n`;
        report += `Progress: ${phasePercent}% (${phaseCompleted}/${phaseTotal} tasks)\n`;
        report += `Duration: ${phase.weeks}\n\n`;

        phase.tasks.forEach(task => {
            const status = task.completed ? '✓' : '☐';
            report += `  ${status} ${task.title}\n`;
            report += `     ${task.description}\n`;
            report += `     Owner: ${task.owner} | Priority: ${task.priority}\n\n`;
        });
    });

    const blob = new Blob([report], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `bill-scanner-progress-${new Date().toISOString().split('T')[0]}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

// Show statistics in modal
function showStats() {
    const allTasks = projectData.phases.flatMap(p => p.tasks);
    const completedTasks = allTasks.filter(t => t.completed).length;
    const totalTasks = allTasks.length;
    const progressPercent = Math.round((completedTasks / totalTasks) * 100);
    
    const startDate = new Date(projectData.startDate);
    const today = new Date();
    const daysElapsed = Math.max(Math.floor((today - startDate) / (1000 * 60 * 60 * 24)), 1);
    const tasksPerDay = (completedTasks / daysElapsed).toFixed(2);
    
    const currentPhase = projectData.phases.find(p => p.status === 'in-progress') || 
                        projectData.phases.find(p => p.status === 'not-started') ||
                        projectData.phases[projectData.phases.length - 1];
    
    const activePhases = projectData.phases.filter(p => p.status === 'in-progress').length;
    const remainingTasks = totalTasks - completedTasks;

    // Populate modal data
    document.getElementById('modalOverallProgress').textContent = `${progressPercent}%`;
    document.getElementById('modalCompletedTasks').textContent = completedTasks;
    document.getElementById('modalTasksPerDay').textContent = tasksPerDay;
    document.getElementById('modalStartDate').textContent = formatDate(startDate);
    document.getElementById('modalDaysElapsed').textContent = daysElapsed;
    document.getElementById('modalCurrentPhase').textContent = currentPhase.name.split('—')[0].trim();
    document.getElementById('modalRemainingTasks').textContent = remainingTasks;
    document.getElementById('modalActivePhases').textContent = activePhases;

    // Populate phase breakdown
    const phaseBreakdownHTML = projectData.phases.map(phase => {
        const completed = phase.tasks.filter(t => t.completed).length;
        const total = phase.tasks.length;
        const percent = Math.round((completed / total) * 100);
        
        const statusColors = {
            'not-started': 'bg-slate-700/30 text-slate-400',
            'in-progress': 'bg-amber-500/20 text-amber-400',
            'completed': 'bg-emerald-500/20 text-emerald-400'
        };

        return `
            <div class="bg-slate-900/50 border border-slate-700/50 rounded-xl p-4">
                <div class="flex justify-between items-center mb-2">
                    <span class="font-semibold">${phase.emoji} ${phase.name}</span>
                    <span class="px-2 py-1 ${statusColors[phase.status]} rounded-full text-xs font-semibold uppercase">
                        ${phase.status.replace('-', ' ')}
                    </span>
                </div>
                <div class="flex justify-between text-sm mb-2">
                    <span class="text-slate-400">${completed} / ${total} tasks</span>
                    <span class="font-semibold text-primary-400">${percent}%</span>
                </div>
                <div class="w-full h-2 bg-slate-800 rounded-full overflow-hidden">
                    <div class="h-full gradient-primary rounded-full transition-all duration-700" style="width: ${percent}%"></div>
                </div>
            </div>
        `;
    }).join('');

    document.getElementById('phaseBreakdown').innerHTML = phaseBreakdownHTML;

    // Show modal
    document.getElementById('analyticsModal').classList.remove('hidden');
    document.getElementById('analyticsModal').classList.add('flex');
    document.body.style.overflow = 'hidden';
}

// Close analytics modal
function closeAnalytics(event) {
    if (event && event.target !== event.currentTarget) return;
    document.getElementById('analyticsModal').classList.add('hidden');
    document.getElementById('analyticsModal').classList.remove('flex');
    document.body.style.overflow = 'auto';
}

// Toggle keyboard shortcuts panel
function toggleShortcuts() {
    const panel = document.getElementById('shortcutsPanel');
    if (panel.classList.contains('hidden')) {
        panel.classList.remove('hidden');
    } else {
        panel.classList.add('hidden');
    }
}

// Initialize scroll animations
function initializeScrollAnimations() {
    const fadeElements = document.querySelectorAll('.animate-fade-in-up');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('opacity-100');
            }
        });
    }, { threshold: 0.1 });

    fadeElements.forEach(element => observer.observe(element));
}

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Ctrl+E - Export progress
    if (e.ctrlKey && e.key === 'e') {
        e.preventDefault();
        exportProgress();
    }
    // Ctrl+S - View analytics
    if (e.ctrlKey && e.key === 's') {
        e.preventDefault();
        showStats();
    }
    // Ctrl+K - Toggle shortcuts panel
    if (e.ctrlKey && e.key === 'k') {
        e.preventDefault();
        toggleShortcuts();
    }
    // ESC - Close modals
    if (e.key === 'Escape') {
        closeAnalytics();
        document.getElementById('shortcutsPanel').classList.add('hidden');
    }
});

