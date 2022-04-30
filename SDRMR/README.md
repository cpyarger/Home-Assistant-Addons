# SDR Meter Reader hass.io addon
A hass.io addon for a software defined radio tuned to listen for Utility Meter RF transmissions and republish the data via Home Assistant's API

- This hassio addon is based on  JDeath's [RTLAMR2MQTT](https://github.com/jdeath/RTLAMR2MQQT/tree/master/RTLAMR2MQQT) addon
- Which is based on biochemguy's [(non-docker) setup](https://community.home-assistant.io/t/get-your-smart-electric-water-and-gas-meter-scm-readings-into-home-assistant-with-a-rtl-sdr)
- This hass.io addon is based on James Fry' [project](https://github.com/james-fry/hassio-addons/tree/master/rtl4332mqtt)
- which was based on Chris Kacerguis' [project](https://github.com/chriskacerguis/honeywell2mqtt)
- which is in turn based on Marco Verleun's [rtl2mqtt image](https://github.com/roflmao/rtl2mqtt)

## Usage

1) Install the addon. Do this by either:
    - Downloading this repository and adding in a folder under /addons/ (eg. /addons/sdrmr)
    - Adding this respository to the Add-on Store

2) Use the addon configuration page to setup:
    - msgType (RTLAMR Message type; see below)
    - ids* (IDs of the sensors you want to watch)
    - pause_time (Time between Readings in seconds)

3) Start the addon

### Message Types

The following message types are supported by rtlamr:

- **scm**: Standard Consumption Message. Simple packet that reports total consumption.
- **scm+**: Similar to SCM, allows greater precision and longer meter ID's.
- **idm**: Interval Data Message. Provides differential consumption data for previous 47 intervals at 5 minutes per interval.
- **netidm**: Similar to IDM, except net meters (type 8) have different internal packet structure, number of intervals and precision. Also reports total power production.
- **r900**: Message type used by Neptune R900 transmitters, provides total consumption and leak flags.
- **r900bcd**: Some Neptune R900 meters report consumption as a binary-coded digits.
- **all**: Listen for ALL of the above message types

## Hardware

This has been tested and used with the following hardware (you can get it on Amazon)

- NooElec NESDR Nano 2+ Tiny Black RTL-SDR USB
- RTL-SDR Blog R820T2 RTL2832U 1PPM TCXO SMA Software Defined Radio


## Troubleshooting

If you see this error:

> Kernel driver is active, or device is claimed by second instance of librtlsdr.
> In the first case, please either detach or blacklist the kernel module
> (dvb_usb_rtl28xxu), or enable automatic detaching at compile time.

Then run the following command on the host

```bash
sudo rmmod dvb_usb_rtl28xxu rtl2832
```

## Posting a bug report, or adding more data from your meters. 
I only have a couple meters on my house, so I don't have example data to get all the sensors right, 

If you need me to make any changes please turn on debug mode in the config, and post a snippit of your logs to a github issue
