# Troll SIM Switcher

TrollSIMSwitcher brings true one-tap SIM control to iOS.  
Switch your cellular data between SIMs instantly, toggle 4G/5G, and access all functions directly from shortcuts and widgets—no need to dig through Settings.

**Features**
- Dual SIM data switching with a single tap
- Switch between 4G(LTE) / 5G modes instantly
- Home Screen quick actions for ultra-fast access
- Lock Screen widgets (iOS 16+) for convenient toggling
- Shortcuts integration (iOS 16+) — automate SIM switching, create Siri triggers, and more

🔔Compatibility Switch Mode (Important)  
Some iPhone models report dual-SIM slot order inconsistently through iOS APIs.  
This can cause cases where switching data SIM does nothing.  
If tapping “Switch SIM” does not work as expected, enable Compatibility Switch Mode in the app.  

Observed examples:
- On devices with physical SIM + eSIM, if the physical SIM happens to be assigned to IMEI 2, iOS may internally reverse the slot mapping.
- f the SIM order shown in Settings → Cellular does not match the SIM order detected by the app, switching may fail.

Turning on Compatibility Switch Mode corrects this mismatch and restores proper SIM switching behavior.

<img width="300" alt="IMG_8704" src="https://github.com/user-attachments/assets/b3d06a05-5daa-4782-81e4-ca52f3821a9a" />
<img width="300" alt="IMG_8704" src="https://github.com/user-attachments/assets/f4e72534-74d6-42cc-8011-520c5e19730e" />
