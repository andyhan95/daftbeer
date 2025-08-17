# daftbeer — Requirements Document (Swift • SwiftUI • Xcode)

## 1) App Overview
daftbeer helps people find breweries and brewpubs near them. It shows a big map. It reads a ready .csv file (a table in a file) that comes with the app. Dots on the map show places. Tap a dot to see more.

---

## 2) Main Goals
1. Show a full-screen map at launch.  
2. Ask to use the phone’s location in a friendly way.  
3. If allowed, center the map on the user. If not, center on Downtown LA (DTLA).  
4. Load places from the bundled .csv file and show them as dots.  
5. Group dots together when zoomed out, and split them when zoomed in.  
6. Let users tap a dot to see simple info in a slide-up panel.  
7. Add a re-center button, a filter/search button (placeholder), and a profile/settings button (placeholder).  
8. Handle missing info and common errors without crashing.

---

## 3) User Stories (US-001 …)
- **US-001**: As a user, I want to see a map right away so that I can explore nearby breweries fast.  
- **US-002**: As a user, I want the app to ask for my location nicely so that I understand why it’s needed.  
- **US-003**: As a user, I want the map to center on me so that I can see what’s close.  
- **US-004**: As a user, if I say no to location, I want the map to still work so that I can browse DTLA.  
- **US-005**: As a user, I want dots on the map for each place so that I can spot them quickly.  
- **US-006**: As a user, I want dots to group when I zoom out so that the map is not messy.  
- **US-007**: As a user, I want to tap a dot and see name, type, address, phone (if any), and website (if any) so that I can decide to visit.  
- **US-008**: As a user, I want a re-center button so that I can jump back to my location.  
- **US-009**: As a user, I want a filter/search button (even if blank for now) so that I know filtering is coming.  
- **US-010**: As a user, I want a simple profile/settings button (blank for now) so that I can expect settings later.  
- **US-011**: As a user, I want clear messages when something goes wrong so that I am not confused.

---

## 4) Features (F-001 …)
> For each feature: **What it does / When it appears / If something goes wrong**

- **F-001 Load CSV Data**  
  - **Does**: Reads the bundled `.csv` at app start. Makes a list of places.  
  - **When**: On first app load and any time the app needs to refresh the list.  
  - **If wrong**: Show a simple alert: “Couldn’t load places. Please restart the app.” Keep the map empty but usable.

- **F-002 Friendly Location Ask (Pre-Prompt + System Prompt)**  
  - **Does**: Shows a simple popup first: “Share your location for the best experience” with **Okay**. Then shows Apple’s location prompt.  
  - **When**: On first launch before showing the full map.  
  - **If wrong**: If system prompt fails or user closes it, continue with DTLA center.

- **F-003 Map at Launch (Full Screen)**  
  - **Does**: Shows Apple’s map full screen. Supports pan and zoom (including double-tap).  
  - **When**: Right after the location flow.  
  - **If wrong**: If map fails to load, show an alert: “Map not available.” Keep a blank background.

- **F-004 Map Center Logic**  
  - **Does**:  
    - If location allowed: center on user.  
    - If not allowed: center on DTLA.  
  - **When**: Right after the map appears.  
  - **If wrong**: If user location is not available, fall back to DTLA.

- **F-005 Dots for Places (with Clustering)**  
  - **Does**: Shows each place as a round dot with a beer icon. Dots group into clusters when zoomed out and split when zoomed in.  
  - **When**: After CSV load and map shows.  
  - **If wrong**: If a place has bad or missing coordinates, skip that place and continue.

- **F-006 Tap Dot → Node View (Slide-Up Panel)**  
  - **Does**: Slide up a panel from the bottom with: Back button, Name, Type, Address (or “No Address Available”), Phone (if any), and Website link (if any; opens in browser).  
  - **When**: When the user taps a dot or a cluster item.  
  - **If wrong**:  
    - If website link can’t open: show alert “Can’t open website.”  
    - If fields are missing: hide the missing rows. Do not crash.

- **F-007 Re-Center Floating Button (Bottom-Left)**  
  - **Does**:  
    - If location allowed: jumps map back to user.  
    - If location not allowed: shows a popup with **Sure** (opens iOS Settings to app page) and **No Thanks** (dismiss).  
  - **When**: Always visible on the map.  
  - **If wrong**: If settings link fails, show alert “Can’t open Settings.”

- **F-008 Filter/Search Floating Button (Bottom-Right, Placeholder)**  
  - **Does**: Opens a blank screen for now.  
  - **When**: When tapped.  
  - **If wrong**: If screen fails to open, show alert and stay on map.

- **F-009 Profile/Settings Floating Button (Top-Right, Placeholder)**  
  - **Does**: Opens a blank screen for now.  
  - **When**: When tapped.  
  - **If wrong**: If screen fails to open, show alert and stay on map.

- **F-010 Dismiss Node View**  
  - **Does**: Close the slide-up panel by dragging it down, tapping outside it, or tapping the Back button on the panel.  
  - **When**: Anytime the panel is open.  
  - **If wrong**: If gesture fails, the Back button still works.

---

## 5) Screens (S-001 …)
- **S-001 Home Map**  
  - **What’s on it**: Full-screen map, dots/clusters, **Re-Center** (bottom-left), **Filter/Search** (bottom-right), **Profile/Settings** (top-right).  
  - **How to get here**: App launch. Back from any placeholder screen. Panel dismiss returns to this map.

- **S-002 Node View (Slide-Up Panel)**  
  - **What’s on it**: Back button (top-left of panel), Brewery **Name** (big), **Type** (e.g., “micro”, “brewpub”), **Address** (or “No Address Available”), **Phone** (if any), **Website** (if any; opens browser).  
  - **How to get here**: Tap a dot on **S-001**. Dismiss by drag down, tap outside, or Back button.

- **S-003 Filter/Search (Placeholder)**  
  - **What’s on it**: Empty page with a title “Filter & Search (Coming Soon)”. Back button.  
  - **How to get here**: Tap the bottom-right button on **S-001**.

- **S-004 Profile/Settings (Placeholder)**  
  - **What’s on it**: Empty page with a title “Profile & Settings (Coming Soon)”. Back button.  
  - **How to get here**: Tap the top-right button on **S-001**.

- **S-005 Friendly Location Popup (In-App Prompt)**  
  - **What’s on it**: Text: “Share your location for the best experience” and an **Okay** button.  
  - **How to get here**: First launch before Apple’s prompt. Also shown by **Re-Center** if location is off (then it shows a version with **Sure** and **No Thanks**).

- **S-006 Apple Location Prompt (System)**  
  - **What’s on it**: Apple’s built-in permission alert.  
  - **How to get here**: After **S-005** on first launch, or when the app asks again as allowed by iOS.

---

## 6) Data (D-001 …)
- **D-001 Places List from CSV**  
  - A list made from the bundled file with columns:  
    - `id`, `name`, `brewery_type`, `address_1`, `address_2`, `address_3`, `city`, `state_province`, `postal_code`, `country` (ignored for now), `phone`, `website_url`, `longitude`, `latitude`.  
  - We use `longitude` and `latitude` to place dots on the map.

- **D-002 Location Permission State**  
  - Values we care about: **Not Asked**, **Allowed**, **Denied**.

- **D-003 Current Selection**  
  - The place the user tapped (or **none**).

- **D-004 DTLA Center (Fallback)**  
  - A fixed point to center on when needed: **34.052235, -118.243683**.

*(No server data. All data is on the device.)*

---

## 7) Extra Details
1. **Internet**: Not required. Website taps open the phone’s web browser if there is a link.  
2. **Storage**: Data comes from the bundled `.csv`. No login. No cloud.  
3. **Permissions**: Location (While Using the App). If denied, app still works with DTLA center.  
4. **Dark Mode**: Yes, follow system setting.  
5. **Devices**: iPhone first. Portrait is fine.  
6. **Map Tool**: Uses Apple’s map (built-in).  
7. **Accessibility**: Buttons have clear labels. Text is readable.  
8. **Privacy**: User location is only used to show nearby places. It is not sent anywhere.
9. We're only dealing with California for now. The data is in california.csv which is in the top of the project directory. I've already placed it there.

---

## 8) Build Steps (B-001 …)
> Each step points back to items above

1. **B-001 Project Setup**  
   - Create SwiftUI app in Xcode. Add the bundled `california.csv` to the project (for **D-001**).

2. **B-002 Data Model & Loader**  
   - Parse the `california.csv` into a list (**F-001**, **D-001**).  
   - Handle bad rows by skipping and showing the simple alert if none load.

3. **B-003 Map Screen**  
   - Build **S-001** with a full-screen map (**F-003**).  
   - Add panning and zooming (default map behavior).  
   - Place dots for all valid places (**F-005**, **D-001**).

4. **B-004 Clustering**  
   - Turn on dot grouping when zoomed out (**F-005**).

5. **B-005 Location Flow**  
   - Add the friendly popup (**S-005**, **F-002**).  
   - Then show Apple’s prompt (**S-006**).  
   - Center on user if allowed, else center on DTLA (**F-004**, **D-004**).

6. **B-006 Floating Buttons**  
   - Add **Re-Center** (bottom-left) (**F-007**).  
   - Add **Filter/Search** (bottom-right) → **S-003** placeholder (**F-008**).  
   - Add **Profile/Settings** (top-right) → **S-004** placeholder (**F-009**).

7. **B-007 Node View Panel**  
   - On dot tap, show **S-002** slide-up panel with fields (**F-006**, **D-003**).  
   - Add dismiss by drag, outside tap, and Back button (**F-010**).  
   - Make website link open the browser; handle failure with an alert (**F-006**).

8. **B-008 Error & Empty States**  
   - CSV load error alert (**F-001**).  
   - No address → show “No Address Available” (**F-006**).  
   - No website/phone → hide those rows (**F-006**).  
   - Settings deep link from Re-Center popup when location is off (**F-007**).

9. **B-009 Polish & Checks**  
   - Make sure dark mode looks good (**Extra #4**).  
   - Check labels and hit targets for buttons (**Extra #7**).  
   - Light test on device and simulator.

---
