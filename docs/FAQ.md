# Frequently Asked Questions (FAQ)

Welcome to the PlayMate FAQ. This document provides clear answers to common questions asked by players, tournament organizers, and developers.

---

## 🎮 General & Gameplay Questions

### Q1: Is an internet connection required to use PlayMate?
**No.** PlayMate is built with a strict **Offline-First** architecture. Every utility—Dice Roller, Coin Toss, Team Generator, Score Tracker, Cricket Scorer, Spin Wheel, Tournament Generator, and Timers—operates 100% offline without cell reception, Wi-Fi, or mobile data.

### Q2: Does PlayMate contain ads or paywalls?
**No.** PlayMate is completely ad-free. You will never encounter interstitial pop-ups, video ads, or banner distractions during your games.

### Q3: How do I roll the dice?
You can roll dice in two ways:
1. Tap the large **"Roll"** button at the bottom of the screen.
2. **Shake your device:** Gently shake your phone to simulate shaking physical dice in a cup. You can toggle shake sensitivity or disable it entirely in the **Settings** menu.

### Q4: Can I roll RPG dice like D20 or D4?
**Yes.** In the Dice Roller screen, tap the dice type selector chip to switch between standard six-sided dice (D6) and tabletop polyhedral RPG dice: **D4, D6, D8, D10, D12, and D20**. You can also choose to roll anywhere from 1 to 6 dice simultaneously.

### Q5: How does the Team Generator create balanced teams?
You enter your player names (either one by one or by pasting a list), select the desired number of teams (from 2 to 8), and choose your mode:
- **Pure Random:** Completely randomized assignment for casual games.
- **Skill-Weighted:** Assigns players based on star ratings (1 to 5 stars) to ensure squads have evenly matched average skill ratings.

### Q6: How does the Cricket Scorer handle Extras (Wides and No-Balls)?
When you tap **WD (Wide)** or **NB (No-Ball)**:
1. An extra run is immediately credited to the batting team's total.
2. The **legal delivery counter does not advance**. An over only completes after 6 legal deliveries have been bowled.
3. You can also log additional runs scored off a no-ball or wide (e.g., 1 NB + 2 runs = 3 runs total).

### Q7: How do Chess Timers work with Fischer increments?
When configuring a Chess Clock in the Timers section:
- You set a base time per player (e.g., 3 minutes, 5 minutes, 10 minutes).
- You can optionally set an **increment in seconds** (e.g., +2s or +5s). Each time a player hits their clock to pass the turn to their opponent, their remaining time increases by the increment amount.

### Q8: Can I undo a mistaken score entry?
**Yes.** Both the Score Tracker and Cricket Scorer feature a full **Undo** action button. Tapping Undo steps back the last recorded ball or point adjustment instantly.

---

## 💾 Data & Privacy Questions

### Q9: Where is my match history stored?
All match records, tournament brackets, and player rosters are stored locally in an encrypted binary file inside your phone's sandbox storage using the **Hive database**. 

### Q10: How do I delete my saved data?
Open **Settings** (gear icon in the top right of the home screen) $\rightarrow$ scroll down to **Data Management** $\rightarrow$ tap **"Clear All Data"** and confirm. This permanently erases all saved matches and statistics from your device.

### Q11: What data does PlayMate collect about me?
PlayMate collects **zero personal information**. We do not collect names, phone numbers, email addresses, or location data. Optional, anonymized crash reports and aggregate feature counters (e.g., "a D6 was rolled") are processed purely to maintain app stability.

---

## 🛠️ Developer & Platform Questions

### Q12: Which operating systems are supported?
- **Android:** Android 6.0 (API Level 23) and newer.
- **iOS:** iOS 14.0 and newer (iPhone and iPad).

### Q13: Can I run PlayMate in landscape mode or on a tablet?
**Yes.** PlayMate features a responsive layout engine that automatically shifts the dashboard and scoreboards from a 2-column mobile grid into a multi-column expanded layout on tablets and foldables.
