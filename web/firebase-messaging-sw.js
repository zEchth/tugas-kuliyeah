// web/firebase-messaging-sw.js
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js");

// 1. Konfigurasi Firebase (Dapatkan ini dari Firebase Console)
// Nanti Anda harus mengganti nilai-nilai ini dengan data asli proyek Anda
const firebaseConfig = {
  apiKey: "AIzaSyD0QN7tBiABOfNzAUAQ3F82Yf2POSXloYg",
  authDomain: "tasktracker-131c8.firebaseapp.com",
  projectId: "tasktracker-131c8",
  storageBucket: "tasktracker-131c8.firebasestorage.app",
  messagingSenderId: "474399573688",
  appId: "1:474399573688:web:cabdbe3d0428c8d26f164d",
  measurementId: "G-VQGMNQ612S"
};

// 2. Initialize Firebase
firebase.initializeApp(firebaseConfig);

// 3. Retrieve Firebase Messaging object
const messaging = firebase.messaging();

// 4. Handle Background Notifications
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // Icon aplikasi Anda
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});