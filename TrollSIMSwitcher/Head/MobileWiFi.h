//
//  MobileWiFi.h — Full SPI Header
//

#ifndef MobileWiFi_h
#define MobileWiFi_h

#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark - Basic Types

typedef struct __WiFiManager* WiFiManagerRef;
typedef struct __WiFiDeviceClient* WiFiDeviceClientRef;
typedef struct __WiFiNetwork* WiFiNetworkRef;

#pragma mark - Manager API

// Create manager
WiFiManagerRef WiFiManagerClientCreate(CFAllocatorRef allocator, int flags);

// Manager property
CFPropertyListRef WiFiManagerClientCopyProperty(WiFiManagerRef manager, CFStringRef property);

// Low-level SPI
void WiFiManagerClientSetProperty(WiFiManagerRef manager, CFStringRef key, CFTypeRef value, CFTypeRef extra);

// Create a WiFiManager client
WiFiManagerRef WiFiManagerClientCreate(CFAllocatorRef allocator, int32_t flags);

// Copy all device clients (usually returns only 1 device)
CFArrayRef WiFiManagerClientCopyDevices(WiFiManagerRef manager);

// Get Wi-Fi power state (0 = off, 1 = on)
int32_t WiFiDeviceClientGetPower(WiFiDeviceClientRef device);

// Set Wi-Fi power state (0 = off, 1 = on)
void WiFiDeviceClientSetPower(WiFiDeviceClientRef device, int32_t power);


// Devices
CFArrayRef WiFiManagerClientCopyDevices(WiFiManagerRef manager);

// Networks (scan result)
CFArrayRef WiFiManagerClientCopyNetworks(WiFiManagerRef manager);

// Join / remove network
Boolean WiFiManagerClientAssociateNetwork(WiFiManagerRef manager, WiFiNetworkRef network, CFDictionaryRef options);
Boolean WiFiManagerClientDisassociateNetwork(WiFiManagerRef manager);

// Save / Forget
Boolean WiFiManagerClientUpdateNetwork(WiFiManagerRef manager, WiFiNetworkRef network);
Boolean WiFiManagerClientRemoveNetwork(WiFiManagerRef manager, WiFiNetworkRef network);

// Scan control
Boolean WiFiManagerClientScan(WiFiManagerRef manager);
Boolean WiFiManagerClientStopScan(WiFiManagerRef manager);

// Get current user Auto-Join state
int WiFiManagerClientGetUserAutoJoinState(WiFiManagerRef manager);

// Enable user Auto-Join
int WiFiManagerClientEnableUserAutoJoin(WiFiManagerRef manager);

// Disable user Auto-Join
int WiFiManagerClientDisableUserAutoJoin(WiFiManagerRef manager);

#pragma mark - Device API

// Create WiFi device interface
WiFiDeviceClientRef WiFiDeviceClientCreate(CFAllocatorRef allocator);

// Get / Set Wi-Fi device properties
CFPropertyListRef WiFiDeviceClientCopyProperty(WiFiDeviceClientRef device, CFStringRef property);
Boolean WiFiDeviceClientSetProperty(WiFiDeviceClientRef device, CFStringRef property, CFPropertyListRef value);

// Device properties (RSSI / noise / channel / PHY mode)
int WiFiDeviceClientGetRSSI(WiFiDeviceClientRef device);
int WiFiDeviceClientGetNoise(WiFiDeviceClientRef device);
int WiFiDeviceClientGetTxRate(WiFiDeviceClientRef device);
int WiFiDeviceClientGetChannel(WiFiDeviceClientRef device);
int WiFiDeviceClientGetActivePHYMode(WiFiDeviceClientRef device);

#pragma mark - Network API

// Network copy properties
CFStringRef WiFiNetworkGetSSID(WiFiNetworkRef network);
CFStringRef WiFiNetworkGetBSSID(WiFiNetworkRef network);
int WiFiNetworkGetChannel(WiFiNetworkRef network);
int WiFiNetworkGetSignalStrength(WiFiNetworkRef network);

// Flags: secured / hidden / saved
Boolean WiFiNetworkIsWEP(WiFiNetworkRef network);
Boolean WiFiNetworkIsWPA(WiFiNetworkRef network);
Boolean WiFiNetworkIsEAP(WiFiNetworkRef network);
Boolean WiFiNetworkIsHidden(WiFiNetworkRef network);
Boolean WiFiNetworkIsSaved(WiFiNetworkRef network);
Boolean WiFiNetworkIsAdHoc(WiFiNetworkRef network);

// Password
CFStringRef WiFiNetworkCopyPassword(WiFiNetworkRef network);
Boolean WiFiNetworkSetPassword(WiFiNetworkRef network, CFStringRef password);

// Convert network → dictionary
CFDictionaryRef WiFiNetworkCopyRecord(WiFiNetworkRef network);

// Create network from dictionary (rare cases)
WiFiNetworkRef WiFiNetworkCreate(CFAllocatorRef allocator, CFDictionaryRef record);

#pragma mark - Common Keys

static const CFStringRef kWiFiManagerPowerKey            = CFSTR("Power");
static const CFStringRef kWiFiManagerNetworksKey         = CFSTR("Networks");
static const CFStringRef kWiFiDevicePropertyPower        = CFSTR("Power");
static const CFStringRef kWiFiDevicePropertyCommittedPower = CFSTR("CommittedPower");
static const CFStringRef kWiFiDevicePropertyChannel      = CFSTR("Channel");
static const CFStringRef kWiFiDevicePropertyRSSI         = CFSTR("RSSI");
static const CFStringRef kWiFiDevicePropertyNoise        = CFSTR("Noise");

#ifdef __cplusplus
}
#endif

#endif /* MobileWiFi_h */
