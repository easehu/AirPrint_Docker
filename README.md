# easehu/debian:AirPrint

This Debian:latest Docker image runs a CUPS instance that is meant as an AirPrint relay for printers that are already on the network but not AirPrint capable. I forked the original to use Debian instead of Ubuntu and work on more host OS's.

## Clone git source
* git source file to your system
```
git clone https://github.com/easehu/AirPrint_Docker.git
```

## Build command:
```
cd AirPrint_Docker
docker build -t debian:AirPrint .
```

## Configuration
### Volumes:
* `/config`: where the persistent printer configs will be stored
* `/services`: where the Avahi service files will be generated

### Variables:
* `CUPSADMIN`: the CUPS admin user you want created - default is CUPSADMIN if unspecified
* `CUPSPASSWORD`: the password for the CUPS admin user - default is admin username if unspecified

### Ports/Network:
* Must be run on host network. This is required to support multicasting which is needed for Airprint.

### Example run command:
```
docker run -itd --name AirPrint \
  --restart unless-stopped \
  --net host \
  --privileged=true \
  -v <your services dir>:/services \
  -v <your config dir>:/config \
  -e CUPSADMIN="<username>" \
  -e CUPSPASSWORD="<password>" \
  -p 631:631/tcp -p 5353:5353/udp \
  -v /dev:/dev \
  debian:AirPrint
```

## Add and set up printer:
* CUPS will be configurable at http://[host ip]:631 using the CUPSADMIN/CUPSPASSWORD.

* Make sure you select Share This Printer when configuring the printer in CUPS.

* ***After configuring your printer, you need to wait 10 seconds and then restart your docker container. Otherwise, the printer will not be displayed on phone priner list.***

## Important
* ***After configuring your printer, you need to close the web browser for at least 60 seconds. CUPS will not write the config files until it detects the connection is closed for as long as a minute.***

