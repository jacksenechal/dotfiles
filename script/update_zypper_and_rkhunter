#!/bin/bash

TEMP_LOG=$(mktemp)
NOTIFY_EMAIL="your-email@example.com"

# Perform zypper update and log output
/usr/bin/zypper up -y > $TEMP_LOG 2>&1
STATUS=$?

# Flags to check if any relevant changes or notifications are needed
CHANGES_MADE=0
REBOOT_REQUIRED=0
ZYP_DUP_REQUIRED=0

# Check if any changes were made to the system
if ! grep -q "Nothing to do." $TEMP_LOG; then
  CHANGES_MADE=1
fi

# Check if a system reboot is required
if grep -q "system reboot required" $TEMP_LOG; then
  REBOOT_REQUIRED=1
fi

# Check if 'zypper dup' is required
if grep -q "requires to be upgraded by calling 'zypper dup'" $TEMP_LOG; then
  ZYP_DUP_REQUIRED=1
fi

# Check if zypper update failed
if [ $STATUS -ne 0 ]; then
  echo "Zypper update failed with status $STATUS." >&2
  CHANGES_MADE=1
else
  if [ $CHANGES_MADE -eq 1 ]; then
    # Run rkhunter --propupd and log output
    /usr/bin/rkhunter --propupd >> $TEMP_LOG 2>&1
    RKSTATUS=$?
    if [ $RKSTATUS -ne 0 ]; then
      echo "rkhunter --propupd failed with status $RKSTATUS." >&2
      CHANGES_MADE=1
    fi
  fi
fi

# Output the temporary log if it's not empty
if [ -s $TEMP_LOG ]; then
  cat $TEMP_LOG
fi

# Clean up temporary log
rm $TEMP_LOG

if [ $STATUS -ne 0 ] || [ $RKSTATUS -ne 0 ]; then
  exit 1
else
  exit 0
fi
