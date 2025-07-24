#!/bin/bash

# Set default URL if not provided as an environment variable
TARGET_URL=${URL:-"NEED_A_VALID_URL_HERE"}
ORIGIN=${ORIGIN:-"http://evil-corp.com"}
TOKEN=${TOKEN:-"NEED_A_VALID_TOKEN_HERE"}



# Function to test if a request from a disallowed origin is rejected by CORS
test_cors_rejection() {
    local url=$1
    # Using a clearly invalid origin to test rejection
    local disallowed_origin=$2

    echo "--- Testing CORS Rejection ---"
    echo "Target URL: $url"
    echo "Testing with disallowed origin: $disallowed_origin"
    echo "--------------------------------"

    # Emulate a browser's preflight OPTIONS request using curl
    # -s for silent, -i to include headers in the output
    response_headers=$(curl -s -i -X OPTIONS "$url" \
        -H "Origin: $disallowed_origin" \
        -H "Access-Control-Request-Method: GET" \
        -H "Access-Control-Request-Headers: X-Requested-With" \
        -H "Authorization: Bearer $TOKEN")

    # Check if the 'Access-Control-Allow-Origin' header is present in the response.
    # For a rejected request, this header should be absent.
    if echo "$response_headers" | grep -q -i "Access-Control-Allow-Origin"; then
        echo "CORS REJECTION FAILED: The server responded with Access-Control-Allow-Origin for a disallowed origin."
        echo ""
        echo "Full Response Headers:"
        echo "$response_headers"
        return 1 # Represents false in shell scripting
    else
        echo "CORS REJECTION SUCCEEDED: The server correctly blocked the request from the disallowed origin."
        echo ""
        echo "Full Response Headers:"
        echo "$response_headers"
        return 0 # Represents true in shell scripting
    fi
}

# Main function to orchestrate the script
main() {
    if [ "$TOKEN" == "NEED_A_VALID_TOKEN_HERE" ]; then
        echo "Error: A valid token is required. Please set the TOKEN environment variable."
        exit 1
    fi

    if [ "$TARGET_URL" == "NEED_A_VALID_URL_HERE" ]; then
        echo "Error: A valid URL is required. Please set the URL environment variable."
        exit 1
    fi

    if test_cors_rejection "$TARGET_URL" "$ORIGIN"; then
        echo ""
        echo "✅ Test Result: TRUE - The CORS policy correctly rejected the request."
        exit 0
    else
        echo ""
        echo "❌ Test Result: FALSE - The CORS policy did NOT reject the request as expected."
        exit 1
    fi
}

# Execute the main function
main
