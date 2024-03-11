#!/usr/bin/env python3

import argparse
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

def get_current_default_devices():
    """Get the current default input and output devices."""
    input_device = run_command(['pactl', 'get-default-source']).strip()
    output_device = run_command(['pactl', 'get-default-sink']).strip()
    return input_device, output_device

def add_device_pair_to_config(config_directory, config_path, device_name, input_device, output_device):
    """Add a new device pair to the configuration file."""
    if not os.path.exists(config_directory):
        os.makedirs(config_directory)
    if not os.path.isfile(config_path):
        with open(config_path, 'w') as config_file:
            json.dump({}, config_file, indent=4)

    with open(config_path, 'r+') as config_file:
        try:
            config = json.load(config_file)
            config[device_name] = {
                "input_device": input_device,
                "output_device": output_device
            }
            config_file.seek(0)
            json.dump(config, config_file, indent=4)
            config_file.truncate()
        except json.JSONDecodeError as e:
            print(f"Error parsing configuration file: {e}")
            sys.exit(1)

def main():
    """Main function to set the default input and output devices based on the device name."""
    parser = argparse.ArgumentParser(description='Set the default input and output devices based on the device name.')
    parser.add_argument('device_name', help='The name of the device pair to set as default', nargs='?')
    parser.add_argument('-a', '--add', help='Add the currently selected default device pair to the config', type=str, metavar='device_name')
    args = parser.parse_args()

    config_directory = os.path.join(os.path.expanduser('~'), '.config')
    config_path = os.path.join(config_directory, 'sound_devices.json')

    if not vars(args):
        parser.print_help()
        sys.exit(1)

    if args.add:
        device_name = args.add
        if device_name is None:
            print("Please provide a device name to add.")
            sys.exit(1)
        input_device, output_device = get_current_default_devices()
        add_device_pair_to_config(config_directory, config_path, device_name, input_device, output_device)
        print(f"Added current default devices as '{device_name}' to the configuration.")
        sys.exit(0)

    if args.device_name is None:
        parser.print_help()
        sys.exit(1)

    try:
        with open(config_path, 'r') as config_file:
            devices = json.load(config_file)
    except FileNotFoundError:
        print(f"Configuration file not found: {config_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing configuration file: {e}")
        sys.exit(1)

    device_name = args.device_name
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

    print(f"Default input and output devices have been set to '{device_name}'")

if __name__ == '__main__':
    main()
