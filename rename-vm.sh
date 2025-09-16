#!/bin/sh
 
if [ "$1" = "" ] || [ "$1" = "-help" ] || [ "$1" = "-h" ]; then
        echo "Usage:"
        echo -e "\t $0 <new name>"
        echo
        echo -e "\t* run this script inside a directory containing vm guest"
        echo
        echo "Example:"
        echo -e "\t cd /vmfs/volumes/MyStorage/ExistingVm"
        echo -e "\t $0 New_Machine_Name"
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
 
NEW_NAME="$1"

if [ "$1" = "$VMX_PREFIX" ]; then
    echo "New name is already used here. Nothing to do"

    exit 1
fi

echo "mv ${VMX_PREFIX}.vmx -> ${NEW_NAME}.vmx"
mv "$VMX_PREFIX.vmx" "$NEW_NAME.vmx" || exit 1

echo "mv ${VMX_PREFIX}.nvram -> ${NEW_NAME}.nvram"
mv "$VMX_PREFIX.nvram" "$NEW_NAME.nvram" || exit 1

echo "mv ${VMX_PREFIX}.vmsd -> ${NEW_NAME}.vmsd"
mv "$VMX_PREFIX.vmsd" "$NEW_NAME.vmsd" || exit 1

echo "mv ${VMDK_PREFIX}.vmdk -> ${NEW_NAME}.vmdk"
mv "$VMDK_PREFIX.vmdk" "$NEW_NAME.vmdk" || exit 1

echo "mv ${VMDK_PREFIX}-flat.vmdk -> ${NEW_NAME}-flat.vmdk"
mv "$VMDK_PREFIX-flat.vmdk" "$NEW_NAME-flat.vmdk" || exit 1

[ -e "$VMX_PREFIX.vmxf" ] && echo "mv ${VMX_PREFIX}.vmxf -> /${NEW_NAME}.vmxf"
[ ! -e "$VMX_PREFIX.vmxf" ] || mv "$VMX_PREFIX.vmxf" "$NEW_NAME.vmxf" || exit 1

sed -ie "s/$VMDK_PREFIX\.vmdk/$NEW_NAME.vmdk/g" "$NEW_NAME.vmx"
sed -ie "s/$VMX_PREFIX/$NEW_NAME/g" "$NEW_NAME.vmx"
sed -ie "s/$VMDK_PREFIX/$NEW_NAME/g" "$NEW_NAME.vmdk"
