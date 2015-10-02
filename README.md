# rrd_hddtemp
For ARM based Buffalo Linkstation NAS.

pulled from: https://josephlo.wordpress.com/2011/04/26/installing-rrdtool-on-buffalo-quad-pro/

Linkstation, by default, stores all user content in ```/mnt/array1``` whether you have RAID0 or RAID1. It is very rare for the device to use ```/mnt/disk1``` so if you have this, open the script in VI and use the ```[ESC]``` command ```:%s/array1/disk1/g```

To keep things mostly portable, you will need to have a share named ```Web``` and use this in your configuration of the ```Network > Web Server``` tab in the Buffalo webgui.

```mkdir /opt/var/lib/rrd```
```mkdir /mnt/disk1/Web/rrd```

THIS IS NOT COMPLETE
Please visit https://josephlo.wordpress.com/2011/04/26/installing-rrdtool-on-buffalo-quad-pro/
