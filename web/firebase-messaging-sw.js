// Import the functions you need from the SDKs you need
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");
// Your web app's Firebase configuration

// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBOIvshNfIG7l45rHkpFMw2QXJkLGaFeYU",
  authDomain: "fcm-tasktracking.firebaseapp.com",
  projectId: "fcm-tasktracking",
  storageBucket: "fcm-tasktracking.firebasestorage.app",
  messagingSenderId: "719080791030",
  // appId: "1:719080791030:web:62709acdae7412f8c5c5d7",
  // measurementId: "G-YEFMG071VR"
};

// Initialize Firebase
// const app = initializeApp(firebaseConfig);
// const analytics = getAnalytics(app);
const messaging = firebase.messaging();