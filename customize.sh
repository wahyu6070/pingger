# Pingger
# By wahyu6070

chmod 755 $MODPATH/bin/functions
. $MODPATH/bin/functions

#functions
GET_PROFILE(){
	getp "$1" "$PROFILE"
	}
IFON(){
	if [ $(GET_PROFILE "$1") = ON ]; then
		return 0
	fi
	return 1
	}
SEDPROP(){
	echo "$1" >> $MODPATH/system.prop
	}
#variable
PINGGER=/data/media/0/pingger
PROFILE=$PINGGER/pingger.profile
MODPROP=$MODPATH/system.prop
log=$PINGGER/pingger.log
device_info



if [ -f /system_root/system/build.prop ]; then
	SYSTEM=/system_root/system 
elif [ -f /system_root/build.prop ]; then
	SYSTEM=/system_root
elif [ -f /system/system/build.prop ]; then
	SYSTEM=/system/system
else
	SYSTEM=/system
fi

if [ ! -L $SYSTEM/vendor ]; then
	VENDOR=$SYSTEM/vendor
else
	VENDOR=/vendor
fi

# /product dir (android 10+)
if [ ! -L $SYSTEM/product ]; then
	PRODUCT=$SYSTEM/product
else
	PRODUCT=/product
fi

# /system_ext dir (android 11+)
if [ ! -L $SYSTEM/system_ext ]; then
	SYSTEM_EXT=$SYSTEM/system_ext
else
	SYSTEM_EXT=/system_ext
fi

VENDOR=/vendor

test ! -d $PINGGER && cdir $PINGGER
del $log

#profile
if [ ! -f  $PROFILE ]; then
	cp -pf $MODPATH/bin/pingger.profile $PROFILE
elif [[ $(GET_PROFILE pingger.code) != $MODULECODE ]]; then
	cp -pf $MODPATH/bin/pingger.profile $PROFILE
fi


if [ -d /data/data/com.termux ]; then
	printlog "- Termux detected"
	printlog "- Installing Pingger control in Termux"
	cp -pf $MODPATH/system/bin/pingger /data/data/com.termux/files/usr/bin/
	chmod 775 /data/data/com.termux/files/usr/bin/pingger
fi

#magiskboot
if [ -f /data/adb/magisk/magiskboot ]; then
	sedlog "Copying magiskboot in xbin"
	mkdir -p $MODPATH/system/xbin
	cp -pf /data/adb/magisk/magiskboot $MODPATH/system/xbin/
	chmod 775 $MODPATH/system/xbin/magiskboot
fi


if IFON Unlock120fpsML; then
SEDPROP "# Unlock 120 fps ml"
SEDPROP "ro.product.brand=Xiaomi"
SEDPROP "ro.product.manufacturer=Xiaomi"
SEDPROP "ro.product.marketname=Mi 11 Ultra"
SEDPROP "ro.product.model=M2102K1G"
SEDPROP "ro.product.odm.brand=Xiaomi"
SEDPROP "ro.product.odm.manufacturer=Xiaomi"
SEDPROP "ro.product.odm.marketname=Mi 11 Ultra"
SEDPROP "ro.product.odm.model=M2102K1G"
SEDPROP "ro.product.product.brand=Xiaomi"
SEDPROP "ro.product.product.manufacturer=Xiaomi"
SEDPROP "ro.product.product.marketname=Mi 11 Ultra"
SEDPROP "ro.product.product.model=M2102K1G"
SEDPROP "ro.product.system.brand=Xiaomi"
SEDPROP "ro.product.system.manufacturer=Xiaomi"
SEDPROP "ro.product.system.marketname=Mi 11 Ultra"
SEDPROP "ro.product.system.model=M2102K1G"
SEDPROP "ro.product.system_ext.brand=Xiaomi"
SEDPROP "ro.product.system_ext.manufacturer=Xiaomi"
SEDPROP "ro.product.system_ext.marketname=Mi 11 Ultra"
SEDPROP "ro.product.system_ext.model=M2102K1G"
SEDPROP "ro.product.vendor.brand=Xiaomi"
SEDPROP "ro.product.vendor.manufacturer=Xiaomi"
SEDPROP "ro.product.vendor.marketname=Mi 11 Ultra"
SEDPROP "ro.product.vendor.model=M2102K1G"
SEDPROP " "
fi

case $(GET_PROFILE GPUrendering) in
1)
printlog "- Set GPU To OpenGl ES"
SEDPROP "debug.hwui.renderer=opengl"
;;
2)
printlog "- Set GPU To OpenGl Skia"
SEDPROP "debug.hwui.renderer=skiagl"
;;
3)
printlog "- Set GPU To OpenGl Skia"
SEDPROP "debug.hwui.renderer=skiavk"
;;
esac

case $(GET_PROFILE OpenGLES) in
1)
printlog "- OpenGL ES 3.0 Active"
SEDPROP "ro.opengles.version=196608"
;;
2)
printlog "- OpenGL ES 3.1 Active"
SEDPROP "ro.opengles.version=196609"
;;
3)
printlog "- OpenGL ES 3.2 Active"
SEDPROP "ro.opengles.version=196610"
;;
esac


if IFON SmoothStreaming; then
	SEDPROP "mm.enable.smoothstreaming=true"
fi

case $(GET_PROFILE APNset) in
1)
print "- Using APN CAF"
APN=$MODPATH/bin/apn/caf
;;
2)
print "- Using APN AOSP"
APN=$MODPATH/bin/apn/aosp
;;
3)
print "- Using APN LineAge"
APN=$MODPATH/bin/apn/lineage
;;
esac


if IFON Camera2api; then
printlog "- Enable Camera2api"
SEDPROP "persist.camera.HAL3.enabled=1"
SEDPROP "persist.vendor.camera.HAL3.enabled=1"
SEDPROP "persist.camera.eis.enable=1"
fi
if [ -f $PRODUCT/etc/apns-conf.xml ]; then
	cdir $MODPATH/system/product/etc
	cp -pf $APN $MODPATH/system/product/etc/apns-conf.xml
	SET_PERM_FILE $MODPATH/system/product/etc/apns-conf.xml
elif [ -f $SYSTEM_EXT/etc/apns-conf.xml ]; then
	cdir $MODPATH/system/system_ext/etc
	cp -pf $APN $MODPATH/system/system_ext/etc/apns-conf.xml
	SET_PERM_FILE $MODPATH/system/system_ext/etc/apns-conf.xml
else
	cdir $MODPATH/system/etc
	cp -pf $APN $MODPATH/system/etc/apns-conf.xml
	SET_PERM_FILE $MODPATH/system/etc/apns-conf.xml
fi


if IFON WifiBonding; then
	printlog "- Enabling Wifi Bonding"
	for U in $(find $VENDOR -name WCNSS_qcom_cfg.ini); do
		if [ -f $U ] && [ ! -L $U ]; then
			cdir $MODPATH/system$(dirname $U)
			cp -pf $U $MODPATH/system$U
			sed -i '/gChannelBondingMode24GHz=/d;/gChannelBondingMode5GHz=/d;/gForce1x1Exception=/d;s/^END$/gChannelBondingMode24GHz=1\ngChannelBondingMode5GHz=1\ngForce1x1Exception=0\nEND/g' $MODPATH/system$U
			chcon -h u:object_r:vendor_configs_file:s0 $MODPATH/system$U
		fi
	done
fi

if IFON Logs; then
	printlog "- Disabling Logs"
	cat $MODPATH/bin/tweaks/logs >> $MODPROP
fi

if IFON HSPA; then
	printlog "- 3G/HSPA+ signal + speed"
	cat $MODPATH/bin/tweaks/3g >> $MODPROP
fi

if IFON DisableThermal; then
	LIST_CNF="
	thermal-engine.conf
	thermal-engine
	thermal.sdm660.so
	"
	for T6 in $LIST_CNF; do
		for R7 in $(find $VENDOR -name $T6); do
			if [ -f $R7 ] && [ ! -L $R7 ]; then
				cdir $MODPATH/system$(dirname $R7)
				touch $MODPATH/system$R7
			fi
		done
	done
fi

if IFON ErrorChecking; then
	printlog "- Disabling Error Checking"
	cat $MODPATH/bin/tweaks/disable_error_checking >> $MODPROP
fi

if IFON Volwifi; then
	printlog "- Enable Vowifi And Volte"
	cat $MODPATH/bin/tweaks/volte_vowifi >> $MODPROP
fi

if IFON ScrollingImprovement; then
	printlog "- Improvement Scrolling"
	cat $MODPATH/bin/tweaks/improvement_scrolling >> $MODPROP
fi

if IFON TouchSceenImprovement; then
	printlog "- Improvement Touch"
	cat $tmp/bin/tweaks/touch_improvement >> $MODPROP
fi

if IFON DataUsage; then
	printlog "- Disabling Data Usage Shared"
	cat $MODPATH/bin/tweaks/share_data >> $MODPROP
fi

if IFON PersistantNotif; then
	printlog "- Disable Persistant Notification"
	cat $MODPATH/bin/tweaks/disable_persistant_notications >> $MODPROP
fi


if [ -f $PINGGER/bootanimation.zip ]; then
	printlog "- Bootanimation.zip detected installing"
	if [ -f $SYSTEM/media/bootanimation.zip ]; then
	    mkdir -p $MODPATH/system/media
	    sedlog "Using /system/media/bootanimation.zip"
		cp -pf $PINGGER/bootanimation.zip $MODPATH/system/media/
	elif [ -f $PRODUCT/media/bootanimation.zip ]; then
	    mkdir -p $MODPATH/system/product/media
	    sedlog "Using /system/product/media/bootanimation.zip"
		cp -pf $PINGGER/bootanimation.zip $MODPATH/system/product/media/
	else
		sedlog "Bootanimation.zip Media not support"
	fi
fi

#service.d
del /data/adb/service.d/pingger.sh
cp -pf $MODPATH/bin/pingger.sh /data/adb/service.d/pingger.sh
chmod 755 /data/adb/service.d/pingger.sh
#pingger controller
chmod 755 $MODPATH/system/pingger
print " "
print "*tips"
print "- open terminal"
print "- su (enter)"
print "- pingger (enter)"
print " "
print "- Edit /sdcard/pingger/pingger.profile for Disable/enable features"
print " "

