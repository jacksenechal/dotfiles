#!/usr/bin/env python3

import subprocess
import sys
import json
import os

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
    config_directory = os.path.join(os.path.expanduser('~'), '.config')
    config_path = os.path.join(config_directory, 'sound_devices.json')
    try:
        with open(config_path, 'r') as config_file:
            devices = json.load(config_file)
    except FileNotFoundError:
        print(f"Configuration file not found: {config_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing configuration file: {e}")
        sys.exit(1)

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
