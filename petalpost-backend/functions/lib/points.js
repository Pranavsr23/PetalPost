"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.awardPoints = awardPoints;
exports.updateStreak = updateStreak;
exports.pointsForSend = pointsForSend;
exports.pointsForRead = pointsForRead;
exports.pointsForReact = pointsForReact;
exports.pointsForFavorite = pointsForFavorite;
const admin = __importStar(require("firebase-admin"));
const POINTS = {
    send: 5,
    read: 2,
    react: 1,
    favorite: 2,
    streak: 3,
};
const BADGES = [
    { id: "first_note", points: 20 },
    { id: "streak_3", points: 60 },
    { id: "lover", points: 250 },
    { id: "milestone", points: 100 },
];
async function awardPoints(uid, delta) {
    if (delta === 0)
        return;
    const userRef = admin.firestore().collection("users").doc(uid);
    await admin.firestore().runTransaction(async (tx) => {
        const snap = await tx.get(userRef);
        const currentPoints = snap.get("points") ?? 0;
        const newPoints = currentPoints + delta;
        const existingBadges = new Set(snap.get("badges") ?? []);
        for (const badge of BADGES) {
            if (newPoints >= badge.points) {
                existingBadges.add(badge.id);
            }
        }
        tx.set(userRef, {
            points: newPoints,
            badges: Array.from(existingBadges),
        }, { merge: true });
    });
}
async function updateStreak(uid) {
    const userRef = admin.firestore().collection("users").doc(uid);
    let streak = 0;
    await admin.firestore().runTransaction(async (tx) => {
        const snap = await tx.get(userRef);
        const lastSent = snap.get("lastSentAt");
        const now = admin.firestore.Timestamp.now();
        if (!lastSent) {
            streak = 1;
        }
        else {
            const diffHours = (now.toMillis() - lastSent.toMillis()) / (1000 * 60 * 60);
            streak = diffHours <= 36 ? (snap.get("streakCount") ?? 0) + 1 : 1;
        }
        tx.set(userRef, {
            lastSentAt: now,
            streakCount: streak,
        }, { merge: true });
    });
    if (streak > 1) {
        await awardPoints(uid, POINTS.streak);
    }
}
function pointsForSend() {
    return POINTS.send;
}
function pointsForRead() {
    return POINTS.read;
}
function pointsForReact() {
    return POINTS.react;
}
function pointsForFavorite() {
    return POINTS.favorite;
}
