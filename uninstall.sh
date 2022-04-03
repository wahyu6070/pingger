LIST="
/data/media/0/pingger
/data/adb/pingger
/data/adb/service.d/pingger.sh
/data/data/com.termux/files/usr/bin/pingger
"

for I in $LIST; do
	rm -rf $I
done

sleep 30s
LIST_GMS="
	com.google.android.gms/com.google.android.gms.auth.managed.admin.DeviceAdminReceiver
	com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
	"
	
	for GMS6 in $LIST_GMS; do
		pm enable $GMS6
	done
