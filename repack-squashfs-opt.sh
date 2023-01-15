#!/bin/sh
#
# unpack, modify and re-pack the Xiaomi RM1800 firmware
# removes checks for release channel before starting dropbear
# remove crap xiaomeme stuffs
# 2020.07.20  darell tan
# 

set -e

IMG=$1
ROOTPW='$1$qtLLI4cm$c0v3yxzYPI46s28rbAYG//'  # "password"

[ -e "$IMG" ] || { echo "rootfs img not found $IMG"; exit 1; }

# verify programs exist
command -v unsquashfs &>/dev/null || { echo "install unsquashfs"; exit 1; }
mksquashfs -version >/dev/null || { echo "install mksquashfs"; exit 1; }

FSDIR=`mktemp -d /tmp/resquash-rootfs.XXXXX`
trap "rm -rf $FSDIR" EXIT

# test mknod privileges
mknod "$FSDIR/foo" c 0 0 2>/dev/null || { echo "need to be run with fakeroot"; exit 1; }
rm -f "$FSDIR/foo"

>&2 echo "unpacking squashfs..."
unsquashfs -f -d "$FSDIR" "$IMG"

>&2 echo "patching squashfs..."

# create /opt dir
mkdir "$FSDIR/opt"
chmod 755 "$FSDIR/opt"

# add global firmware language packages
cp -R ./language-packages/opkg-info/. $FSDIR/usr/lib/opkg/"info"
cp -R ./uci-defaults/. $FSDIR/etc/uci-defaults
cp -R ./base-translation/. $FSDIR/usr/lib/lua/luci/i18n
cat ./language-packages/languages.txt >>$FSDIR/usr/lib/opkg/status
chmod 755 $FSDIR/usr/lib/opkg/info/luci-i18n-*.prerm
chmod 755 $FSDIR/etc/uci-defaults/luci-i18n-*

# translate xiaomi stuff to English
sed -i 's/连接设备数量/Connected devices/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"
sed -i 's/连接设备数量/Connected devices/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"

sed -i 's/Wi-Fi名称/Wi-Fi name/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"
sed -i 's/Wi-Fi名称/Wi-Fi name/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"

sed -i 's/Wi-Fi密码/Password/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"
sed -i 's/Wi-Fi密码/Password/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"

sed -i 's/>设置/">Settings/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"
sed -i 's/>设置/">Settings/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"

sed -i 's/小米AIoT路由器 AX3600/Router AIoT Mi AX3600/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"
sed -i 's/小米AIoT路由器 AX3600/Router AIoT Mi AX3600/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"

sed -i "s/开启后，2.4G和5G将合并显示为同一个名称，路由器将优先为终端选择5G网络。合并名称后部分终端可能离线，需重新连接。/When the feature is on, 2.4G and 5G networks will share a name. The router will choose the best available signal. For example, it will switch to 5G network if the device is close, and to 2.4G network if it's far away. Brief interruptions may occur during the switch./g" "$FSDIR/usr/lib/lua/luci/view/web/setting/wifi.htm"
sed -i "s/开启后，2.4G和5G将合并显示为同一个名称，路由器将优先为终端选择5G网络。合并名称后部分终端可能离线，需重新连接。/When the feature is on, 2.4G and 5G networks will share a name. The router will choose the best available signal. For example, it will switch to 5G network if the device is close, and to 2.4G network if it's far away. Brief interruptions may occur during the switch./g" "$FSDIR/usr/lib/lua/luci/view/web/apsetting/wifi.htm"

sed -i "s/Wi-Fi 5 兼容模式/Wi-Fi 5 (802.11ac) compatibility mode/g" "$FSDIR/usr/lib/lua/luci/view/web/setting/wifi.htm"
sed -i "s/Wi-Fi 5 兼容模式/Wi-Fi 5 (802.11ac) compatibility mode/g" "$FSDIR/usr/lib/lua/luci/view/web/apsetting/wifi.htm"

sed -i 's/某些老设备对Wi-Fi6支持不好，可能扫描不到信号或者连接不上等。 开启此开关后，将会切换到Wi-Fi5模式，解决兼容问题。但同时会关闭Wi-Fi6的相关功能，如OFDMA，BSS Coloring等。/Some older devices are not compatible with Wi-Fi 6 and may have compatibility issues, such as Wi-Fi connection or scanning errors. Once this switch is turned on, the router will work in Wi-Fi 5 compatible mode to fix compatibility issues. It will also disable Wi-Fi 6 related features such as OFDMA, BSS colors, etc./g' "$FSDIR/usr/lib/lua/luci/view/web/setting/wifi.htm"
sed -i 's/某些老设备对Wi-Fi6支持不好，可能扫描不到信号或者连接不上等。 开启此开关后，将会切换到Wi-Fi5模式，解决兼容问题。但同时会关闭Wi-Fi6的相关功能，如OFDMA，BSS Coloring等。/Some older devices are not compatible with Wi-Fi 6 and may have compatibility issues, such as Wi-Fi connection or scanning errors. Once this switch is turned on, the router will work in Wi-Fi 5 compatible mode to fix compatibility issues. It will also disable Wi-Fi 6 related features such as OFDMA, BSS colors, etc./g' "$FSDIR/usr/lib/lua/luci/view/web/apsetting/wifi.htm"

sed -i 's/AIoT智能天线自动扫描功能可以自动发现未初始化的小米智能设备，通过米家APP快速入网。/AIoT smart antenna auto scan can automatically find uninitialized Mi smart devices and quickly connect with them through the Mi Home app./g' "$FSDIR/usr/lib/lua/luci/view/web/setting/wifi.htm"
sed -i 's/AIoT智能天线自动扫描功能可以自动发现未初始化的小米智能设备，通过米家APP快速入网。/AIoT smart antenna auto scan can automatically find uninitialized Mi smart devices and quickly connect with them through the Mi Home app./g' "$FSDIR/usr/lib/lua/luci/view/web/apsetting/wifi.htm"

sed -i 's/此功能可能在网络拥塞的环境下导致网络出现一定的丢包变多及延时提高的问题。/This feature can cause some packet loss and increased latency in congested environments./g' "$FSDIR/usr/lib/lua/luci/view/web/setting/wifi.htm"
sed -i 's/此功能可能在网络拥塞的环境下导致网络出现一定的丢包变多及延时提高的问题。/This feature can cause some packet loss and increased latency in congested environments./g' "$FSDIR/usr/lib/lua/luci/view/web/apsetting/wifi.htm"

sed -i 's/:畅快连/:Xiaomi Easy Connect/g' "$FSDIR/usr/lib/lua/luci/view/web/setting/wifi.htm"
sed -i 's/:畅快连/:Xiaomi Easy Connect/g' "$FSDIR/usr/lib/lua/luci/view/web/apsetting/wifi.htm"

sed -i 's/时区设置/Region and Time/g' "$FSDIR/usr/lib/lua/luci/view/web/inc/sysinfo_ap.htm"
sed -i 's/时区设置/Region and Time/g' "$FSDIR/usr/lib/lua/luci/view/web/inc/sysinfo.htm"

sed -i "s/开启此功能，路由器可自动发现支持畅快连的未初始化Wi-Fi设备，通过米家APP快速配网；修改路由器密码也将自动同步给支持畅快连的设备。/With this feature enabled, the router can automatically discover uninitialized Wi-Fi devices that support Xiaomi Easy Connect and quickly pair them with the network through the Mi Home App; changing the router's password will also automatically sync with devices that support Xiaomi Easy Connect./g" "$FSDIR/usr/lib/lua/luci/view/web/setting/wifi.htm"

sed -i "s/路由器正常工作情况下建议使用小米WiFi App进行安装，当安装失败或需要降级到前一版本时使用手动安装插件。/When the router is working normally, it is recommended to use the Xiaomi WiFi App to install it. When the installation fails or needs to be downgraded to the previous version, use the manual installation plug-in./g" "$FSDIR/usr/lib/lua/luci/view/web/setting/upgrade.htm"

sed -i 's/路由状态/Status/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"
sed -i 's/路由状态/Status/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"
sed -i 's/常用设置/Default Settings/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"
sed -i 's/常用设置/Default Settings/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"
sed -i 's/高级设置/Advanced Settingss/g' "$FSDIR/usr/lib/lua/luci/view/web/apindex.htm"
sed -i 's/高级设置/Advanced Settings/g' "$FSDIR/usr/lib/lua/luci/view/web/index.htm"


# modify dropbear init
sed -i 's/channel=.*/channel=release2/' "$FSDIR/etc/init.d/dropbear"
sed -i 's/flg_ssh=.*/flg_ssh=1/' "$FSDIR/etc/init.d/dropbear"

# mark web footer so that users can confirm the right version has been flashed
sed -i 's/romVersion%>/& acexqr-opt-eng/;' "$FSDIR/usr/lib/lua/luci/view/web/inc/footer.htm"

# stop resetting root password
sed -i '/set_user(/a return 0' "$FSDIR/etc/init.d/system"
sed -i 's/flg_init_pwd=.*/flg_init_pwd=0/' "$FSDIR/etc/init.d/boot_check"

# make sure our backdoors are always enabled by default
sed -i '/ssh_en/d;' "$FSDIR/usr/share/xiaoqiang/xiaoqiang-reserved.txt"
sed -i '/ssh_en=/d; /uart_en=/d; /boot_wait=/d;' "$FSDIR/usr/share/xiaoqiang/xiaoqiang-defaults.txt"
cat <<XQDEF >> "$FSDIR/usr/share/xiaoqiang/xiaoqiang-defaults.txt"
uart_en=1
ssh_en=1
boot_wait=on
XQDEF

# always reset our access nvram variables
grep -q -w enable_dev_access "$FSDIR/lib/preinit/31_restore_nvram" || \
 cat <<NVRAM >> "$FSDIR/lib/preinit/31_restore_nvram"
enable_dev_access() {
	nvram set uart_en=1
	nvram set ssh_en=1
	nvram set boot_wait=on
	nvram commit
}

boot_hook_add preinit_main enable_dev_access
NVRAM

# modify root password
sed -i "s@root:[^:]*@root:${ROOTPW}@" "$FSDIR/etc/shadow"

# stop phone-home in web UI
cat <<JS >> "$FSDIR/www/js/miwifi-monitor.js"
(function(){ if (typeof window.MIWIFI_MONITOR !== "undefined") window.MIWIFI_MONITOR.log = function(a,b) {}; })();
JS

# add xqflash tool into firmware for easy upgrades
cp xqflash "$FSDIR/sbin"
chmod 0755      "$FSDIR/sbin/xqflash"
chown root:root "$FSDIR/sbin/xqflash"

# dont start crap services
for SVC in stat_points statisticsservice \
		datacenter \
		smartcontroller \
		plugincenter plugin_start_script.sh cp_preinstall_plugins.sh; do
	rm -f $FSDIR/etc/rc.d/[SK]*$SVC
done

# prevent stats phone home & auto-update
for f in StatPoints mtd_crash_log logupload.lua otapredownload wanip_check.sh; do > $FSDIR/usr/sbin/$f; done

rm -f $FSDIR/etc/hotplug.d/iface/*wanip_check

for f in wan_check messagingagent.sh; do
	sed -i '/start_service(/a return 0' $FSDIR/etc/init.d/$f
done

# cron jobs are mostly non-OpenWRT stuff
for f in $FSDIR/etc/crontabs/*; do
	sed -i 's/^/#/' $f
done

# as a last-ditch effort, change the *.miwifi.com hostnames to localhost
sed -i 's@\w\+.miwifi.com@localhost@g' $FSDIR/etc/config/miwifi

# get hardware name
HWNAME=`sed -n "/option\s\+HARDWARE/ s/.*'\(.*\)'/\1/g p" $FSDIR/usr/share/xiaoqiang/xiaoqiang_version`
[ -n "$HWNAME" ] && echo "detected hw $HWNAME" || echo "[WARN] cant find hw name in firmware"

# apply hw-specific patches
PATCHES=
[ -n "$HWNAME" ] && [ -d "patches-$HWNAME" ] && PATCHES=patches-$HWNAME/*.patch

# generic patches
[ -d patches ] && PATCHES="$PATCHES patches/*.patch"

# apply patches
for p in $PATCHES; do
	>&2 echo "applying patch $p..."
	patch -d "$FSDIR" -s -p1 < $p

	[ $? -ne 0 ] && { echo "patch $p didnt apply cleanly - aborting."; exit 1; }
done

>&2 echo "repacking squashfs..."
rm -f "$IMG.new"
mksquashfs "$FSDIR" "$IMG.new" -comp xz -b 256K -no-xattrs
