// Bill Scanner Development Dashboard with Firebase Sync
// This version syncs with Flutter app through Firebase Realtime Database

// ========================================
// FIREBASE CONFIGURATION
// ========================================
// TODO: Replace with your Firebase config
const firebaseConfig = {
    apiKey: "YOUR_API_KEY_HERE",
    authDomain: "your-project.firebaseapp.com",
    databaseURL: "https://your-project-default-rtdb.firebaseio.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
};

// Initialize Firebase
let database;
let isFirebaseEnabled = false;

function initializeFirebase() {
    try {
        if (typeof firebase !== 'undefined') {
            firebase.initializeApp(firebaseConfig);
            database = firebase.database();
            isFirebaseEnabled = true;
            console.log('✅ Firebase initialized successfully');
            loadFromFirebase();
        } else {
            console.warn('⚠️ Firebase not loaded. Using localStorage fallback.');
            isFirebaseEnabled = false;
            loadProgressFromStorage();
        }
    } catch (error) {
        console.error('❌ Firebase initialization error:', error);
        isFirebaseEnabled = false;
        loadProgressFromStorage();
    }
}

// ========================================
// DATA STRUCTURE
// ========================================
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

// ========================================
// FIREBASE SYNC FUNCTIONS
// ========================================

// Save to Firebase
function saveProgressToFirebase() {
    if (!isFirebaseEnabled || !database) {
        saveProgressToStorage();
        return;
    }

    const data = {
        phases: projectData.phases,
        startDate: projectData.startDate,
        lastUpdated: new Date().toISOString(),
        source: 'web'
    };

    database.ref('billScanner/progress').set(data)
        .then(() => {
            console.log('✅ Synced to Firebase');
            showSyncStatus('Synced with mobile app ✅');
        })
        .catch((error) => {
            console.error('❌ Firebase sync error:', error);
            saveProgressToStorage();
            showSyncStatus('Sync failed, saved locally ⚠️');
        });
}

// Load from Firebase
function loadFromFirebase() {
    database.ref('billScanner/progress').once('value')
        .then((snapshot) => {
            const data = snapshot.val();
            if (data && data.phases) {
                projectData.phases = data.phases;
                projectData.startDate = data.startDate || projectData.startDate;
                console.log('✅ Loaded from Firebase');
                renderDashboard();
                updateStats();
                updateLastUpdated();
            } else {
                console.log('No Firebase data, using defaults');
                loadProgressFromStorage();
            }
        })
        .catch((error) => {
            console.error('❌ Error loading from Firebase:', error);
            loadProgressFromStorage();
        });

    // Listen for realtime updates
    database.ref('billScanner/progress').on('value', (snapshot) => {
        const data = snapshot.val();
        if (data && data.source !== 'web') {
            console.log('📱 Update received from mobile app');
            projectData.phases = data.phases;
            renderDashboard();
            updateStats();
            showSyncStatus('Updated from mobile app 📱');
        }
    });
}

// Show sync status notification
function showSyncStatus(message) {
    const notification = document.createElement('div');
    notification.className = 'fixed top-4 right-4 bg-emerald-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-fade-in-down';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.opacity = '0';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// ========================================
// FALLBACK: LOCALSTORAGE FUNCTIONS
// ========================================

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
    renderDashboard();
    updateStats();
    updateLastUpdated();
}

function saveProgressToStorage() {
    localStorage.setItem('billScannerProgress', JSON.stringify(projectData));
    localStorage.setItem('lastUpdated', new Date().toISOString());
    updateLastUpdated();
}

// ========================================
// INITIALIZATION
// ========================================

document.addEventListener('DOMContentLoaded', () => {
    initializeFirebase();
    initializeScrollAnimations();
});

// [REST OF THE FUNCTIONS FROM ORIGINAL dashboard.js]
// Copy all the other functions (renderDashboard, toggleTask, showStats, etc.)
// from the original dashboard.js file here...

// The functions are identical, just replace saveProgressToStorage calls
// with saveProgressToFirebase calls

// NOTE: This is a template. You'll need to:
// 1. Replace Firebase config with your actual config
// 2. Add the remaining functions from dashboard.js
// 3. Replace localStorage calls with Firebase calls

