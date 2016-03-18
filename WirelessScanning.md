# THSuite #

---


---

# Wireless Scanning #

---

This option makes use of airodump-ng to scan for wireless networks.

---

On selecting wireless scanning from the main menu, you are prompted to enter a monitor interface or warned if none exist.

---

You are then prompted to either enter scan settings or use the default settings;
  * Channel to scan on (default is all channels)
  * If you chose the default(scanning on all channels), you will be prompted for a channel hop delay in seconds or skip (hit Enter) to use airodump-ng's default.
  * Scan time (default is no limit)

---

airodump-ng will then be opened in an xterm window which will either stop after the entered scan time, or if scan time was left as default, continue until stopped with Ctrl-C.

---

![http://i94.photobucket.com/albums/l112/TAPE_RULEZ/5705cb40-5fd6-4c09-8095-2db667774538_zpsa1d47f0b.jpg](http://i94.photobucket.com/albums/l112/TAPE_RULEZ/5705cb40-5fd6-4c09-8095-2db667774538_zpsa1d47f0b.jpg)

---


Scan results will be saved as date-time files (ex. 20130101-1800-01.csv) in the /root/THS\_TMP/ directory.

---


---

# Wiki Links #

---

  * https://code.google.com/p/thsuite/wiki/WIKIGeneral
  1. https://code.google.com/p/thsuite/wiki/WirelessInterfaces
  1. https://code.google.com/p/thsuite/wiki/MacAddressManipulation
  1. https://code.google.com/p/thsuite/wiki/WirelessScanning
  1. https://code.google.com/p/thsuite/wiki/ViewScansCaptures
  1. https://code.google.com/p/thsuite/wiki/ManualAssistedHandshakeAcquisition
  1. https://code.google.com/p/thsuite/wiki/WirelessDisruption
  1. https://code.google.com/p/thsuite/wiki/Miscellaneous