#Pingger
#by wahyu6070
sleep 30s

#functions
GET_PROFILE(){
	grep "^$1" "$PROFILE" | head -n1 | cut -d = -f 2
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
APP_LIST(){
	pm list packages | grep -q "$1"
	}
#variable
PINGGER=/data/media/0/pingger
PROFILE=$PINGGER/pingger.profile

	
if IFON DisableUpdater; then
	if APP_LIST org.lineageos.updater; then 
		pm disable org.lineageos.updater
	fi

	if APP_LIST com.aospextended.ota; then 
		pm disable com.aospextended.ota
	fi
fi


LIST_GMS="
	com.google.android.gms/com.google.android.gms.auth.managed.admin.DeviceAdminReceiver
	com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
	"
if IFON GmsDose; then
	for GMS6 in $LIST_GMS; do
		pm disable $GMS6
	done
else
	for GMS6 in $LIST_GMS; do
		pm enable $GMS6
	done
fi

if IFON Permissive; then
	setenforce 0
fi

