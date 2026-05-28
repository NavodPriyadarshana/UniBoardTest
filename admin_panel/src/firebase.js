import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "AIzaSyBx7p1FUkiYLUhwyUKlvck2XE7S6QIlPZI",
  authDomain: "uniboard-fd52f.firebaseapp.com",
  projectId: "uniboard-fd52f",
  storageBucket: "uniboard-fd52f.firebasestorage.app",
  messagingSenderId: "554742916529",
  appId: "1:554742916529:web:5c79357e6ce82e50b4c990"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export default app;