#!/usr/bin/env python3

import subprocess
import sys

def run_command(command):
    """Run a system command and return the output."""
    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running command: {' '.join(command)}")
        print(f"Error message: {e}")
        sys.exit(1)

def get_device_id(device_name, device_type):
    """Get the device ID for a given device name and type."""
    command = ['pactl', 'list', 'short', device_type]
    output = run_command(command)
    for line in output.split('\n'):
        if device_name in line:
            return line.split('\t')[0]
    return None

def set_default_device(device_id, device_type):
    """Set the default device for the given device ID and type."""
    command = ['pactl', 'set-default-' + device_type, device_id]
    run_command(command)

def set_default_devices(input_device_id, output_device_id):
    """Set the default input and output devices."""
    set_default_device(input_device_id, 'source')
    set_default_device(output_device_id, 'sink')

def main():
    """Main function to set the default input and output devices based on the device name."""
    devices = {
            "headset": {
                "input_device": "alsa_input.usb-0c76_USB_PnP_Audio_Device-00.mono-fallback",
                "output_device": "alsa_output.usb-0c76_USB_PnP_Audio_Device-00.iec958-stereo"
                },
            "speaker": {
                "input_device": "alsa_input.usb-046d_HD_Pro_Webcam_C920_12E8EDAF-02.iec958-stereo",
                "output_device": "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_3__sink"
                }
            }

    if len(sys.argv) != 2:
        print("Usage: sound.py [device_name]")
        sys.exit(1)

    device_name = sys.argv[1]
    device_pair = devices.get(device_name)

    if not device_pair:
        print(f"Device pair not found: {device_name}")
        sys.exit(1)

    input_device = device_pair["input_device"]
    output_device = device_pair["output_device"]

    input_device_id = get_device_id(input_device, 'sources')
    output_device_id = get_device_id(output_device, 'sinks')

    if not input_device_id or not output_device_id:
        print("Device ID not found")
        sys.exit(1)

    set_default_devices(input_device_id, output_device_id)

    print(f"Default input and output devices have been set to {device_name}")

if __name__ == '__main__':
    main()
