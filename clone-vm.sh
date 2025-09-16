#!/bin/sh
 
if [ "$1" = "" ] || [ "$2" = "" ] || [ "$1" = "--help" ] || [ "$1" = "-help" ] || [ "$1" = "-h" ]; then
        echo "Usage:"
        echo -e "\t $0 <destination> <new name>"
        echo
        echo -e "\t* run this script inside a directory containing vm guest"
        echo
        echo "Example:"
        echo -e "\t cd /vmfs/volumes/MyStorage/ExistingVm"
        echo -e "\t $0 /vmfs/volumes/MyStorage/NewVmMachine New_Machine_Name"
        echo
 
        exit 1
fi
 
VMX_COUNT=$(ls *.vmx 2>/dev/null | grep -c -e ".vmx$")
 
if [ "$VMX_COUNT" -gt 1 ]; then
        echo "ERROR! Too many VMX files here"
        exit 1
elif [ "$VMX_COUNT" -lt 1 ]; then
        echo "ERROR! VMX file not found here"
        exit 1
fi
 
VMDK_COUNT=$(ls *.vmdk 2>/dev/null | grep -v -e "-flat.vmdk$" | grep -c -e ".vmdk$")
 
if [ "$VMDK_COUNT" -gt 1 ]; then
        echo "ERROR! Too many VMDK files here"
        exit 1
elif [ "$VMDK_COUNT" -lt 1 ]; then
        echo "ERROR! VMDK file not found here"
        exit 1
fi
 
VMX_PREFIX=$(ls *.vmx 2>/dev/null | grep vmx | sed "s/.vmx$//g")
VMDK_PREFIX=$(ls *.vmdk 2>/dev/null | grep -v -e "-flat.vmdk$" | grep -e ".vmdk$" | sed "s/.vmdk$//g")
 
echo "Using:"
echo -e "\tVMX  = ${VMX_PREFIX}.vmx"
echo -e "\tVMDK = ${VMDK_PREFIX}.vmdk"
 
DST="$1"
NEW_NAME="$2"
 
mkdir -p "$DST" || exit 1
 
echo "cp ./${VMX_PREFIX}.nvram -> ${DST}/${NEW_NAME}.nvram"
cp "./$VMX_PREFIX.nvram" "$DST/$NEW_NAME.nvram" || exit 1
 
echo "cp ./${VMX_PREFIX}.vmsd -> ${DST}/${NEW_NAME}.vmsd"
cp "./$VMX_PREFIX.vmsd" "$DST/$NEW_NAME.vmsd" || exit 1
 
[ -e "./$VMX_PREFIX.vmxf" ] && echo "cp ./${VMX_PREFIX}.vmxf -> ${DST}/${NEW_NAME}.vmxf"
[ ! -e "./$VMX_PREFIX.vmxf" ] || cp "./$VMX_PREFIX.vmxf" "$DST/$NEW_NAME.vmxf" || exit 1
 
vmkfstools --clonevirtualdisk "./$VMDK_PREFIX.vmdk" --diskformat thin "$DST/$NEW_NAME.vmdk"
 
cat "./$VMX_PREFIX.vmx" | sed -e "s/$VMDK_PREFIX\.vmdk/$NEW_NAME.vmdk/g" > "$DST/$NEW_NAME.vmx"
sed -ie "s/$VMX_PREFIX/$NEW_NAME/g" "$DST/$NEW_NAME.vmx"
