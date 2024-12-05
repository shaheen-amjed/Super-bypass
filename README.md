# Super-bypass
HTTP 401/403 Bypass Tool

A powerful Bash script designed to bypass HTTP 401 Unauthorized and 403 Forbidden status codes using multiple fuzzing techniques. This tool attempts to exploit potential misconfigurations in HTTP methods, headers, paths, User-Agent strings, and protocol versions.
Features

    HTTP Method Fuzzing: Tries various HTTP methods, including standard and uncommon ones.
    User-Agent Fuzzing: Tests bypasses by using different User-Agent strings.
    HTTP Header Fuzzing: Modifies common headers like X-Forwarded-For, Referer, and Authorization.
    Path Fuzzing: Uses creative path manipulations to test access controls.
    Protocol Downgrade: Attempts HTTP/1.0 and HTTP/1.1 versions for unexpected server behavior.
    Color-Coded Output: Displays 200 OK responses in green and other responses in red.
    Extensive Logging: Outputs all results to a bypass_results.txt file for further analysis.

Prerequisites

    Curl: Ensure curl is installed on your system. Use the following command to install if it's missing:

    sudo apt-get install curl

Usage

    Clone the repository or copy the tool.sh script to your local machine.
    Make the script executable:

chmod +x tool.sh

Run the script with the following syntax:

    ./tool.sh -u <target_url> -path <target_path>

Example Command

./tool.sh -u https://example.com -path /admin

Parameters

    -u or --url: The base URL of the target.
    -path or --path: The path to test on the target server.

Output

    The script displays results in the terminal:
        Green for HTTP 200 responses.
        Red for other responses.
    Detailed results are saved in a file named bypass_results.txt.

Example Output

Terminal:

[200 OK] -> Method: POST, Path: /../admin, Protocol: HTTP/1.1
[403 Forbidden] -> Method: GET, Path: /admin, Protocol: HTTP/1.0
[200 OK] -> Method: TRACE, Path: /%2e/admin, Protocol: HTTP/1.1

File (bypass_results.txt):

[Method: POST, User-Agent: Mozilla/5.0 (X11; Linux i686; rv:1.7.13) Gecko/20070322 Kazehakase/0.4.4.1, Header: X-Forwarded-For: 127.0.0.1, Path: /../admin, Protocol: HTTP/1.1] -> HTTP 200 OK
[Method: GET, User-Agent: curl/7.68.0, Header: Referer: /admin, Path: /admin, Protocol: HTTP/1.0] -> HTTP 403 Forbidden

Techniques Used

    HTTP Methods:
        Standard: GET, POST, PUT, DELETE, HEAD, OPTIONS, TRACE.
        Uncommon: FOO, SEARCH, PROPFIND, MKCOL, COPY, MOVE, LOCK, UNLOCK.

    User-Agent Strings:
        Realistic browser and tool-based strings like curl, Python Requests, Firefox, etc.

    Headers:
        Modified headers such as X-Forwarded-For, Referer, Authorization, and Origin.

    Path Manipulation:
        Adds encoded and relative paths like /%2e/admin, /../admin, /..%00/admin.

    HTTP Protocols:
        Uses HTTP/1.1 and downgrades to HTTP/1.0 to test server behavior.

Contributing

Contributions are welcome! Feel free to fork the repository, create a new branch, and submit a pull request with your improvements or new techniques.
Disclaimer

This tool is intended for ethical penetration testing and educational purposes only. Unauthorized use of this tool on systems without proper authorization is illegal and may result in severe consequences.
