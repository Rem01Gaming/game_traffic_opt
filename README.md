# Game Traffic Optimizer

Helps optimize network traffic for gaming by prioritizing specific ports on a chosen interface using `tc` (traffic control) from `iproute2`.

## Usage

1. Ensure `iproute2` is installed.
2. Run the script in a terminal: `bash game_traffic_optimizer.sh`.
3. Follow the prompts to select the interface and the game you want to optimize.
4. Enter the number associated with the game or choose 'Custom' to input your own TCP and UDP ports.
5. If you want to reset network optimizations, run: `bash game_traffic_optimizer.sh reset`.

## Instructions

- When prompted to select an interface, enter the interface name (e.g., ccmni1, wlan0).
- Select a game or choose 'Custom' to input TCP and UDP ports for your game.
- TCP and UDP ports should be comma-separated, and port ranges can be specified using hyphens (e.g., 5000-5221).
- Follow on-screen instructions to complete the setup.

## Important Note

- Ensure the script is run with appropriate permissions to modify network settings (`sudo` may be required).
- Incorrect configurations might affect network performance. Reset network settings if needed.

## Script Structure

- `game_traffic_optimizer.sh`: Main script file.
- Functions:
  - `check_requirements()`: Checks if necessary commands (`ip`, `tc`) are available.
  - `fetch_interfaces()`: Retrieves available interfaces for optimization.
  - `select_interface()`: Prompts the user to select an interface for optimization.
  - `reset_network_optimizations()`: Resets network settings on the selected interface.
  - `select_game()`: Prompts user to select a game or input custom ports.
  - `apply_optimizations()`: Implements traffic prioritization based on selected ports.
  
## Credits
[bilhanet.com](https://bilhanet.com/daftar-port-game-online-untuk-mikrotik-firewall/) for newest Games ports

## License
This Project is licensed under GPL-2.0

## Contributions

Feel free to contribute by suggesting improvements, reporting issues, or creating pull requests.

## Disclaimer

- Use this script at your own risk. Incorrect configurations may impact network connectivity.